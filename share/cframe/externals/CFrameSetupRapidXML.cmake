# ---------------------------------------
# Set up RAPIDXML stuff
# ---------------------------------------

if ( WIN32 )

  if ( NOT RAPIDXML_VERSION )
    set( RAPIDXML_VERSION_STRING 1.13 CACHE STRING "RAPIDXML Version" )
  endif()

  if ( NOT RAPIDXML_ROOT )
    cframe_search_paths(
        rapidxml-${RAPIDXML_VERSION_STRING}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        RAPIDXML_ROOT
    )

    if ( "${RAPIDXML_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "RAPIDXML not found, set RAPIDXML_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()
  endif()
  set( RAPIDXML_DIR ${RAPIDXML_ROOT} )
  set( RAPIDXML_INCLUDE_DIR ${RAPIDXML_ROOT} )

endif()
