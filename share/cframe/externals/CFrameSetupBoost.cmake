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
    "1.77" "1.77.0"
    "1.81" "1.81.0"
    "1.87" "1.87.0"
)

if ( WIN32 )

  if ( ${CMAKE_GENERATOR} STREQUAL "Visual Studio 17 2022" )
    set( BOOST_VERSION 1_87_0 CACHE STRING "Version of Boost" )
  elseif( ${CMAKE_GENERATOR} STREQUAL "Visual Studio 16 2019" )
    set( BOOST_VERSION 1_77_0 CACHE STRING "Version of Boost" )
  else()
    set( BOOST_VERSION 1_68_0 CACHE STRING "Version of Boost" )
  endif()

  if ( (NOT BOOST_ROOT) AND ((NOT BOOST_LIBRARYDIR) OR (NOT BOOST_INCLUDEDIR)) )
    cframe_search_paths(
        boost_${BOOST_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        BOOST_ROOT
    )

    if ( "${BOOST_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "Boost not found, set BOOST_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
    endif()
  endif()

endif()

if ( NOT BUILD_SHARED_LIBS )
  set(Boost_USE_STATIC_LIBS        ON)
  set(Boost_USE_MULTITHREADED      ON)
  set(Boost_USE_STATIC_RUNTIME     OFF)
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

list(
    APPEND Boost_DEFINITIONS
    BOOST_SIGNALS_NO_DEPRECATION_WARNING
    BOOST_SIGNALS_DEFAULT_VERSION=${BOOST_SIGNALS_DEFAULT_VERSION}
)

if ( BUILD_SHARED_LIBS )
  list(
      APPEND Boost_DEFINITIONS
      BOOST_ALL_DYN_LINK
  )
else()
  ##list(
  ##    APPEND Boost_DEFINITIONS
  ##    BOOST_ALL_NO_LIB
  ##)
endif()

# For some platforms (e.g. Ubuntu 11.10), some Boost libraries must be
# specified explicitly.
# Setting the Boost_ADD_LIBRARIES during cmake setup allows this to be done on
# a per-platform basis.
if ( Boost_ADD_LIBRARIES )
  list( APPEND Boost_LIBRARIES ${Boost_ADD_LIBRARIES} )
endif()
