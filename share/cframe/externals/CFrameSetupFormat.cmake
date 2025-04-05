# -----------------------------------------------------------------------------
# Set up the Format library for pre C++20
# @see: https://fmt.dev/latest/get-started/
#
# Usage:
# 
# target_link_libraries(<your-target> fmt::fmt)
# -----------------------------------------------------------------------------

if ( ${CMAKE_CXX_STANDARD} GREATER_EQUAL 20 )
  set( FORMAT_LIB "" )
  return()
endif()

cmake_minimum_required( VERSION 3.14 )

include( FetchContent )

FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt
  GIT_TAG        e69e5f977d458f2650bb346dadf2ad30c5320281 # 10.2.1
)

FetchContent_MakeAvailable(fmt)

set( FORMAT_LIB fmt::fmt )
