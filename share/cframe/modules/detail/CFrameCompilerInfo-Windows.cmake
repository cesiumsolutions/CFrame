# -----------------------------------------------------------------------------
#
# Functions to retrieve and display Windows-specific compiler information.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Provides Version Number and Year based on MSVC_TOOLSET_VERSION
# @see https://cmake.org/cmake/help/latest/variable/MSVC_TOOLSET_VERSION.html#variable:MSVC_TOOLSET_VERSION
# -----------------------------------------------------------------------------
function( cframe_get_msvc_version_info VERSION_NUMBER VERSION_YEAR )

  if ( ${MSVC_TOOLSET_VERSION} EQUAL 80 )
    set( ${VERSION_NUMBER} 8 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2005 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 90 )
    set( ${VERSION_NUMBER} 9 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2008 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 100 )
    set( ${VERSION_NUMBER} 10 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2010 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 110 )
    set( ${VERSION_NUMBER} 11 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2012 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 120 )
    set( ${VERSION_NUMBER} 12 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2013 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 140 )
    set( ${VERSION_NUMBER} 14 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2015 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 141 )
    set( ${VERSION_NUMBER} 15 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2017 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 142 )
    set( ${VERSION_NUMBER} 16 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2019 PARENT_SCOPE )
  elseif ( ${MSVC_TOOLSET_VERSION} EQUAL 143 )
    set( ${VERSION_NUMBER} 17 PARENT_SCOPE )
    set( ${VERSION_YEAR} 2022 PARENT_SCOPE )
  else()
    set( ${VERSION_NUMBER} MSVC_VERSION_NUMBER_UNDEFINED PARENT_SCOPE )
    set( ${VERSION_YEAR} MSVC_VERSION_YEAR_UNDEFINED PARENT_SCOPE )
  endif() # MSVC_TOOLSET_VERSION

endfunction() # cframe_get_msvc_version_info

# -----------------------------------------------------------------------------
# Print Windows-specific Compiler Information
# -----------------------------------------------------------------------------
function( cframe_print_windows_compiler_info )

  if ( ARGC GREATER 0 )
    set( MESSAGE_MODE ${ARGV0} )
  else()
    set( MESSAGE_MODE STATUS )
  endif()

  cframe_get_msvc_version_info( MSVC_VERSION_NUMBER MSVC_VERSION_YEAR )
  
  message( ${MESSAGE_MODE} "    MSVC_VERSION:                                     ${MSVC_VERSION}" )
  message( ${MESSAGE_MODE} "    MSVC_VERSION_NUMBER:                              ${MSVC_VERSION_NUMBER}" )
  message( ${MESSAGE_MODE} "    MSVC_VERSION_YEAR:                                ${MSVC_VERSION_YEAR}" )
  message( ${MESSAGE_MODE} "    MSVC_IDE:                                         ${MSVC_IDE}" )
  message( ${MESSAGE_MODE} "    MSVC_TOOLSET_VERSION:                             ${MSVC_TOOLSET_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_PLATFORM_NAME:                           ${CMAKE_VS_PLATFORM_NAME}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_PLATFORM_NAME_DEFAULT:                   ${CMAKE_VS_PLATFORM_NAME_DEFAULT}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_PLATFORM_TOOLSET:                        ${CMAKE_VS_PLATFORM_TOOLSET}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE:      ${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_PLATFORM_TOOLSET_VERSION:                ${CMAKE_VS_PLATFORM_TOOLSET_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_TARGET_FRAMEWORK_IDENTIFIER:             ${CMAKE_VS_TARGET_FRAMEWORK_IDENTIFIER}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_TARGET_FRAMEWORK_VERSION:                ${CMAKE_VS_TARGET_FRAMEWORK_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_TARGET_FRAMEWORK_TARGETS_VERSION:        ${CMAKE_VS_TARGET_FRAMEWORK_TARGETS_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION:         ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION_MAXIMUM: ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION_MAXIMUM}" )
  message( ${MESSAGE_MODE} "    CMAKE_VS_INTEL_Fortran_PROJECT_VERSION:           ${CMAKE_VS_INTEL_Fortran_PROJECT_VERSION}" )

endfunction() # cframe_print_windows_compiler_info
