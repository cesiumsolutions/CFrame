# -----------------------------------------------------------------------------
#
# Functions to retrieve and display compiler information.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Print Compiler Information
# -----------------------------------------------------------------------------
function( cframe_print_compiler_info )

  if ( ARGC EQUAL 0 )
    return()
  elseif( ARGC EQUAL 1 )
    set( MESSAGE_MODE STATUS )
    set( LANG ${ARGV0} )
  else()
    set( MESSAGE_MODE ${ARGV0} )
    set( LANG ${ARGV1} )
  endif()

  message( ${MESSAGE_MODE} "Compiler Info: [${LANG}]" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_ID:               ${CMAKE_${LANG}_COMPILER_ID}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_VERSION:          ${CMAKE_${LANG}_COMPILER_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER:                  ${CMAKE_${LANG}_COMPILER}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_ABI:              ${CMAKE_${LANG}_COMPILER_ABI}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_TARGET:           ${CMAKE_${LANG}_COMPILER_TARGET}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_LAUNCHER:         ${CMAKE_${LANG}_COMPILER_LAUNCHER}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_ARCHITECTURE_ID:  ${CMAKE_${LANG}_ARCHITECTURE_ID}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_VERSION_INTERNAL: ${CMAKE_${LANG}_COMPILER_VERSION_INTERNAL}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_AR:               ${CMAKE_${LANG}_COMPILER_AR}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_RANLIB:           ${CMAKE_${LANG}_COMPILER_RANLIB}" )
  message( ${MESSAGE_MODE} "    CMAKE_${LANG}_COMPILER_LOADED:           ${CMAKE_${LANG}_COMPILER_LOADED}" )

  get_filename_component( currListFile ${CMAKE_CURRENT_LIST_FILE} NAME_WLE )
  if ( EXISTS ${CMAKE_CURRENT_LIST_DIR}/detail/${currListFile}-${CMAKE_SYSTEM_NAME}.cmake )
    include( ${CMAKE_CURRENT_LIST_DIR}/detail/${currListFile}-${CMAKE_SYSTEM_NAME}.cmake )

    if ( COMMAND cframe_print_${CMAKE_SYSTEM_NAME}_compiler_info )
      cmake_language(
          CALL "cframe_print_${CMAKE_SYSTEM_NAME}_compiler_info" ${MESSAGE_MODE}
      )
    endif()
  endif()

endfunction() # cframe_print_compiler_info

if ( CFRAME_RUN_TESTS )
  cframe_print_compiler_info( CXX )
endif()
