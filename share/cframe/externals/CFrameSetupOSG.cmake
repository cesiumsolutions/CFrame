# -------------------
# Set up OpenGL Stuff
# -------------------
find_package( OpenGL REQUIRED )

include_directories( ${OPENGL_INCLUDE_DIR} )

# ---------------------------------------
# Set up OpenSceneGraph/OpenThreads stuff
# ---------------------------------------

if ( WIN32 )
  if ( NOT OSG_VERSION )
    set( OSG_VERSION 3.6.3 CACHE STRING "OpenSceneGraph Version" )
  endif()

  if ( NOT OSG_DIR )

    cframe_search_paths(
        OpenSceneGraph-${OSG_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        OSG_DIR
    )

    if ( "${OSG_DIR}" STREQUAL "" )
      message(
          FATAL_ERROR
          "OSG not found, set OSG_DIR or CFRAME_EXTERN_SEARCH_PATHS"
      )
      return()
    endif()

  endif()

  find_package( OpenSceneGraph ${OSG_VERSION} REQUIRED
                osgDB
                osgGA
                osgShadow
                osgSim
                osgText
                osgUtil
                osgViewer
  )

else()

  find_package( OpenSceneGraph REQUIRED COMPONENTS
                osgDB
                osgGA
                osgShadow
                osgSim
                osgText
                osgUtil
                osgViewer
  )

endif()

include_directories( ${OPENSCENEGRAPH_INCLUDE_DIRS} )

