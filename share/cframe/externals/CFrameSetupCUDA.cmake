# --------------------------
# Set up CUDA dependency
# --------------------------

# Based on: https://cliutils.gitlab.io/modern-cmake/chapters/packages/CUDA.html
include( CheckLanguage )
check_language( CUDA )

if ( NOT CMAKE_CUDA_COMPILER )
  message( FATAL_ERROR
      "CUDA not available, exiting..."
  )
endif()

enable_language( CUDA )

find_package( CUDA )
