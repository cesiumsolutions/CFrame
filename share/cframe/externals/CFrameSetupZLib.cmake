# ---------------------------------------
# Set up ZLib stuff
# ---------------------------------------

if ( WIN32 )

  if ( NOT ZLIB_VERSION )
    set( ZLIB_VERSION 1.2.11 CACHE STRING "ZLib Version" )
  endif()

  if ( NOT ZLIB_ROOT )

    cframe_search_paths(
        zlib-${ZLIB_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        ZLIB_ROOT
    )

    if ( "${ZLIB_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "ZLib not found, set ZLIB_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()
  endif()

  find_package( ZLIB ${ZLIB_VERSION} REQUIRED )

  ## include_directories( ${ZLIB_INCLUDE_DIRS} )

endif()

