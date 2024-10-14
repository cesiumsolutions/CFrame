cmake_minimum_required( VERSION 3.10 )
project( qtosgboost-sample )

if ( "${CFRAME_FOUND}" )
  include( CFrameLists.txt )
  return()
endif()


# -----------------------------------------------------------------------------
# Setup CMake stuff
# -----------------------------------------------------------------------------

set( CMAKE_DEBUG_POSTFIX d )

# -----------------------------------------------------------------------------
# Setup C++ stuff
# -----------------------------------------------------------------------------

set( CMAKE_CXX_STANDARD 17 )

# -----------------------------------------------------------------------------
# Setup Windows stuff
# -----------------------------------------------------------------------------

if ( WIN32 )
  set( OS_DEFINITIONS
      -DWIN32
      -D_WINDOWS
  )
  set( OS_COMPILE_OPTIONS
      /std:c++17
      /Zc:__cplusplus
      /EHsc
  )
endif()

# -----------------------------------------------------------------------------
# Setup Boost
# -----------------------------------------------------------------------------
find_package( Boost REQUIRED
    date_time
    filesystem
    system
)

list(
    APPEND Boost_DEFINITIONS
    BOOST_ALL_DYN_LINK
)

# -----------------------------------------------------------------------------
# Setup Qt
# -----------------------------------------------------------------------------

# From share/cframe/externals/CFrameSetupQt.cmake
macro( QT5_SETUP_COMPONENT COMPONENT )
  find_package( Qt5${COMPONENT} )
  list( APPEND QT_INCLUDES ${Qt5${COMPONENT}_INCLUDE_DIRS} )

  # Strip off the preceding "-D" from each definition as this was causing
  # problems on Linux (RHEL8)
  foreach( COMPONENT_DEFINITION ${Qt5${COMPONENT}_DEFINITIONS} )
    string(
        SUBSTRING "${COMPONENT_DEFINITION}" 2 -1
        COMP_DEF
    )
    list( APPEND QT_DEFINITIONS ${COMP_DEF} )
  endforeach()

  list( APPEND QT_LIBRARIES ${Qt5${COMPONENT}_LIBRARIES} )
  set( CMAKE_CXX_FLAGS "${Qt5${COMPONENT}_EXECUTABLE_COMPILE_FLAGS}" )

endmacro()

set( CMAKE_PREFIX_PATH ${QTDIR} )
set( QT5_COMPONENTS
    Core
    Gui
    Widgets
    CACHE STRING "List of Qt Components to link"
)
foreach( COMPONENT ${QT5_COMPONENTS} )
  qt5_setup_component( ${COMPONENT} )
endforeach()

if ( WIN32 )
  install(
      FILES "$<TARGET_FILE:Qt5::QWindowsIntegrationPlugin>"
      DESTINATION bin/platforms
  )
endif() # WIN32

# -----------------------------------------------------------------------------
# Setup OpenSceneGraph
# -----------------------------------------------------------------------------

find_package( OpenGL REQUIRED )

if ( WIN32 )
  set( OSG_VERSION 3.6.3 CACHE STRING "OpenSceneGraph Version")
endif()

find_package(
  OpenSceneGraph ${OSG_VERSION}
  REQUIRED COMPONENTS
      osgDB
      osgGA
      osgText
      osgUtil
      osgViewer
)

# -----------------------------------------------------------------------------
# Setup the library
# -----------------------------------------------------------------------------

set( LIB_TARGET qtosgboost )
set( LIB_TARGET_HEADERS_PUBLIC
    qtosgboostapi.h
    qtosgboost.hpp
)
set( LIB_TARGET_SOURCES
    qtosgboost.cpp
)

add_library(
    ${LIB_TARGET} SHARED
    ${LIB_TARGET_HEADERS_PUBLIC}
    ${LIB_TARGET_SOURCES}
)

set_target_properties(
    ${LIB_TARGET}
    PROPERTIES
        DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
)

target_compile_definitions(
    ${LIB_TARGET}
    PUBLIC
        ${OS_DEFINITIONS}
        ${Boost_DEFINITIONS}
        ${QT_DEFINITIONS}
)

target_compile_options(
    ${LIB_TARGET}
    PUBLIC
        ${OS_COMPILE_OPTIONS}
)

target_include_directories(
    ${LIB_TARGET}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/..
        ${OPENSCENEGRAPH_INCLUDE_DIRS}
        ${QT_INCLUDES}
        ${Boost_INCLUDE_DIRS}
        ${OPENGL_INCLUDE_DIR}
)

target_link_libraries(
    ${LIB_TARGET}
    PUBLIC
        ${OPENSCENEGRAPH_LIBRARIES}
        ${QT_LIBRARIES}
        ${Boost_LIBRARIES}
)

install(
    FILES ${LIB_TARGET_HEADERS_PUBLIC}
    DESTINATION include/${LIB_TARGET}
)

# -----------------------------------------------------------------------------
# Setup the library
# -----------------------------------------------------------------------------

set( APP_TARGET qtosgboostviewer )

set( MODEL_FILES
    testPattern-1024x512.rgb
    testPattern-1024x512.rgb.attr
    testSphere.osg
)

add_executable(
    ${APP_TARGET}
    qtosgboostviewer.cpp
    ${MODEL_FILES}
)

set_target_properties(
    ${APP_TARGET}
    PROPERTIES
        DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
)

target_link_libraries(
    ${APP_TARGET}
    PUBLIC
        ${LIB_TARGET}
)

install(
    TARGETS ${LIB_TARGET} ${APP_TARGET}
    RUNTIME DESTINATION bin COMPONENT Runtime
    LIBRARY DESTINATION lib COMPONENT Runtime
    ARCHIVE DESTINATION lib COMPONENT Development
)

install(
    FILES ${MODEL_FILES}
    DESTINATION bin/models
)
