# -----------------------------------------------------------------------------
#
# Functions to manage External Dependencies.
#
# -----------------------------------------------------------------------------

if ( WIN32 )

  if ( NOT EXISTS ${CFRAME_DIR}/../CFrameExtern )

    set(
        CFRAME_EXTERN_SEARCH_PATHS
        ""
        CACHE STRING
        "Directory paths to search for external library dependencies."
    )
    message( WARNING
        "CFRAME_EXTERN_SEARCH_PATHS not set and could not be found,"
        " set manually or place CFrameExtern as a sibling directory to CFrame"
    )

    return()
  endif() # CFrameExtern exists

  if ( ${CMAKE_GENERATOR} STREQUAL "Visual Studio 18 2026" )
    set(
        CFRAME_EXTERN_SEARCH_PATHS
        ${CFRAME_DIR}/../CFrameExtern/source
        ${CFRAME_DIR}/../CFrameExtern/win64-vc17
        CACHE STRING
        "Directory paths to search for external library dependencies."
    )
  elseif ( ${CMAKE_GENERATOR} STREQUAL "Visual Studio 17 2022" )
    set(
        CFRAME_EXTERN_SEARCH_PATHS
        ${CFRAME_DIR}/../CFrameExtern/source
        ${CFRAME_DIR}/../CFrameExtern/win64-vc17
        CACHE STRING
        "Directory paths to search for external library dependencies."
    )
  elseif( ${CMAKE_GENERATOR} STREQUAL "Visual Studio 16 2019" )
    set(
        CFRAME_EXTERN_SEARCH_PATHS
        ${CFRAME_DIR}/../CFrameExtern/source
        ${CFRAME_DIR}/../CFrameExtern/win64-vc16
        CACHE STRING
        "Directory paths to search for external library dependencies."
    )
  else()
    message( FATAL_ERROR
        "CFrameExtern directories do not support specified generator: ${CMAKE_GENERATOR}"
    )
  endif()

  cframe_message(
      MODE STATUS
      TAGS CFrame ExternalLibraries
      VERBOSITY 1
      "Setting CFRAME_EXTERN_SEARCH_PATHS to: ${CFRAME_EXTERN_SEARCH_PATHS}"
  )

endif() # WIN32
