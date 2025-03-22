# -----------------------------------------------------------------------------
#
# Initializes various settings related to C++
#
# -----------------------------------------------------------------------------

# ----------------------------------------
# Handle selection of C++ standard Version
# ----------------------------------------
set(
    CMAKE_CXX_STANDARD 17
    CACHE STRING "C++ Standard Version to use"
)
set_property(
    CACHE CMAKE_CXX_STANDARD
    PROPERTY STRINGS
        98 11 14 17 20 23 26
)

if ( WIN32 )
  # Set Compiler version. For Visual Studio, CXX_STANDARD doesn't work, have t0
  # explicitly set it.
  # See: https://developercommunity.visualstudio.com/content/problem/139261/msvc-incorrectly-defines-cplusplus.html
  if ( ${MSVC_VERSION} GREATER 1900  )
    if ( ${CMAKE_CXX_STANDARD} EQUAL 98 )
      set(
          CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /Zc:__cplusplus-
          CACHE INTERNAL "Compile Options"
      )
    elseif ( ${CMAKE_CXX_STANDARD} EQUAL 11 )
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

  if ( NOT ${CMAKE_CXX_STANDARD} EQUAL 98 )
    set(
	      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS}
		    -std=c++${CMAKE_CXX_STANDARD}
		    CACHE INTERNAL "Compile Options"
	)
  endif()

endif()
