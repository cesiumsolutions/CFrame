# -----------------------------------------------------------------------------
#
# Qt specialized setup
#
# -----------------------------------------------------------------------------

# Qt 5 convenience macros
macro( QT5_SETUP_COMPONENT COMPONENT )
  find_package( Qt5${COMPONENT} )
  list( APPEND QT_INCLUDES ${Qt5${COMPONENT}_INCLUDE_DIRS} )
  list( APPEND QT_DEFINTIONS ${Qt5${COMPONENT}_DEFINITIONS} )
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
    set( QT_VERSION 5.1.1 CACHE STRING "Qt Version")
  endif()
  string( SUBSTRING ${QT_VERSION} 0 1 QT_VERSION_MAJOR )
  string( COMPARE EQUAL ${QT_VERSION_MAJOR} "4" QT_VERSION_4 )
  string( COMPARE EQUAL ${QT_VERSION_MAJOR} "5" QT_VERSION_5 )

  if ( NOT ENV{QTDIR} AND NOT QTDIR )
    if ( OPENIGS_EXTERN_DIR )
      set( ENV{QTDIR} ${OPENIGS_EXTERN_DIR}/qt-everywhere-opensource-src-${QT_VERSION} )
      set( QTDIR ${OPENIGS_EXTERN_DIR}/qt-everywhere-opensource-src-${QT_VERSION} )
      set( QT_QMAKE_EXECUTABLE ${QTDIR}/bin/qmake )
    else()
      message( FATAL_ERROR "Neither QTDIR nor OPENIGS_EXTERN_DIR are set, set one of these appropriately." )
      return()
    endif()
  endif()

##  set( IGS_RUNTIME_DIRS
##       ${IGS_RUNTIME_DIRS}
##       ${QTDIR}/bin
##       ${QTDIR}/plugins
##       CACHE INTERNAL ""
##  )

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
  add_definitions(
      ${QT_DEFINITIONS}
      -DQT_NO_KEYWORDS
      -DEXCLUDE_XHEADERS
  )

elseif ( QT_VERSION_5 )

  if ( WIN32 )
    add_definitions( -DWIN32 -D_WINDOWS ) ## Qt5 is screwing this up somehow
  endif()

  set( CMAKE_PREFIX_PATH ${QTDIR} )
  set( QT5_COMPONENTS
      ${CFRAME_EXTERNAL_Qt_COMPONENTS}
  )

  qt5_setup_components( QT5_COMPONENTS )

  include_directories( ${QT_INCLUDES} )
  add_definitions(
      ${QT_DEFINITIONS}
      -DQT_NO_KEYWORDS
      -DEXCLUDE_XHEADERS
  )

  set( CMAKE_AUTOMOC OFF )
  set( CMAKE_INCLUDE_CURRENT_DIR ON )
  set( CMAKE_POSITION_INDEPENDENT_CODE ON )

endif()
