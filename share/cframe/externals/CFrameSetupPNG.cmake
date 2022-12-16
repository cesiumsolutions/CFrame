# ---------------------------------------
# Set up PNG stuff
# ---------------------------------------

if ( WIN32 )

  if ( NOT PNG_VERSION )
    set( PNG_VERSION_STRING 1.6.37 CACHE STRING "PNG Version" )
  endif()

  if ( NOT PNG_ROOT )
    cframe_search_paths(
        libpng-${PNG_VERSION_STRING}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        PNG_ROOT
    )

    if ( "${PNG_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "PNG not found, set PNG_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()
  endif()

  # These have to be hardcoded for some reason, kind of useless if you have to specify everything before find_package can find it for you
  set( PNG_LIBRARY ${PNG_ROOT}/lib/libpng14.lib )
  set( PNG_PNG_INCLUDE_DIR ${PNG_ROOT}/include )
  find_package( PNG REQUIRED )

endif()

