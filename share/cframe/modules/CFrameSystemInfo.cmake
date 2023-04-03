# -----------------------------------------------------------------------------
#
# Functions to retrieve and display system information.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Print System Information
# -----------------------------------------------------------------------------
function( cframe_print_system_info )

  if ( ARGC GREATER 0 )
    set( MESSAGE_MODE ${ARGV0} )
  else()
    set( MESSAGE_MODE STATUS )
  endif()

  message( ${MESSAGE_MODE} "System Info:" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM:           ${CMAKE_SYSTEM}" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM_NAME:      ${CMAKE_SYSTEM_NAME}" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM_VERSION:   ${CMAKE_SYSTEM_VERSION}" )
  message( ${MESSAGE_MODE} "    CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}" )
  message( ${MESSAGE_MODE} "    CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}" )

  get_filename_component( currListFile ${CMAKE_CURRENT_LIST_FILE} NAME_WLE )
  if ( EXISTS ${CMAKE_CURRENT_LIST_DIR}/detail/${currListFile}-${CMAKE_SYSTEM_NAME}.cmake )
    include( ${CMAKE_CURRENT_LIST_DIR}/detail/${currListFile}-${CMAKE_SYSTEM_NAME}.cmake )

    if ( COMMAND cframe_print_${CMAKE_SYSTEM_NAME}_system_info )
      cmake_language(
          CALL "cframe_print_${CMAKE_SYSTEM_NAME}_system_info" ${MESSAGE_MODE}
      )
    endif()
  endif()

endfunction() # cframe_print_system_info

if ( CFRAME_RUN_TESTS )
  cframe_print_system_info( )
endif()
