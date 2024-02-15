# ---------------------------------------
# Set up GStreamer stuff
# ---------------------------------------


if ( WIN32 )

  if ( NOT GSTREAMER_DIR )

    cframe_search_paths(
        gstreamer
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        GSTREAMER_DIR
    )

    if ( "${GSTREAMER_DIR}" STREQUAL "" )
      message(
          FATAL_ERROR
          "GStreamer not found, set GSTREAMER_DIR or CFRAME_EXTERN_SEARCH_PATHS"
      )
      return()
    endif()

  endif()

  set( ENV{PKG_CONFIG_PATH} "${GSTREAMER_DIR}/lib/pkgconfig" )

endif()

find_package(PkgConfig REQUIRED)
pkg_search_module(gstreamer REQUIRED IMPORTED_TARGET gstreamer-1.0)

set(
    GSTREAMER_COMPONENTS sdp app video
    CACHE STRING "GStreamer components to link"
)

foreach( COMPONENT ${GSTREAMER_COMPONENTS} )
  pkg_search_module(
      gstreamer-${COMPONENT} REQUIRED
      IMPORTED_TARGET gstreamer-${COMPONENT}-1.0
  )
endforeach()
