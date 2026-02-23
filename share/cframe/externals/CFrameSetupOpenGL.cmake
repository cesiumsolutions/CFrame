
find_package( OpenGL REQUIRED )

if ( WIN32 )

  set( OPENGL_LIBRARIES
      optimized ${OPENGL_LIBRARIES}
      debug     ${OPENGL_LIBRARIES}
  )

endif()

