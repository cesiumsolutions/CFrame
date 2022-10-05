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

set( CFRAME_SEARCH_SUBDIRS_RESULT "" )

function( cframe_search_subdir_impl dir filter recursive maxResults )

  message( "cframe_search_subdir_impl: ${dir} [${CFRAME_SEARCH_SUBDIRS_RESULT}]" )
  
  file(
    GLOB children
    RELATIVE ${dir}
    ${dir}/*
  )
  
  foreach( child ${children} )
    
    if ( IS_DIRECTORY ${dir}/${child} )

      if ( ${recursive} )
        cframe_search_subdir_impl(
            ${dir}/${child} ${filter} ${recursive} ${maxResults}
        )
      endif()

    else() # IS_FILE
    
    
      message( "cframe_search_subdir_impl: ${dir}/${child} [${CFRAME_SEARCH_SUBDIRS_RESULT}]" )
    
      string( REGEX MATCH ${filter} matchResult ${child} )
      if ( NOT "${matchResult}" STREQUAL "" )
        list( APPEND CFRAME_SEARCH_SUBDIRS_RESULT ${dir}/${child} )
        message( "Match found: ${dir}/${child}" )
        message( "Current List: ${CFRAME_SEARCH_SUBDIRS_RESULT}" )
        
        if ( ${maxResults} GREATER 0 )
          list( LENGTH CFRAME_SEARCH_SUBDIRS_RESULT currentLength )
          if ( ${currentLength} GREATER_EQUAL ${maxResults} )
            return()
          endif() # max results reached
        endif() # limited results
      endif() # Filter matched
    endif() # IS_FILE
    
  endforeach()
  
endfunction() # cframe_search_subdir_impl

# -----------------------------------------------------------------------------
# @brief Searches subdirectories for given file returning list of paths containing
#        file.
# Options:
# @param RECURSIVE [in] True if directory should recurse subdirs (default: TRUE)
# @param MAXRESULTS [in] Maximum number of results to return, anything <= 0 means
#                        return as many as possible. (default: 0)
# Single value args:
# @param FILTER [in] The regex filter to apply to the filename.
# @param OUTVAR [out] The name of the variable to store the results in
# @param VERBOSITY [in] The verbosity level to use for messages (default: 1)
# Multivalue args:
# @param ROOTDIRS [in] List of paths to directories to search for file
#
# For example:
# @code
# cframe_search_subdirs(
#     FILTER "[a-zA-Z0-9]*.txt"
#     ROOTDIRS
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
  set( recursive  ON )
  set( maxResults 0 )
  set( verbosity  1 )

  # Set up and parse multiple arguments
  set( options
  )
  set( oneValueArgs
      RECURSIVE
      FILTER
      MAXRESULTS
      OUTVAR
      VERBOSITY
  )
  set( multiValueArgs
      ROOTDIRS
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

  if ( DEFINED cframe_search_subdirs_ROOTDIRS )
    set( rootDirs ${cframe_search_subdirs_ROOTDIRS} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        MESSAGE "cframe_search_dirs() ROOTDIRS not specified, aborting"
    )
  endif()

  if ( DEFINED cframe_search_subdirs_FILTER )
    set( filter ${cframe_search_subdirs_FILTER} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        MESSAGE "cframe_search_dirs() FILTER not specified, aborting"
    )
  endif()

  if ( NOT DEFINED cframe_search_subdirs_OUTVAR )
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        MESSAGE "cframe_search_dirs() OUTVAR not specified, aborting"
    )
  endif()

  if ( DEFINED cframe_search_subdirs_RECURSIVE )
    set( recursive ${cframe_search_subdirs_RECURSIVE} )
  endif()
  if ( DEFINED cframe_search_subdirs_MAXRESULTS )
    set( maxResults ${cframe_search_subdirs_MAXRESULTS} )
  endif()

  ##message( "filter: ${filter}" )
  ##message( "recursive: ${recursive}" )
  ##message( "maxResults: ${maxResults}" )
  ##message( "rootDirs: ${rootDirs}" )

  set( CFRAME_SEARCH_SUBDIRS_RESULT "" )
  foreach( dir ${cframe_search_subdirs_ROOTDIRS} )
    cframe_search_subdir_impl(
        ${dir} ${filter} ${recursive} ${maxResults}
    )
  endforeach()
  message( "Finished: ${CFRAME_SEARCH_SUBDIRS_RESULT}" )

  set(
      ${cframe_search_subdirs_OUTVAR} ${CFRAME_SEARCH_SUBDIRS_RESULT}
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
        MESSAGE "cframe_traverse_directories() FILTER not specified, aborting"
    )
  endif()

  if ( DEFINED ARGS_PREDICATE )
    set( predicate ${ARGS_PREDICATE} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        MESSAGE "cframe_traverse_directories() PREDICATE not specified, aborting"
    )
  endif()

  if ( DEFINED ARGS_DIRECTORIES )
    set( directories ${ARGS_DIRECTORIES} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        MESSAGE "cframe_traverse_directories() DIRECTORIES not specified, aborting"
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

##  foreach( dir ${cframe_search_subdirs_ROOTDIRS} )
##    cframe_search_subdir_impl(
##        "${dir}" "${filter}"
##        "${recursive}" "${stopWhenFound}"
##        results
##    )
##  endforeach()

endfunction() # cframe_traverse_directories

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
  message( "SubDir Path:   ${subDir}" )
  message( "Relative Path: ${relPath}" )

  if ( relPathPrefix STREQUAL ".." )
      get_filename_component( name ${relPath} NAME_WE )
      add_subdirectory( ${relPath} ${name} )
  else()
      add_subdirectory( ${relPath} )
  endif()

endfunction() # cframe_add_subdirectory
