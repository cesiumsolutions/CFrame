
# ---------------------------
# Set platform specific flags
# ---------------------------

if ( WIN32 )

  if ( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( CMAKE_MSVC_VCVARS_ARGS amd64 CACHE INTERNAL "Argument to vcvars.bat" )
  endif()

  add_definitions( -DNOMINMAX )

  # turn off dll-interface warning
  add_definitions( "/wd4251" )
  # turn off: non dll-interface struct '' used as base for dll-interface
  add_definitions( "/wd4275" )
  # turn off: "forcing value to bool" warning
  add_definitions( "/wd4800" )
  # turn off: unsafe use of type 'bool' in operation
  add_definitions( "/wd4804" )
  # prevent inclusion of superfluous windows file
  add_definitions( "-DWIN32_LEAN_AND_MEAN" "-DWIN32_EXTRA_LEAN" )
  # disable warning 4996: Function call with parameters that may be unsafe
  add_definitions( "-D_SCL_SECURE_NO_WARNINGS" )

  set( BUILD_MAX_PROCESSES 4
      CACHE STRING
      "The maximum number of parallel proces ses to use for compiling."
  )
  option( BUILD_USE_PRECOMPILED_HEADERS
      "Set to ON to use precompiled headers." ON
  )
  set( BUILD_PCH_FACTOR 300
      CACHE STRING
      "The factor to use for allocating heap memory for precompiled headers."
  )

  if ( BUILD_MAX_PROCESSES )
    list( APPEND CFRAME_COMPILEFLAGS "/MP${BUILD_MAX_PROCESSES}" )
  else()
    list( APPEND CFRAME_COMPILEFLAGS "/MP2" )
  endif()

  set( CFRAME_COMPILEFLAGS
      "${CFRAME_COMPILEFLAGS} /bigobj /Zm${BUILD_PCH_FACTOR} /EHsc"
  )

else()

  list( APPEND CFRAME_COMPILEFLAGS "-fPIC -Wno-unused-local-typedefs" )

endif()
