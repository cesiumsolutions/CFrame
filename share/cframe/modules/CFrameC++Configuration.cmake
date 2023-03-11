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

if ( WIN32 )
  # Set Compiler version. For Visual Studio, CXX_STANDARD doesn't work, have t0
  # explicitly set it.
  # See: https://developercommunity.visualstudio.com/content/problem/139261/msvc-incorrectly-defines-cplusplus.html
  if ( ${MSVC_VERSION} GREATER 1900  )
    if ( ${CFRAME_CXX_STANDARD} EQUAL 97 )
      set(
          CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /Zc:__cplusplus-
          CACHE INTERNAL "Compile Options"
      )
    elseif ( ${CFRAME_CXX_STANDARD} EQUAL 11 )
      set(
          CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /Zc:__cplusplus
          CACHE INTERNAL "Compile Options"
      )
    else()
      set(
          CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS}
              /std:c++${CMAKE_CXX_STANDARD} /Zc:__cplusplus
          CACHE INTERNAL "Compile Options"
      )
    endif()
  endif()

else()

  if ( NOT ${CFRAME_CXX_STANDARD} EQUAL 97 )
    set(
	    CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS}
		    -std=c++${CFRAME_CXX_STANDARD}
		CACHE INTERNAL "Compile Options"
	)
  endif()

endif()
