# -----------------------------------------------------------------------------
#
# Various general-purpose utility functions.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Message wrapper which checks verbosity level
# @param MODE The message mode, @see CMake message
# @param VERBOSITY The verbosity associated with the messages
# @param MESSAGE The message
#
# Verbosity Levels suggested conventions:
# - 0: No messages
# - 1: Essential messages
# - 2: More informational messages
# - 3: Debug messages
# - 4: Low level debug messages
# -----------------------------------------------------------------------------
set( CFRAME_VERBOSITY 2
    CACHE STRING
    "Verbosity level for CFrame messages: 0=off, 1=essential, higher=more"
)

function( cframe_message )

  # Set up and parse multiple arguments
  set( options
  )
  set( oneValueArgs
      MODE
      VERBOSITY
  )
  set( multiValueArgs
      TAGS
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  # Set default values for missing or undefined parameters
  foreach( missing ${MY_INSTALL_KEYWORDS_MISSING_VALUES} )
    if ( ${missing} STREQUAL "MODE" )
      set( ARGS_MODE STATUS )
    elseif( ${missing} STREQUAL "VERBOSITY" )
      set( ARGS_VERBOSITY 2 )
    endif()
  endforeach()

  if ( NOT DEFINED ARGS_MODE )
    set( ARGS_MODE STATUS )
  endif()
  if ( NOT DEFINED ARGS_VERBOSITY )
    set( ARGS_VERBOSITY 1 )
  endif()

  # @todo Use TAGS to filter messages

  if ( ${CFRAME_VERBOSITY} GREATER_EQUAL ${ARGS_VERBOSITY} )
    message(
        ${ARGS_MODE}
        "[${ARGS_MODE}:${ARGS_VERBOSITY}] ${ARGS_UNPARSED_ARGUMENTS}"
    )
  endif()
endfunction()
