# -----------------------------------------------------------------------------
#
# Functions to retrieve and display Linux-specific system information
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Get Linux-specific distribution/release name and number
# -----------------------------------------------------------------------------
function( cframe_get_linux_release_info RELEASE_NAME RELEASE_VERSION )

  # From: https://stackoverflow.com/questions/26919334/detect-underlying-platform-flavour-in-cmake
  find_program( LSB_RELEASE_EXEC lsb_release )

  execute_process(
      COMMAND ${LSB_RELEASE_EXEC} -is
      OUTPUT_VARIABLE LSB_RELEASE_ID_SHORT
      OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set( ${RELEASE_NAME} ${LSB_RELEASE_ID_SHORT} PARENT_SCOPE )

  execute_process(
      COMMAND ${LSB_RELEASE_EXEC} -rs
      OUTPUT_VARIABLE LSB_RELEASE_VERSION_SHORT
      OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set( ${RELEASE_VERSION} ${LSB_RELEASE_VERSION_SHORT} PARENT_SCOPE )

endfunction() # cframe_get_linux_release_info

# -----------------------------------------------------------------------------
# Print Linux-specific Information
# -----------------------------------------------------------------------------
function( cframe_print_linux_system_info )

  if ( ARGC GREATER 0 )
    set( MESSAGE_MODE ${ARGV0} )
  else()
    set( MESSAGE_MODE STATUS )
  endif()

  cframe_get_linux_release_info( RELEASE_NAME RELEASE_VERSION )
  message( ${MESSAGE_MODE} "    Release Name:    ${RELEASE_NAME}" )
  message( ${MESSAGE_MODE} "    Release Version: ${RELEASE_VERSION}" )

endfunction() # cframe_print_linux_system_info
