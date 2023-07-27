# ---------------------------------------
# Set up OpenCV
# ---------------------------------------

set( OpenCV_COMPONENTS
    core imgproc imgcodecs videoio highgui video
    CACHE STRING "OpenCV Components"
)

foreach( OpenCV_COMPONENT ${OpenCV_COMPONENTS} )
  list( APPEND OpenCV_PACKAGE_COMPONENTS "opencv_${OpenCV_COMPONENT}" )
endforeach()


if ( WIN32 )

  if ( NOT OpenCV_VERSION )
    set( OpenCV_VERSION 4.8.0 CACHE STRING "OpenCV Version" )
  endif()

  if ( NOT OpenCV_DIR )

    cframe_search_paths(
        opencv-${OpenCV_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        OpenCV_DIR
    )

    list( APPEND CMAKE_MODULE_PATH ${OpenCV_DIR} )

    if ( "${OpenCV_DIR}" STREQUAL "" )
      message(
          FATAL_ERROR
          "OpenCV directory not found, set OpenCV_DIR or CFRAME_EXTERN_SEARCH_PATHS."
      )
    endif()

  endif()

  set( OpenCV_FOUND "" )
  find_package(
      OpenCV ${OpenCV_VERSION}
      REQUIRED COMPONENTS ${OpenCV_PACKAGE_COMPONENTS}
  )

else()

  find_package(
      OpenCV
      REQUIRED COMPONENTS ${OpenCV_PACKAGE_COMPONENTS}
  )

endif()
