# -----------------------------------------------------------------------------
# -*-cmake-*- Saccades - Copyright (C) 2019-2022 Cesium Solutions
# This file is subject to the terms and conditions defined in the file
# 'SACCADES-LICENSE.txt', which is part of this source code package.
# -----------------------------------------------------------------------------

set( CATCH_ROOT "" CACHE PATH "Path to Catch 2 installation." )

if ( EXISTS "${CATCH_ROOT}" )

  list( APPEND CMAKE_MODULE_PATH ${CATCH_ROOT}/lib/cmake/Catch2 )
  include( Catch )
  include( Catch2Targets )

else()
  message( SEND_ERROR
      "CATCH_ROOT is invalid, set it to the Catch2 installation directory"
  )
endif()
