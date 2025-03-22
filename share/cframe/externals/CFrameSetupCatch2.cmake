# -----------------------------------------------------------------------------
# -*-cmake-*- Saccades - Copyright (C) 2019-2022 Cesium Solutions
# This file is subject to the terms and conditions defined in the file
# 'SACCADES-LICENSE.txt', which is part of this source code package.
# -----------------------------------------------------------------------------

set( CATCH_ROOT "" CACHE PATH "Path to Catch 2 installation." )

if ( WIN32 )

  if ( "${CATCH_ROOT}" STREQUAL "" )

    cframe_search_paths(
        Catch2
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        CATCH_ROOT
    )

    if ( "${CATCH_ROOT}" STREQUAL "" )
      message(
          FATAL_ERROR
          "Catch2 Not found, set CATCH_ROOT or CFRAME_EXTERN_SEARCH_PATHS"
      )
      return()
    endif()

  endif()

else()

  find_package( Catch2 )

endif() # Not WIN32

if ( EXISTS "${CATCH_ROOT}" )

  list( APPEND CMAKE_MODULE_PATH ${CATCH_ROOT}/lib/cmake/Catch2 )
  include( Catch )
  include( Catch2Targets )

else()
  message( SEND_ERROR
      "CATCH_ROOT is invalid, set it to the Catch2 installation directory"
  )
endif()
