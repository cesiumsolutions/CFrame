# -----------------
# Set up SDL3 stuff
# -----------------

if ( WIN32 )
  if ( NOT SDL3_VERSION )
    set( SDL3_VERSION 3.4.2 CACHE STRING "SDL Version" )
  endif()

  if ( NOT SDL3DIR )

    cframe_search_paths(
        SDL3-${SDL3_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        SDL3DIR
    )

  endif()

  ##set( ENV{PKG_CONFIG_PATH}
  ##    "$ENV{PKG_CONFIG_PATH}:${SDL3DIR}/lib/pkgconfig" )
  ##find_package( PkgConfig REQUIRED )
  ##pkg_check_modules( SDL3 REQUIRED IMPORTED_TARGET sdl3 )

  #set( CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${SDL3DIR} )
  find_package(
     SDL3 ${SDL3_VERSION}
     REQUIRED
     PATHS
         ${SDL3DIR}
  )

  # Package Configuration files for SDL3 may not be properly set up, so
  # manually set the include and library paths
  set( SDL3_INCLUDE_DIRS ${SDL3DIR}/include )
  set( SDL3_LIBRARY_DIR ${SDL3DIR}/lib )
  set( SDL3_LIBRARIES optimized SDL3 debug SDL3d )
else()

  find_package( SDL3 REQUIRED )

endif()

#message( STATUS "SDL3 found in:     ${SDL3DIR}" )
message( STATUS "SDL3 version:      ${SDL_VERSION}" )
message( STATUS "SDL3 library dir:  ${SDL3_LIBRARY_DIR}" )
message( STATUS "SDL3 include dirs: ${SDL3_INCLUDE_DIRS}" )
message( STATUS "SDL3 libraries:    ${SDL3_LIBRARIES}" )

