# -----------------------------------------------------------------------------
# Set up the Microsoft C++ Guideline Support Library
# @see: https://github.com/Microsoft/GSL
#
# Usage:
# 
# target_link_libraries(foobar PRIVATE Microsoft.GSL::GSL)
# -----------------------------------------------------------------------------

cmake_minimum_required( VERSION 3.14 )

include( FetchContent )

set(
  MICROSOFT_GSL_VERSION "4.2.0"
  CACHE STRING "Version of the Microsoft GSL to use."
)

FetchContent_Declare(
    GSL
    GIT_REPOSITORY "https://github.com/microsoft/GSL"
    GIT_TAG "v${MICROSOFT_GSL_VERSION}"
    GIT_SHALLOW ON
)

FetchContent_MakeAvailable( GSL )
