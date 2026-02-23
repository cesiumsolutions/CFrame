# -----------------
# Set up SDL2 stuff
# -----------------

if ( WIN32 )
  if ( NOT SDL2_VERSION )
    set( SDL2_VERSION 2.32.8 CACHE STRING "SDL2 Version" )
  endif()

  if ( NOT SDL2DIR )

    cframe_search_paths(
        SDL2-${SDL2_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        SDL2DIR
    )

  endif()

  ##set( ENV{PKG_CONFIG_PATH}
  ##    "$ENV{PKG_CONFIG_PATH}:${SDL2DIR}/lib/pkgconfig" )
  ##find_package( PkgConfig REQUIRED )
  ##pkg_check_modules( SDL2 REQUIRED IMPORTED_TARGET sdl3 )

  set( CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${SDL2DIR}/cmake )
  find_package(
     SDL2 ${SDL2_VERSION}
     REQUIRED
     PATHS
         ${SDL2DIR}
  )

  # Package Configuration files for SDL2 may not be properly set up, so
  # manually set the include and library paths
  set( SDL2_INCLUDE_DIRS ${SDL2DIR}/include )
  set( SDL2_LIBRARY_DIR ${SDL2DIR}/lib )
  set( SDL2_LIBRARIES optimized SDL2 debug SDL2d )
else()

  find_package( SDL2 REQUIRED )

endif()

#message( STATUS "SDL2 found in:     ${SDL2DIR}" )
message( STATUS "SDL2 version:      ${SDL_VERSION}" )
message( STATUS "SDL2 library dir:  ${SDL2_LIBRARY_DIR}" )
message( STATUS "SDL2 include dirs: ${SDL2_INCLUDE_DIRS}" )
message( STATUS "SDL2 libraries:    ${SDL2_LIBRARIES}" )

