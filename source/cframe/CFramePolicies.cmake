# -----------------------------------------------------------------------------
# Set up some policies
# TODO: Figure out a more modular/customizable way of doing this
# -----------------------------------------------------------------------------

macro( cframe_init_policies )

  # CMP0074: find_package() uses <PackageName>_ROOT variables.
  cmake_policy( SET CMP0074 NEW )

  # ``install(SCRIPT)`` did not evaluate generator expressions.  CMake 3.14
  # and later will evaluate generator expressions for ``install(CODE)`` and
  #``install(SCRIPT)``.
  # The ``OLD`` behavior of this policy is for ``install(CODE)`` and
  # ``install(SCRIPT)`` to not evaluate generator expressions.  The ``NEW``
  # behavior is to evaluate generator expressions for ``install(CODE)`` and
  # ``install(SCRIPT)``.
  if ( POLICY CMP0087 )
    cmake_policy( SET CMP0087 NEW )
  endif()

  set( CFRAME_CMAKE_POLICIES
      "CMP0074:NEW" # CMP0074: find_package() uses <PackageName>_ROOT variables.
      "CMP0087:NEW" # CMP0087: install(SCRIPT) evaluates generator expressions.
      CACHE STRING "List of Policy names and values"
  )

endmacro() # cframe_init_policies

# TODO: Traverse CFRAME_CMAKE_POLICIES, split each entry on the colon and
# call cmake_policy()
# TODO: Make a function to automate this.
# function should accept separator, prefix (to prepend to variables), suffixes
# for multi-value entries
