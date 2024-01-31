# ---------------------------------------
# Set up CURL stuff
# ---------------------------------------

find_package( PkgConfig )

if ( WIN32 )

  if ( NOT CURL_VERSION )
    set( CURL_VERSION_STRING 8.5.0 CACHE STRING "CURL Version" )
  endif()

  if ( NOT CURL_ROOT )
    cframe_search_paths(
        curl-${CURL_VERSION_STRING}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        CURL_ROOT
    )

    if ( "${CURL_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "CURL not found, set CURL_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()
  endif()
  set( CURL_DIR ${CURL_ROOT} )

  # These have to be hardcoded for some reason, kind of useless if you have to specify everything before find_package can find it for you
  set( CURL_LIBRARY ${CURL_ROOT}/lib/libcurl_imp.lib )
  set( CURL_LIBRARY_DEBUG ${CURL_ROOT}/lib/libcurl-d_imp.lib )
  set( CURL_INCLUDE_DIR ${CURL_ROOT}/include )

  set(
      CURL_LIBRARIES
      optimized ${CURL_LIBRARY}
      debug ${CURL_LIBRARY_DEBUG}
  )

endif()

find_package( CURL REQUIRED )
