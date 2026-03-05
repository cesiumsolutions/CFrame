# -----------------------------------------------------------------------------
#
# Functions to retrieve and display system information.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Print System Information
# -----------------------------------------------------------------------------
function( cframe_print_system_info )

  if ( ARGC GREATER 0 )
    set( MESSAGE_MODE ${ARGV0} )
  else()
    set( MESSAGE_MODE STATUS )
  endif()

  message( ${MESSAGE_MODE} "System Info:" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM:           ${CMAKE_SYSTEM}" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM_NAME:      ${CMAKE_SYSTEM_NAME}" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM_VERSION:   ${CMAKE_SYSTEM_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}" )
  message( ${MESSAGE_MODE} "    CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}" )

  get_filename_component( currListFile ${CMAKE_CURRENT_LIST_FILE} NAME_WLE )
  if ( EXISTS ${CMAKE_CURRENT_LIST_DIR}/detail/${currListFile}-${CMAKE_SYSTEM_NAME}.cmake )
    include( ${CMAKE_CURRENT_LIST_DIR}/detail/${currListFile}-${CMAKE_SYSTEM_NAME}.cmake )

    if ( COMMAND cframe_print_${CMAKE_SYSTEM_NAME}_system_info )
      cmake_language(
          CALL "cframe_print_${CMAKE_SYSTEM_NAME}_system_info" ${MESSAGE_MODE}
      )
    endif()
  endif()

endfunction() # cframe_print_system_info

cframe_print_system_info( )

#
# Gather system information and place them in CFRAME_PLATFORM_ID variables
# which can be used e.g. for organizing files in directories according to
# compiler version.
#

# --- Function: Get OS Name and OS Version separately ---
function( cframe_get_os_info OS_NAME_OUTPUT_VAR OS_VERSION_OUTPUT_VAR )
  if( WIN32 )
    set( _OS_NAME "win" )
    if( CMAKE_SYSTEM_VERSION VERSION_GREATER_EQUAL "10.0.22000" )
      set( _OS_VERSION "11" )
    else()
      set( _OS_VERSION "10" )
    endif()
  elseif( APPLE )
    set( _OS_NAME "mac" )
    string( REGEX MATCH "^([0-9]+)" _OS_VERSION "${CMAKE_SYSTEM_VERSION}" )
  elseif( CMAKE_SYSTEM_NAME MATCHES "Linux" )
    if( CMAKE_VERSION VERSION_GREATER_EQUAL "3.22" )
      cmake_host_system_information( RESULT _OS_NAME QUERY DISTRIB_ID )
      cmake_host_system_information( RESULT _OS_VERSION QUERY DISTRIB_VERSION_ID )
    endif()

    if( NOT _OS_NAME OR NOT _OS_VERSION )
      if( EXISTS "/etc/os-release" )
        file( READ "/etc/os-release" OS_INFO )
        if( OS_INFO MATCHES "ID=([^\n\"]+|[\"][^\"]+[\"])" )
          string( REPLACE "\"" "" _OS_NAME "${CMAKE_MATCH_1}" )
        endif()
        if( OS_INFO MATCHES "VERSION_ID=([^\n\"]+|[\"][^\"]+[\"])" )
          string( REPLACE "\"" "" _OS_VERSION "${CMAKE_MATCH_1}" )
        endif()
      endif()
    endif()
    string( TOLOWER "${_OS_NAME}" _OS_NAME )
  endif()

  set( ${OS_NAME_OUTPUT_VAR} "${_OS_NAME}" PARENT_SCOPE )
  set( ${OS_VERSION_OUTPUT_VAR} "${_OS_VERSION}" PARENT_SCOPE )
endfunction() # cframe_get_os_info

# --- Function: Get Architecture Bits ---
function( cframe_get_bits_info OUTPUT_VAR )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( ${OUTPUT_VAR} "64" PARENT_SCOPE )
  else()
    set( ${OUTPUT_VAR} "32" PARENT_SCOPE )
  endif()
endfunction() # cframe_get_bits_info

# --- Function: Get Compiler Name and Major Version separately ---
function( cframe_get_compiler_info NAME_OUT_VAR VERSION_OUT_VAR )
  if( MSVC )
    set( _ID "vc" )
    if( MSVC_VERSION GREATER_EQUAL 1940 )
      set( _VERSION "18" )
    elseif( MSVC_VERSION GREATER_EQUAL 1930 )
      set( _VERSION "17" )
    else()
      set( _VERSION "16" )
    endif()
  elseif( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
    set( _ID "clang" )
    set( _VERSION ${CMAKE_CXX_COMPILER_VERSION_MAJOR} )
  elseif( CMAKE_CXX_COMPILER_ID MATCHES "GNU" )
    set( _ID "gc" )
    set( _VERSION ${CMAKE_CXX_COMPILER_VERSION_MAJOR} )
  endif()

  set( ${NAME_OUT_VAR} "${_ID}" PARENT_SCOPE )
  set( ${VERSION_OUT_VAR} "${_VERSION}" PARENT_SCOPE )
endfunction() # cframe_get_compiler_info

# --- Function: Get Platform ID using a format string ---
# Format keywords:
#   {OS_NAME}     Operating System name, e.g. win, ubuntu, mac
#   {OS_VERSION}  Operating System major
#   {OS_BITS}     Operating System bits, e.g. 32, 64
#   {COMPILER_NAME}     Compiler name, e.g.
#      - vc for Visual C(++)
#      - gcc
#      - clang
#   {COMPILER_VERSION}  Compiler version major
function( cframe_get_platform_id FORMAT_STR OUTPUT_VAR )
  cframe_get_os_info( _OS_NAME _OS_VERSION )
  cframe_get_bits_info( _BITS )
  cframe_get_compiler_info( _COMPILER_NAME _COMPILER_VERSION )

  set( _RESULT "${FORMAT_STR}" )
  string( REPLACE "{OS_NAME}" "${_OS_NAME}" _RESULT "${_RESULT}" )
  string( REPLACE "{OS_VERSION}" "${_OS_VERSION}" _RESULT "${_RESULT}" )
  string( REPLACE "{OS_BITS}" "${_BITS}" _RESULT "${_RESULT}" )
  string( REPLACE "{COMPILER_NAME}" "${_COMPILER_NAME}" _RESULT "${_RESULT}" )
  string( REPLACE "{COMPILER_VERSION}" "${_COMPILER_VERSION}" _RESULT "${_RESULT}" )

  set( ${OUTPUT_VAR} "${_RESULT}" PARENT_SCOPE )
endfunction() # cframe_get_platform_id

# --- Execution ---
cframe_get_platform_id(
    "{OS_NAME}{OS_VERSION}-x{OS_BITS}-{COMPILER_NAME}{COMPILER_VERSION}" PLAT_ID
)

set( CFRAME_PLATFORM_ID "${PLAT_ID}" 
  CACHE STRING "CFrame Platform Identifier" FORCE 
)

message( STATUS "CFRAME_PLATFORM_ID: ${CFRAME_PLATFORM_ID}" )
