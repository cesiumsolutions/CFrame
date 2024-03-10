# ---------------------
# Set up FFmpeg package
# ---------------------

if ( WIN32 )

  set( FFMPEG_VERSION 6.1.1 CACHE STRING "Version of FFmpeg" )

  if ( NOT FFMPEG_ROOT )
    cframe_search_paths(
        "ffmpeg-${FFMPEG_VERSION}-full_build-shared"
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        FFMPEG_ROOT
    )

    if ( "${FFMPEG_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "FFmpeg not found, set FFMPEG_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()
  endif()

endif()

# See FindFFMPEG.cmake for list of supported components
set( FFMPEG_COMPONENTS
    avcodec
    avdevice
    avfilter
    avformat
    # avresample
    avutil
    swresample
    swscale
    CACHE STRING "FFmpeg components to link with"
)

find_package(
    FFMPEG REQUIRED  
    ${FFMPEG_COMPONENTS}
)
