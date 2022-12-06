# -----------------------------------------------------------------------------
#
# Initializes various settings and variables.
#
# -----------------------------------------------------------------------------

set( CFRAME_INSTALL_BIN_DIR bin
    CACHE STRING "Directory where binaries will be installed"
)
set( CFRAME_INSTALL_LIB_DIR lib
    CACHE STRING "Directory where runtime libraries will be installed"
)
set( CFRAME_INSTALL_DEV_DIR lib
    CACHE STRING "Directory where development libraries will be installed"
)

set( BUILD_SHARED_LIBS ON )
set( CMAKE_DEBUG_POSTFIX d CACHE STRING "Postfix for Debug targets" )
set_property( GLOBAL PROPERTY USE_FOLDERS ON )

# For some reason, compiling with -g doesn't automatically define this standard macro
if ( CMAKE_BUILD_TYPE STREQUAL "Debug" )
  add_definitions( -DDEBUG )
else()
  add_definitions( -DNDEBUG )
endif()

option(
    CFRAME_OPTION_EXCEPTIONS
    "Turn on to enable exception handling"
    ON
)

option(
    CFRAME_OPTION_BIG_OBJECTS
    "Turn ON to enable large compilation objects."
    ON
)

if ( WIN32 )

  # Set Windows version, used by socket libraries
  set(
      CFRAME_WIN_VERSION "0x0601"
      CACHE STRING
      "Version of Windows to build for"
  )
  add_definitions( "-D_WIN32_WINDOWS=${CFRAME_WIN_VERSION}" )
  add_definitions( "-D_WIN32_WINNT=${CFRAME_WIN_VERSION}" )

  if ( CFRAME_OPTION_EXCEPTIONS )
    set(
        CFRAME_COMPILE_OPTIONS
        ${CFRAME_COMPILE_OPTIONS} /EHsc
        CACHE INTERNAL "Compile Options"
    )
  endif()

  if ( CFRAME_OPTION_BIG_OBJECTS )
    set(
        CFRAME_COMPILE_OPTIONS
        ${CFRAME_COMPILE_OPTIONS} /bigobj
        CACHE INTERNAL "Compile Options"
    )
  endif()

endif()
