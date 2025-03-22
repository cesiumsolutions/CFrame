# -----------------------------------------------------------------------------
#
# Various List-based utility functions.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Join the list back into a string
# @param LIST The list to join
# @param GLUE The string to put between elements
# @param OUTPUT Variable where to store result
# @ref https://stackoverflow.com/questions/41416167/cmake-how-should-i-remove-duplicates-in-a-space-separated-list
# -----------------------------------------------------------------------------
function( cframe_list_join LIST GLUE OUTPUT )
  cframe_message( MODE STATUS VERBOSITY 4
      "CFrame: FUNCTION: cframe_list_join"
  )
  string( REGEX REPLACE "([^\\]|^);" "\\1${GLUE}" _TMP_STR "${LIST}" )
  string( REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}" ) #fixes escaping
  set( ${OUTPUT} "${_TMP_STR}" PARENT_SCOPE )
endfunction()

# -----------------------------------------------------------------------------
# Combine two lists represented as strings into a single list
# @param STRING1 The first list as a string
# @param STRING2 The second list as a string
# @param REMOVE_DUPLICATES Whether or not to remove duplicates
# @param SORT Whether or not to sort the resultant list
# @param RESULT Where to restore the result, which will be a string.
#
# It is surprisingly difficult to do this as lists can be represented as either
# a string with separated elements or as a true list.
#
# This merges two lists represented as strings and stores in the output as a LIST.
#
# The resulting list can be converted back to a string using cframe_list_join.
# -----------------------------------------------------------------------------
function( cframe_merge_list_strings STRING1 STRING2 REMOVE_DUPLICATES SORT RESULT )

  cframe_message( MODE STATUS VERBOSITY 4
      "CFrame: FUNCTION: cframe_merge_list_strings"
  )

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
function( cframe_list_remove_duplicates LIST_STR LIST_OUTPUT )
  cframe_message( MODE STATUS VERBOSITY 4
      "CFrame: FUNCTION: cframe_list_remove_duplicates"
  )
  set( LIST_INPUT ${LIST_STR} )
  separate_arguments( LIST_INPUT )
  list( REMOVE_DUPLICATES LIST_INPUT )
  string( REGEX REPLACE "([^\\]|^);" "\\1 " _TMP_STR "${LIST_INPUT}" )
  string( REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}" ) #fixes escaping
  set( ${LIST_OUTPUT} "${_TMP_STR}" PARENT_SCOPE )
endfunction()

# -----------------------------------------------------------------------------
# Separates list into multiple lists based on KEYWORDS.
# Defines variables named ${KEYWORD}${SUFFIX}, each of which contains a list of
# the values following that keyword in the ITEMS list.
# Any values that do not have precedent keywords (e.g. the first values), will
# be added to the first KEYWORD in the KEYWORDS list.
#
# For example:
# @code
#   set( KEYWORDS PUBLIC PRIVATE INTERFACE )
#   set( ITEMS item0 PUBLIC item1 item2 PRIVATE item3 item4 INTERFACE item5 )
#
#   # NOTE: Be sure to put double-quotes around variables to ensure separate
#   # lists are passed!!
#   cframe_list_mapify( "${KEYWORDS}" "${ITEMS}" _VALUES )
# @endcode
#
# Will result in the following variables and values being set:
# - PUBLIC_VALUES:    item0;item1;item2
# - PRIVATE_VALUES:   item3;item4
# - INTERFACE_VALUES: item5
#
# @param KEYWORDS List of keys to split up ITEMS list.
# @param ITEMS The list of items to split up.
# @param SUFFIX The string to append to end of KEYWORD variable for values.
# @return Defines a set of variables with names ${KEYWORD}_${SUFFIX} each of which
# have the values of that list
# -----------------------------------------------------------------------------
function( cframe_list_mapify KEYWORDS ITEMS SUFFIX )

  list( LENGTH KEYWORDS NUM_KEYWORDS )
  if ( NUM_KEYWORDS EQUAL 0 )
    return()
  endif()

  list( LENGTH ITEMS NUM_ITEMS )
  if ( NUM_ITEMS EQUAL 0 )
    return()
  endif()

  # Set the first KEYWORD as the default
  list( GET KEYWORDS 0 KEYWORD )

  foreach( ITEM ${ITEMS} )

    list( FIND KEYWORDS ${ITEM} KEYWORD_INDEX )
    if ( KEYWORD_INDEX EQUAL -1 )
      # Add to current KEYWORD's list
      list( APPEND ${KEYWORD}${SUFFIX}_INTERN ${ITEM} )
    else()
      # Update current KEYWORD
      set( KEYWORD ${ITEM} )
    endif()

  endforeach()

  foreach( KEYWORD ${KEYWORDS} )
    set( ${KEYWORD}${SUFFIX} ${${KEYWORD}${SUFFIX}_INTERN} PARENT_SCOPE )
  endforeach() # KEYWORDS

endfunction() # cframe_list_mapify

function( test_cframe_list_mapify )

  cframe_message(
      MODE STATUS VERBOSITY 2
      "test_cframe_list_mapify()"
  )

  set( KEYWORDS PUBLIC PRIVATE INTERFACE )
  set( ITEMS item0 PUBLIC item1 item2 PRIVATE item3 item4 INTERFACE )

  cframe_list_mapify( "${KEYWORDS}" "${ITEMS}" _VALUES )

  foreach( KEYWORD ${KEYWORDS} )
    cframe_message(
        MODE STATUS VERBOSITY 3
        "${KEYWORD}_VALUES: ${${KEYWORD}_VALUES}"
    )
  endforeach()

  set( SUCCESS TRUE )
  if ( NOT "${PUBLIC_VALUES}" STREQUAL "item0;item1;item2" )
    cframe_message(
        MODE SEND_ERROR VERBOSITY 3
        "test_cframe_list_mapify: PUBLIC_VALUES"
    )
    set( SUCCESS FALSE )
  endif()
  if ( NOT "${PRIVATE_VALUES}" STREQUAL "item3;item4" )
    cframe_message(
        MODE SEND_ERROR VERBOSITY 3
        "test_cframe_list_mapify: PRIVATE_VALUES"
    )
    set( SUCCESS FALSE )
  endif()
  if ( NOT "${INTERFACE_VALUES}" STREQUAL "" )
    cframe_message(
        MODE SEND_ERROR VERBOSITY 3
        "test_cframe_list_mapify: INTERFACE_VALUES"
    )
    set( SUCCESS FALSE )
  endif()

  if ( SUCCESS )
    cframe_message(
        MODE STATUS VERBOSITY 2
        "test_cframe_list_mapify: SUCCEEDED"
    )
  else()
    cframe_message(
        MODE STATUS VERBOSITY 2
        "test_cframe_list_mapify: FAILED"
    )
  endif()

endfunction() # test_cframe_list_mapify

if ( CFRAME_RUN_TESTS )
  test_cframe_list_mapify()
endif()

# Parse a flat list with items containing name-value pairs split by a separator
# (with no spaces).
# A list of value names is provided in the OUTPUT_VARS variable and the values
# are stored in variables named ${PREFIX}${VARNAME}_${VARVALUE}${SUFFIX}
# A list of suffixes specifies the suffixes for multivalue variables.
# If there are more values than provided suffixes, the last suffix will be a list
# of the remaining values.
# If there are less values than provided suffixes, the leftover PREFIX+NAME+SUFFIX
# will not be defined.
# If no suffixes are provided, the default is _VALUES.
#
# For example:
#
# cframe_parse_list_to_key_values(
#    ITEMS "A:ayy:0" "B:bee:1" "C:see:2"
#    SEPARATOR ":"
#    PREFIX "LETTER_"
#    SUFFIXES "_SOUND" "_INDEX"
#    OUTPUT_VAR_LIST LETTER_VARS
# )
#
# Will result in the following:
# LETTER_VARS = A, B, C
# LETTER_A_SOUND = ayy
# LETTER_A_INDEX = 0
# LETTER_B_SOUND = bee
# LETTER_B_INDEX = 1
# LETTER_C_SOUND = see
# LETTER_C_INDEX = 2
#
# And could be processed as such:
#
# foreach( LETTER ${LETTER_VARS} )
#    message(
#        "Letter ${LETTER} sounds like ${${LETTER}_SOUND}"
#        " and is index ${${LETTER}_INDEX} in the alphabet" )
# endforeach()
#
# See:
# https://stackoverflow.com/questions/70099620/cmake-string-to-get-key-value-pairs-from-a-string-list-containing-key-values-sep
function( cframe_parse_list_to_key_values )

  set( options
  )
  set( oneValueArgs
       PREFIX
       SEPARATOR
       OUTPUT_VAR_LIST
  )
  set( multiValueArgs
       ITEMS
       SUFFIXES
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  # TODO: Implement


endfunction() # cframe_parse_list_to_key_values

function( test_cframe_parse_list_to_key_values )

  cframe_parse_list_to_key_values(
    ITEMS "A:ayy:0" "B:bee:1" "C:see:2"
    SEPARATOR ":"
    PREFIX "LETTER_"
    SUFFIXES "_SOUND" "_INDEX"
    OUTPUT_VAR_LIST LETTER_VARS
  )

  foreach( LETTER ${LETTER_VARS} )
    cframe_message(
        MODE STATUS VERBOSITY 3
        "Letter ${LETTER} sounds like ${${LETTER}_SOUND}"
        " and is index ${${LETTER}_INDEX} in the alphabet" )
  endforeach()

  set( SUCCESS TRUE )
  if ( NOT "${LETTER_VARS}" STREQUAL "A;B;C" )
    cframe_message(
        MODE SEND_ERROR VERBOSITY 3
        "cframe_parse_list_to_key_values: LETTER_VARS"
    )
    set( SUCCESS FALSE )
  endif()

  if ( NOT "${LETTER_A_SOUND}" STREQUAL "ayy" )
    cframe_message(
        MODE SEND_ERROR VERBOSITY 3
        "cframe_parse_list_to_key_values: LETTER_A_SOUND"
    )
    set( SUCCESS FALSE )
  endif()
  if ( NOT "${LETTER_A_INDEX}" STREQUAL "0" )
    cframe_message(
        MODE SEND_ERROR VERBOSITY 3
        "cframe_parse_list_to_key_values: LETTER_A_INDEX"
    )
    set( SUCCESS FALSE )
  endif()

  if ( SUCCESS )
    cframe_message(
        MODE STATUS VERBOSITY 2
        "cframe_parse_list_to_key_values: SUCCEEDED"
    )
  else()
    cframe_message(
        MODE STATUS VERBOSITY 2
        "cframe_parse_list_to_key_values: FAILED"
    )
  endif()


endfunction() # cframe_parse_list_to_key_values

if ( CFRAME_RUN_TESTS )
  test_cframe_parse_list_to_key_values()
endif()


# From: https://stackoverflow.com/questions/24491129/excluding-directory-somewhere-in-file-structure-from-cmake-sourcefile-list
# Remove strings matching given regular expression from a list.
# @param items (in,out) aItems Reference of a list variable to filter.
# @param filterRegEx Value of regular expression to match.
function( cframe_filter_list items filterRegEx )
    # For each item in our list
    foreach( item ${${items}} )
        # Check if our items matches our regular expression
        if ( "${item}" MATCHES ${filterRegEx} )
            # Remove current item from our list
            list( REMOVE_ITEM ${items} ${item} )
        endif ()
    endforeach()
    # Provide output parameter
    set( ${items} ${${items}} PARENT_SCOPE )
endfunction()
