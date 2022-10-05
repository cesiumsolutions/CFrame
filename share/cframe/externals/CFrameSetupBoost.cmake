# --------------------
# Set up Boost package
# --------------------

option( Boost_USE_MULTITHREADED "Use the multithreaded versions of Boost libraries." ON )
set( Boost_ADDITIONAL_VERSIONS
    "1.42" "1.42.0"
    "1.47" "1.47.0"
    "1.48" "1.48.0"
    "1.49" "1.49.0"
    "1.55" "1.55.0"
    "1.58" "1.58.0"
    "1.62" "1.62.0"
    "1.68" "1.68.0"
    "1.71" "1.71.0"
    "1.72" "1.72.0"
)

if ( WIN32 )

  if ( ${CMAKE_GENERATOR} STREQUAL "Visual Studio 16 2019" )
    set( BOOST_VERSION 1_71_0 CACHE STRING "Version of Boost" )
  else()
    set( BOOST_VERSION 1_68_0 CACHE STRING "Version of Boost" )
  endif()

  if ( (NOT BOOST_ROOT) AND ((NOT BOOST_LIBRARYDIR) OR (NOT BOOST_INCLUDEDIR)) )
    if ( CFRAME_EXTERN_DIR )
      set( BOOST_ROOT ${CFRAME_EXTERN_DIR}/boost_${BOOST_VERSION}
           CACHE PATH "Boost directory." )
    endif()
  endif()

  # Append to this variable which will be used to configure startup scripts
  set( IGS_RUNTIME_DIRS ${IGS_RUNTIME_DIRS} ${BOOST_ROOT}/lib CACHE INTERNAL "" )

endif()

add_definitions( -DBOOST_SIGNALS_NO_DEPRECATION_WARNING )
if ( BUILD_SHARED_LIBS )
  add_definitions( -DBOOST_ALL_DYN_LINK )
else()
  set(Boost_USE_STATIC_LIBS        ON)
  set(Boost_USE_MULTITHREADED      ON)
  set(Boost_USE_STATIC_RUNTIME     OFF)
####  add_definitions( -DBOOST_ALL_NO_LIB )
endif()

# Do initial search for Boost package to determine the actual
# version found.
# If the BOOST_VERSION is not explicitly specified (e.g. on Linux)
# then this call will provide the actual version available in the
# Boost_VERSION variable.
find_package( Boost REQUIRED )

set( BOOST_COMPONENTS
    date_time
    filesystem
    graph
    iostreams
    program_options
    regex
    serialization
    system
    thread
    unit_test_framework
    CACHE STRING "Boost components to link with"
)

# On Mac, the Boost_VERSION is reported back as, e.g. 1.71.0,
# Whereas on Linux/Windows it is reported back as 107100.
# So have to transform the Mac string into something compatible.
# Although this isn't the best way to do it (but works for now),
# just replace the '.' characters with '0'
string( REPLACE . 0 Boost_VERSION "${Boost_VERSION}" )

# As of version 1.69.0, Boost.Signals is header only. So only add
# the signals component for earlier versions.
if ( "${Boost_VERSION}" LESS 106900 )

  list( APPEND BOOST_COMPONENTS signals )

  # BOOST_SIGNALS_DEFAULT_VERSION used To support easily switching between
  # Boost.Signals version.
  set(
      BOOST_SIGNALS_DEFAULT_VERSION 2
      CACHE STRING
      "The default Boost.Signals version to use(1 or 2, default 1)"
  )
  set_property(
      CACHE BOOST_SIGNALS_DEFAULT_VERSION
      PROPERTY
          STRINGS 1 2
  )

else() # Boost_VERSION >= 106900

  # For later Boost versions, Signals version is not selectable
  set( BOOST_SIGNALS_DEFAULT_VERSION 2 )

endif()

# See https://stackoverflow.com/questions/57415206/is-there-a-way-to-get-rid-of-the-new-boost-version-may-have-incorrect-or-missin
set( Boost_NO_WARN_NEW_VERSIONS 1 )

find_package( Boost REQUIRED
    ${BOOST_COMPONENTS}
)

include_directories( ${Boost_INCLUDE_DIR} )
link_directories( ${Boost_LIBRARY_DIRS} )


add_definitions(
   -DBOOST_SIGNALS_DEFAULT_VERSION=${BOOST_SIGNALS_DEFAULT_VERSION}
)

# For some platforms (e.g. Ubuntu 11.10), some Boost libraries must be
# specified explicitly.
# Setting the Boost_ADD_LIBRARIES during cmake setup allows this to be done on
# a per-platform basis.
if ( Boost_ADD_LIBRARIES )
  list( APPEND Boost_LIBRARIES ${Boost_ADD_LIBRARIES} )
endif()

