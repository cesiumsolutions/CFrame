# -----------------------------------------------------------------------------
#
# Initializes various settings related to C++
#
# -----------------------------------------------------------------------------

# ----------------------------------------
# Handle selection of C++ standard Version
# ----------------------------------------
set(
    CFRAME_CXX_STANDARD 14
    CACHE STRING "C++ Standard Version to use"
)
set_property(
    CACHE CFRAME_CXX_STANDARD
    PROPERTY STRINGS
        97 11 14 17 20
)
if ( NOT ${CFRAME_CXX_STANDARD} EQUAL 97 )
  set( CMAKE_CXX_STANDARD ${CFRAME_CXX_STANDARD} )
endif()
