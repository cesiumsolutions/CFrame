# Qt 5 convenience macros
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

macro( QT5_SETUP_COMPONENTS COMPONENTS )
  foreach( COMPONENT ${${COMPONENTS}} )
    qt5_setup_component( ${COMPONENT} )
  endforeach()
endmacro()

macro( QT5_SETUP_EXECUTABLE_COMPONENTS EXECUTABLE COMPONENTS )
  foreach( COMPONENT ${${COMPONENTS}} )
    qt5_use_modules( ${EXECUTABLE} ${COMPONENT} )
  endforeach()
endmacro()

if ( ENV{QT_VERSION} )
  set( QT_VERSION $ENV{QT_VERSION} )
endif()

# set up Qt stuff
if ( WIN32 )

  if ( NOT QT_VERSION )
    set( QT_VERSION 5.15.1 CACHE STRING "Qt Version")
  endif()
  string( SUBSTRING ${QT_VERSION} 0 1 QT_VERSION_MAJOR )
  string( COMPARE EQUAL ${QT_VERSION_MAJOR} "4" QT_VERSION_4 )
  string( COMPARE EQUAL ${QT_VERSION_MAJOR} "5" QT_VERSION_5 )

  if ( NOT ENV{QTDIR} AND NOT QTDIR )

    cframe_search_paths(
        Qt${QT_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        QT_ROOT
    )
    if ( "${QT_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "Qt not found, set QTDIR or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()

    # Setup some hard-coded mappings between Qt version and the installation
    # (sub)directory. Don't really know how else to do this elegantly
    if ( QT_VERSION_5 )
      set( QT_SUBPATH "${QT_VERSION}/msvc2019")
    endif()

    if ( "${CMAKE_SIZEOF_VOID_P}" )
      set( QT_BITS "_64" )
    endif()

    set( ENV{QTDIR} ${QT_ROOT}/${QT_SUBPATH}${QT_BITS} )
    set( QTDIR ${QT_ROOT}/${QT_SUBPATH}${QT_BITS}   )
    set( QT_QMAKE_EXECUTABLE ${QTDIR}/bin/qmake )

    message( STATUS "Setting QTDIR to ${QTDIR}")

  endif()

else()

  if ( QT_VERSION )
    string( SUBSTRING ${QT_VERSION} 0 1 QT_VERSION_MAJOR )
    string( COMPARE EQUAL ${QT_VERSION_MAJOR} "4" QT_VERSION_4 )
    string( COMPARE EQUAL ${QT_VERSION_MAJOR} "5" QT_VERSION_5 )
  elseif ( ENV{QT_VERSION} )
    string( SUBSTRING ${ENVQT_VERSION} 0 1 QT_VERSION_MAJOR )
    string( COMPARE EQUAL $ENV{QT_VERSION_MAJOR} "4" QT_VERSION_4 )
    string( COMPARE EQUAL $ENV{QT_VERSION_MAJOR} "5" QT_VERSION_5 )
  else()
    set( QT_VERSION_5 ON )
  endif()

endif()

# Version specific setup
if ( QT_VERSION_4 )

  find_package( Qt4 ${QT_VERSION} REQUIRED )

  set( QT_USE_QTOPENGL TRUE )
  set( QT_USE_QTNETWORK TRUE )
  set( QT_USE_QTUITOOLS TRUE )
  ##set( QT_USE_PHONON TRUE )
  ##set( QT_USE_QT3SUPPORT TRUE )
  set( QT_USE_QTTEST TRUE )
  include( ${QT_USE_FILE} )

elseif ( QT_VERSION_5 )

  # Requires CMake version 2.8.11 or above
##  cmake_policy( SET CMP0011 OLD )
  cmake_policy( SET CMP0020 NEW )
  # disable autolinking to qtmain as we have our own main() functions (new in Qt 5.1)
  if ( (${CMAKE_MAJOR_VERSION} EQUAL 2 OR ${CMAKE_MAJOR_VERSION} GREATER 2) AND
       (${CMAKE_MINOR_VERSION} EQUAL 8 OR ${CMAKE_MINOR_VERSION} GREATER 8) AND
        ${CMAKE_PATCH_VERSION} GREATER 10 )
    cmake_policy(SET CMP0020 OLD)
  endif()

  if ( WIN32 )
    add_definitions( -DWIN32 -D_WINDOWS ) ## Qt5 is screwing this up somehow
  endif()

  set( CMAKE_PREFIX_PATH ${QTDIR} )
  set( QT5_COMPONENTS
      Core
      Gui
      Widgets
      Network
      ## OpenGL
      UiTools
      CACHE STRING "List of Qt Components to link"
  )
  qt5_setup_components( QT5_COMPONENTS )

  set( CMAKE_AUTOMOC OFF )
  set( CMAKE_INCLUDE_CURRENT_DIR ON )
  set( CMAKE_POSITION_INDEPENDENT_CODE ON )

endif()

list(
    APPEND QT_DEFINITIONS
    QT_NO_KEYWORDS
    EXCLUDE_XHEADERS
)
