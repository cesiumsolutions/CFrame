# ---------------------------------------
# Set up PNG stuff
# ---------------------------------------

if ( WIN32 )

  if ( NOT PNG_VERSION )
    set( PNG_VERSION_STRING 1.6.37 CACHE STRING "PNG Version" )
  endif()

  if ( NOT PNG_ROOT )
    if ( (NOT "${CFRAME_EXTERN_DIR}" STREQUAL "") AND
         (EXISTS "${CFRAME_EXTERN_DIR}/libpng-${PNG_VERSION_STRING}") )
      set( PNG_ROOT ${CFRAME_EXTERN_DIR}/libpng-${PNG_VERSION_STRING} )
    else()
      message(
          FATAL_ERROR
          "Either PNG_ROOT or CFRAME_EXTERN_DIR are not set, or directory does not exist. Check installation."
      )
      return()
    endif()
  endif()

  # These have to be hardcoded for some reason, kind of useless if you have to specify everything before find_package can find it for you
  set( PNG_LIBRARY ${PNG_ROOT}/lib/libpng14.lib )
  set( PNG_PNG_INCLUDE_DIR ${PNG_ROOT}/include )
  find_package( PNG REQUIRED )

  ## include_directories( ${PNG_INCLUDE_DIRS} )

endif()

