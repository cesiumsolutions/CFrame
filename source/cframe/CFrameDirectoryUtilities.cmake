# -----------------------------------------------------------------------------
#
# Contains functions for operating on directories
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# @brief Returns the relative path of all the files relative to specified
# directory
# @param directory [in] The directory to get relative path to
# @param files [in] List of files to determine relative path
# @return outVar
# -----------------------------------------------------------------------------
function( cframe_files_relative_paths outVar directory files )

  foreach( file ${files} )
    file( RELATIVE_PATH relPath ${directory} ${file} )
    list( APPEND relPaths ${relPath} )
  endforeach()

  set( ${outVar} ${relPaths} PARENT_SCOPE )
endfunction() # cframe_files_relative_paths

# -----------------------------------------------------------------------------
# Implementation part for cframe_search_subdirs for directories
# -----------------------------------------------------------------------------

function(
    cframe_search_subdir_impl
    dir filter recurseMode maxResults outResults
)

  set( localOutVar ${${outResults}} )

  file(
    GLOB children
    RELATIVE ${dir}
    ${dir}/*
  )

  set( files "" )
  set( dirs "" )
  foreach( child ${children} )
    if ( IS_DIRECTORY ${dir}/${child} )
      list( APPEND dirs ${dir}/${child} )
    else()
      list( APPEND files ${child} )
    endif()
  endforeach()

  # Process files
  set( matchFound OFF )
  foreach( file ${files} )
    string( REGEX MATCH ${filter} matchResult ${file} )
    if ( NOT "${matchResult}" STREQUAL "" )
      set( matchFound ON )
      set( localOutVar ${localOutVar} ${dir}/${file} )
      set( ${outResults} ${localOutVar} PARENT_SCOPE )

      if ( ${maxResults} GREATER 0 )
        list( LENGTH localOutVar currentLength )
        if ( currentLength GREATER_EQUAL ${maxResults} )
          return()
        endif() # max results reached
      endif() # limited results
    endif() # Filter matched

  endforeach() # files

  # Check and traverse subdirs
  if ( ${recurseMode} STREQUAL "OFF" )
    return()
  endif()

  if ( ${matchFound} AND ( ${recurseMode} STREQUAL "UNTIL_FOUND" ) )
    return()
  endif()

  foreach( dir ${dirs} )
    cframe_search_subdir_impl(
        ${dir}/${child} ${filter} ${recurseMode} ${maxResults} localOutVar
    )
  endforeach()

  set( ${outResults} ${localOutVar} PARENT_SCOPE )
endfunction() # cframe_search_subdir_impl

# -----------------------------------------------------------------------------
# @brief Searches subdirectories for given file returning list of paths containing
#        file.
# @param DIRECTORIES [in] List of paths to directories to search for file
# @param RECURSE_MODE [in] Determines subdirectory traversal:
#                          OFF: No directory recursion
#                          ALWAYS: Always recurse subdirectories
#                          UNTIL_FOUND: Recurse only until matches are found
# @param MAXRESULTS [in] Maximum number of results to return, anything <= 0 means
#                        return as many as possible. (default: 0)
# @param FILTER [in] The regex filter to apply to the filename.
# @param OUTVAR [out] The name of the variable to store the results in
# @param VERBOSITY [in] The verbosity level to use for messages (default: 1)
#
# For example:
# @code
# cframe_search_subdirs(
#     FILTER "[a-zA-Z0-9]*.txt"
#     DIRECTORIES
#         projects
#         special/subprojA
#         optional/src/subsystem
#     OUTVAR paths
# )
# @endcode
# -----------------------------------------------------------------------------
function( cframe_search_subdirs )

  ##message( "cframe_search_subdirs" )

  # Assign default values to parameters
  set( recurseMode  ALWAYS )
  set( maxResults 0 )
  set( verbosity  1 )

  # Set up and parse multiple arguments
  set( options
  )
  set( oneValueArgs
      RECURSE_MODE
      FILTER
      MAXRESULTS
      OUTVAR
      VERBOSITY
  )
  set( multiValueArgs
      DIRECTORIES
  )

  cmake_parse_arguments(
      cframe_search_subdirs
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  if ( DEFINED cframe_search_subdirs_VERBOSITY )
    set( verbosity ${cframe_search_subdirs_VERBOSITY} )
  endif()

  if ( DEFINED cframe_search_subdirs_DIRECTORIES )
    set( directories ${cframe_search_subdirs_DIRECTORIES} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_search_dirs() DIRECTORIES not specified, aborting"
    )
  endif()

  if ( DEFINED cframe_search_subdirs_FILTER )
    set( filter ${cframe_search_subdirs_FILTER} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_search_dirs() FILTER not specified, aborting"
    )
  endif()

  if ( NOT DEFINED cframe_search_subdirs_OUTVAR )
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_search_dirs() OUTVAR not specified, aborting"
    )
  endif()

  if ( DEFINED cframe_search_subdirs_RECURSE_MODE )
    set( recurseMode ${cframe_search_subdirs_RECURSE_MODE} )
  endif()
  if (
    ( NOT ${recurseMode} STREQUAL "OFF" ) AND
    ( NOT ${recurseMode} STREQUAL "ALWAYS" ) AND
    ( NOT ${recurseMode} STREQUAL "UNTIL_FOUND" )
  )
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_search_dirs(): Invalid RECURSE_MODE [${recurseMode}], aborting"
    )    
  endif()
  
  if ( DEFINED cframe_search_subdirs_MAXRESULTS )
    set( maxResults ${cframe_search_subdirs_MAXRESULTS} )
  endif()

  ##message( "filter:      ${filter}" )
  ##message( "recurseMode: ${recurseMode}" )
  ##message( "maxResults:  ${maxResults}" )
  ##message( "directories: ${directories}" )

  set( results "" )
  foreach( dir ${directories} )
    cframe_search_subdir_impl(
        ${dir} ${filter} ${recurseMode} ${maxResults} results
    )
  endforeach()

  set(
      ${cframe_search_subdirs_OUTVAR} ${results}
      PARENT_SCOPE
  )

endfunction() # cframe_search_subdirs

# -----------------------------------------------------------------------------
# @brief Traverses all of the files in specified directories, and for each file
#        passing the specified filter, executes the specified predicate.
#
# Options:
# @param RECURSIVE [in] True if should recurse subdirs (default: FALSE)
#
# Single value args:
# @param FILTER [in] Regex filter to apply to each file found in directory
#                    (default: *)
# @param PREDICATE [in] The name of the function to execute for each file found.
# @param VERBOSITY [in] The verbosity level to use for messages (default: 1)
#
# Multivalue args:
# @param DIRECTORIES [in] List of paths to directories to traverse.
# @param PARAMS [in] Parameters to pass to PREDICATE function. Within the
#                    Parameters variable, %FILENAME% will be replaced with the
#                    name of the file currently being processed.
#
# For example:
# @code
# cframe_traverse_directories(
#     DIRECTORIES
#         projects
#         special/subprojA
#         optional/src/subsystem
#     FILTER *.txt
#     PREDICATE  printFileInfo
#     PARAMS %FILENAME%
#     RECURSIVE TRUE
# )
# @endcode
# -----------------------------------------------------------------------------
function( cframe_traverse_directories )

  # Assign default values to parameters
  set( recursive false )
  set( filters   "*" )
  set( verbosity 1 )
  set( params "%FILENAME%" )

  # Set up and parse multiple arguments
  set( options
      RECURSIVE
  )
  set( oneValueArgs
      FILTER
      PREDICATE
      VERBOSITY
  )
  set( multiValueArgs
      DIRECTORIES
      PARAMS
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )


  if ( DEFINED ARGS_VERBOSITY )
    set( verbosity ${ARGS_VERBOSITY} )
  endif()

  if ( ARGS_RECURSIVE )
    set( recursive TRUE )
  endif()

  if ( DEFINED ARGS_FILTER )
    set( filter ${ARGS_FILTER} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_traverse_directories() FILTER not specified, aborting"
    )
  endif()

  if ( DEFINED ARGS_PREDICATE )
    set( predicate ${ARGS_PREDICATE} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_traverse_directories() PREDICATE not specified, aborting"
    )
  endif()

  if ( DEFINED ARGS_DIRECTORIES )
    set( directories ${ARGS_DIRECTORIES} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        "cframe_traverse_directories() DIRECTORIES not specified, aborting"
    )
  endif()


  if ( DEFINED ARGS_PARAMS )
    set( params ${ARGS_PARAMS} )
  endif()

  message( "cframe_traverse_directories():" )
  message( "Directories: ${directories}" )
  message( "Filters:     ${filters}" )
  message( "Predicate:   ${predicate}" )
  message( "Params:      ${params}" )
  message( "Recursive:   ${recursive}" )

##  foreach( dir ${ARGS_DIRECTORIES} )
##    cframe_search_subdir_impl(
##        "${dir}" "${filter}"
##        "${recursive}" "${stopWhenFound}"
##        results
##    )
##  endforeach()

endfunction() # cframe_traverse_directories

# -----------------------------------------------------------------------------
# Determines if entry is in any of the directories specified by paths.
# Returns value in outVar or sets it to empty if not found.
# -----------------------------------------------------------------------------
function( cframe_search_paths entry paths outVar )

  foreach( path ${paths} )
    if ( EXISTS ${path}/${entry} )
      set( ${outVar} ${path}/${entry} PARENT_SCOPE )
      return()
    endif()
  endforeach()

  set( outVar "" PARENT_SCOPE )

endfunction() # cframe_search_paths

# -----------------------------------------------------------------------------
# Determines if subDir is a subdirectory of current source directory in which
# case we can directly call add_subdirectory.
# Otherwise, use the leaf directory as the binary directory.
#
# @param subDir [in] The subdirectory to add, can be absolute or relative
# @todo Would be nice to use the partial path under the AUTOLOAD_PATHS
# as the binary directory.
# -----------------------------------------------------------------------------
function( cframe_add_subdirectory subDir )

  file( RELATIVE_PATH relPath ${CMAKE_CURRENT_SOURCE_DIR} ${subDir} )
  string( SUBSTRING ${relPath} 0 2 relPathPrefix )

  if ( relPathPrefix STREQUAL ".." )
      get_filename_component( name ${relPath} NAME_WE )
      add_subdirectory( ${relPath} ${name} )
  else()
      add_subdirectory( ${relPath} )
  endif()

endfunction() # cframe_add_subdirectory


# -----------------------------------------------------------------------------
# Add all subdirectories of specified directory if it contains a CMakeLists.txt
# file
# -----------------------------------------------------------------------------
function( cframe_conditionally_add_subdirectories dir )

  file( GLOB children RELATIVE ${dir} ${dir}/* )
  foreach( child ${children} )
    if ( IS_DIRECTORY ${dir}/${child} )
      add_subdirectory( ${dir}/${child} )
    endif()
  endforeach()

endfunction() # cframe_conditionally_add_subdirectories
