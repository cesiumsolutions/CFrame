# -----------------------------------------------------------------------------
#
# Initializes various settings and variables.
#
# -----------------------------------------------------------------------------

set( CFRAME_INSTALL_BIN_DIR bin
    CACHE STRING "Directory where binaries will be installed"
)
set( CFRAME_INSTALL_LIB_DIR bin
    CACHE STRING "Directory where runtimme libraries will be installed"
)
set( CFRAME_INSTALL_DEV_DIR lib
    CACHE STRING "Directory where development libraries will be installed"
)

set( BUILD_SHARED_LIBS ON )
set( CMAKE_DEBUG_POSTFIX d CACHE STRING "Postfix for Debug targets" )
set( CMAKE_CXX_STANDARD 14 CACHE STRING "Version of C++ to use" )
set_property( GLOBAL PROPERTY USE_FOLDERS ON )

if ( WIN32 )

  set(
      CFRAME_COMPILE_OPTIONS "/bigobj"
      CACHE STRING
      "Platform specific compile flags"
  )
  add_compile_options( "${CFRAME_COMPILE_OPTIONS}" )

  set(
      CFRAME_WIN_VERSION "0x0601"
      CACHE STRING
      "Version of Windows to build for"
  )
  add_definitions( "-D_WIN32_WINDOWS=${CFRAME_WIN_VERSION}" )

  # Find a more generic way of enable Exception Handling
  set(
      CFRAME_COMPILE_FLAGS "/EHsc"
      CACHE STRING
      "Platform specific compile flags"
  )
  set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CFRAME_COMPILE_FLAGS}" )
  set( CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} ${CFRAME_COMPILE_FLAGS}" )

  foreach( CONFIG ${CMAKE_CONFIGURATION_TYPES} )
    string( TOUPPER ${CONFIG} UCONFIG )
    set( CMAKE_CXX_FLAGS_${UCONFIG} "${CMAKE_CXX_FLAGS_${UCONFIG}} ${CFRAME_COMPILE_FLAGS}" )
    set( CMAKE_C_FLAGS_${UCONFIG} "${CMAKE_C_FLAGS_${UCONFIG}} ${CFRAME_COMPILE_FLAGS}" )
  endforeach()

  set(
      CFRAME_LOADER_LIBRARIES
      Dbghelp.lib
      CACHE STRING
      "List of (platform specific) libraries to link"
  )
endif()
