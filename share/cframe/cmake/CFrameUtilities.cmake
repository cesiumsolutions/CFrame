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

# -----------------------------------------------------------------------------
# Join the list back into a string
# @param LIST The list to join
# @param GLUE The string to put between elements
# @param OUTPUT Variable where to store result
# @ref https://stackoverflow.com/questions/41416167/cmake-how-should-i-remove-duplicates-in-a-space-separated-list
# -----------------------------------------------------------------------------
function(cframe_list_join LIST GLUE OUTPUT)
  cframe_message( STATUS 4 "CFrame: FUNCTION: cframe_list_join" )
  string( REGEX REPLACE "([^\\]|^);" "\\1${GLUE}" _TMP_STR "${LIST}" )
  string( REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}" ) #fixes escaping
  set( ${OUTPUT} "${_TMP_STR}" PARENT_SCOPE )
endfunction()

# -----------------------------------------------------------------------------
# Combine too lists represented as strings into a single list
# @param STRING1 The first list as a string
# @param STRING2 The second list as a string
# @param REMOVE_DUPLICATES Whether or not to remove duplicates
# @param SORT Whether or not to sort the resultant list
# @param RESULT Where to restore the result, which will be a string.
# It is surprisingly difficult to do this as lists can be represented as either
# a string with separated elements or as a true list.
# This merges two lists represented as strings and stores in the output as a LIST.
# This does not remove duplicates, which can be done by using the standard
# cmake list(REMOVE_DUPLICATES ...) command.
# The resulting list can be converted back to a string using cframe_list_join.
# -----------------------------------------------------------------------------
function( cframe_merge_list_strings STRING1 STRING2 REMOVE_DUPLICATES SORT RESULT)

  cframe_message( STATUS 4 "CFrame: FUNCTION: cframe_merge_list_strings" )

  # Just append the strings with a space between them
  set( LIST "${STRING1} ${STRING2}" )
  separate_arguments( LIST )

  if ( ${REMOVE_DUPLICATES} )
    list( REMOVE_DUPLICATES LIST )
  endif()
  if ( ${SORT} )
    list( SORT LIST )
  endif()

  set( ${RESULT} ${LIST} PARENT_SCOPE )

endfunction()

# -----------------------------------------------------------------------------
# Remove all duplicates
# @param LIST_STR The list in the form of a string
# @param LIST_OUTPUT Variable to store result
# @ref https://stackoverflow.com/questions/41416167/cmake-how-should-i-remove-duplicates-in-a-space-separated-list
# -----------------------------------------------------------------------------
function( cframe_list_remove_duplicates LIST_STR LIST_OUTPUT)
  cframe_message( STATUS 4 "CFrame: FUNCTION: cframe_list_remove_duplicates" )
  set( LIST_INPUT ${LIST_STR} )
  separate_arguments( LIST_INPUT )
  list( REMOVE_DUPLICATES LIST_INPUT )
  string( REGEX REPLACE "([^\\]|^);" "\\1 " _TMP_STR "${LIST_INPUT}" )
  string( REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}" ) #fixes escaping
  set( ${LIST_OUTPUT} "${_TMP_STR}" PARENT_SCOPE )
endfunction()
