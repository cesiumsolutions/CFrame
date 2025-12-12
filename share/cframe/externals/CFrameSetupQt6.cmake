
set(
	Qt6_COMPONENTS Core Gui Widgets
    CACHE STRING "List of Qt6 Components to use."
)

if ( WIN32 )
  if ( NOT Qt6_DIR )
    message( FATAL_ERROR
        "Set Qt6_DIR to the location of lib\\cmake\\Qt6 subdirectory in the Qt6 "
        "installation, e.g. C:\\Qt\\6.8.3\\msvc2022_64\\lib\\cmake\\Qt6"
    )
  endif()

  set( CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${Qt6_DIR} )
endif()

find_package( Qt6 REQUIRED COMPONENTS ${Qt6_COMPONENTS} )

qt_standard_project_setup()
