# --------------------------
# Set up NetCDF dependency
# --------------------------

if ( WIN32 )

  if ( NOT netCDF_DIR )
    message(
        FATAL_ERROR
	"netCDF_DIR not set. Set it to location of NetCDF installation lib/cmake directory."
    )
    return()
  endif()

  list( APPEND CMAKE_PREFIX_PATH ${netCDF_DIR} )

endif()

find_package( netCDF )

# HACK for Windows to remove hardcoded interface dependencies to zlib and curl
if ( WIN32 )
  get_target_property( TARGET_LIBRARIES ${netCDF_LIBRARIES} INTERFACE_LINK_LIBRARIES )
  list( REMOVE_ITEM TARGET_LIBRARIES C:/share/VS15/x64/lib/zlib.lib )
  list( REMOVE_ITEM TARGET_LIBRARIES C:/share/VS15/x64/lib/libcurl_imp.lib )
  set_property( TARGET ${netCDF_LIBRARIES} PROPERTY INTERFACE_LINK_LIBRARIES ${TARGET_LIBRARIES} )
endif()
