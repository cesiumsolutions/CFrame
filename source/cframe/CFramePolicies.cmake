# -----------------------------------------------------------------------------
# Set up some policies
# TODO: Figure out a more modular/customizable way of doing this
# -----------------------------------------------------------------------------

# CMP0074: find_package() uses <PackageName>_ROOT variables.
cmake_policy( SET CMP0074 NEW )

set( CFRAME_CMAKE_POLICIES
    "CMP0074:NEW" # CMP0074: find_package() uses <PackageName>_ROOT variables.
    CACHE STRING "List of Policy names and values"
)

# TODO: Traverse CFRAME_CMAKE_POLICIES, split each entry on the colon and
# call cmake_policy()
# TODO: Make a function to automate this.
# function should accept separator, prefix (to prepend to variables), suffixes
# for multi-value entries
