# -----------------------------------------------------------------------------
# -*-cmake-*- Saccades - Copyright (C) 2019-2022 Cesium Solutions
# This file is subject to the terms and conditions defined in the file
# 'SACCADES-LICENSE.txt', which is part of this source code package.
# -----------------------------------------------------------------------------

set( CATCH_ROOT "" CACHE PATH "Path to Catch 2 installation." )

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

if ( EXISTS "${CATCH_ROOT}" )

  set( Catch2_DIR ${CATCH_ROOT}/lib/cmake/Catch2/ )

  find_package( Catch2 )

  list( APPEND CMAKE_MODULE_PATH ${CATCH_ROOT}/lib/cmake/Catch2 )
  include( Catch )
  include( Catch2Targets )

else()
  message( SEND_ERROR
      "CATCH_ROOT is invalid, set it to the Catch2 installation directory"
  )
endif()
