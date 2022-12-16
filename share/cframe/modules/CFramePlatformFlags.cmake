
# ---------------------------
# Set platform specific flags
# ---------------------------

if ( WIN32 )

  if ( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( CMAKE_MSVC_VCVARS_ARGS amd64 CACHE INTERNAL "Argument to vcvars.bat" )
  endif()

  # turn off dll-interface warning
  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /wd4251
      CACHE INTERNAL "Compile Options"
  )
  # turn off: non dll-interface struct '' used as base for dll-interface
  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /wd4275
      CACHE INTERNAL "Compile Options"
  )
  # turn off: "forcing value to bool" warning
  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /wd4800
      CACHE INTERNAL "Compile Options"
  )
  # turn off: unsafe use of type 'bool' in operation
  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS} /wd4804
      CACHE INTERNAL "Compile Options"
  )

  # prevent inclusion of superfluous windows files
  set(
      CFRAME_COMPILE_DEFINITIONS ${CFRAME_COMPILE_DEFINITIONS}
          WIN32_LEAN_AND_MEAN WIN32_EXTRA_LEAN
      CACHE INTERNAL "Compile Definitions"
  )
  # Calling any of the potentially unsafe methods in the C++ Standard Library
  # results in Compiler Warning (level 3) C4996. To disable this warning,
  # define the macro _SCL_SECURE_NO_WARNINGS in your code.
  set(
      CFRAME_COMPILE_DEFINITIONS ${CFRAME_COMPILE_DEFINITIONS}
          _SCL_SECURE_NO_WARNINGS
      CACHE INTERNAL "Compile Definitions"
  )
  # disable Min/Max macros
  set(
      CFRAME_COMPILE_DEFINITIONS ${CFRAME_COMPILE_DEFINITIONS}
          NOMINMAX
      CACHE INTERNAL "Compile Definitions"
  )

  set( BUILD_MAX_PROCESSES 4
      CACHE STRING
      "The maximum number of parallel proces ses to use for compiling."
  )
  list( APPEND CFRAME_COMPILE_OPTIONS "/MP${BUILD_MAX_PROCESSES}" )
  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS}
          "/MP${BUILD_MAX_PROCESSES}"
      CACHE INTERNAL "Compile Options"
  )

  option( BUILD_USE_PRECOMPILED_HEADERS
      "Set to ON to use precompiled headers." ON
  )

  set( BUILD_PCH_FACTOR 300
      CACHE STRING
      "The factor to use for allocating heap memory for precompiled headers."
  )
  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS}
          "/Zm${BUILD_PCH_FACTOR}"
      CACHE INTERNAL "Compile Options"
  )

else()

  set(
      CFRAME_COMPILE_OPTIONS ${CFRAME_COMPILE_OPTIONS}
          -Wno-unused-local-typedefs
      CACHE INTERNAL "Compile Options"
  )

endif()
