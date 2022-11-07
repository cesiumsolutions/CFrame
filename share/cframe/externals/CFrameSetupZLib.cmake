# ---------------------------------------
# Set up ZLib stuff
# ---------------------------------------

if ( WIN32 )

  if ( NOT ZLIB_VERSION )
    set( ZLIB_VERSION 1.2.11 CACHE STRING "ZLib Version" )
  endif()

  if ( NOT ZLIB_ROOT )
    if ( (NOT "${CFRAME_EXTERN_DIR}" STREQUAL "") AND
         (EXISTS "${CFRAME_EXTERN_DIR}/zlib-${ZLIB_VERSION}") )
      set( ZLIB_ROOT ${CFRAME_EXTERN_DIR}/zlib-${ZLIB_VERSION} )
    else()
      message(
          FATAL_ERROR
          "Either ZLIB_ROOT or CFRAME_EXTERN_DIR are not set, or directory does not exist. Check installation."
      )
      return()
    endif()
  endif()

  find_package( ZLIB ${ZLIB_VERSION} REQUIRED )

  ## include_directories( ${ZLIB_INCLUDE_DIRS} )

endif()

