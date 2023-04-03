# -----------------------------------------------------------------------------
#
# Functions to retrieve and display Windows-specific system information
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Print Windows-specific System Information
# -----------------------------------------------------------------------------
function( cframe_print_windows_system_info )

  if ( ARGC GREATER 0 )
    set( MESSAGE_MODE ${ARGV0} )
  else()
    set( MESSAGE_MODE STATUS )
  endif()

  message(
      ${MESSAGE_MODE}
      "    CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION:"
      " ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}"
  )
endfunction()
