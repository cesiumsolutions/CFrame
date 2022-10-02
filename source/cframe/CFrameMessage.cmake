# -----------------------------------------------------------------------------
#
# Various general-purpose utility functions.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Message wrapper which checks verbosity level
# @param LEVEL The message level, @see CMake message
# @param VERBOSITY The verbosity associated with the messages
# @param MESSAGE The message
#
# Levels:
# - 0: No messages
# - 1: Essential messages
# - 2: More informational messages
# - 3: Debug messages
# - 4: Low level debug messages
# -----------------------------------------------------------------------------
set( CFRAME_VERBOSITY 4
    CACHE STRING
    "Verbosity level for CFrame messages: 0=off, 1=essential, higher=more"
)

function( cframe_message LEVEL VERBOSITY MESSAGE )
  if ( (${CFRAME_VERBOSITY} GREATER ${VERBOSITY}) OR
       (${CFRAME_VERBOSITY} EQUAL ${VERBOSITY}))
    message( ${LEVEL} "[${LEVEL}:${VERBOSITY}] " ${MESSAGE} )
  endif()
endfunction()
