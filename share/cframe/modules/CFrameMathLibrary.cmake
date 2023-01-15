# -----------------------------------------------------------------------------
#
# Initializes setting of CFRAME_MATH_LIBRARY
# @see https://cliutils.gitlab.io/modern-cmake/chapters/features/small.html
#
# -----------------------------------------------------------------------------

find_library( MATH_LIBRARY m )

if ( MATH_LIBRARY )
  set(
      CFRAME_MATH_LIBRARY ${MATH_LIBRARY}
      CACHE FILEPATH
      "Path to Math library."
  )
else()
  set(
      CFRAME_MATH_LIBRARY ""
      CACHE FILEPATH
      "Path to Math library."
  )
endif()
