# -----------------------------------------------------------------------------
#
# Contains functions for operating on directories
#
# -----------------------------------------------------------------------------

# @brief Returns the relative path of all the files relative to specified directory
# @param directory [in] The directory to get relative path to
# @param files [in] List of files to determine relative path
# @return outVar 
function( cframe_files_relative_paths outVar directory files )

  foreach( file ${files} )
    file( RELATIVE_PATH relPath ${directory} ${file} )
    list( APPEND relPaths ${relPath} )
  endforeach()

  set( ${outVar} ${relPaths} PARENT_SCOPE )
endfunction() # cframe_files_relative_paths

#
#
#
function( cframe_search_subdir_impl dir filename recursive stopWhenFound outVar )

  ##message( "cframe_search_subdir_impl: ${dir} ${filename} ${recursive} ${stopWhenFound} ${outVar}" )

  if ( EXISTS ${dir}/${filename} )
    list( APPEND results ${dir} )
    if ( ${stopWhenFound} )
      set( ${outVar} ${results} PARENT_SCOPE )
      return()
    endif()
  endif()

  if ( NOT ${recursive} )
    set( ${outVar} ${results} PARENT_SCOPE )
    return()
  endif()

  file(
      GLOB children
      RELATIVE ${dir}
      ${dir}/*
  )

  foreach( child ${children} )
    if ( IS_DIRECTORY ${dir}/${child} )
      cframe_search_subdir_impl(
          ${dir}/${child} ${filename}
          ${recursive} ${stopWhenFound}
          results
      )
    endif()
  endforeach()

  set( ${outVar} ${results} PARENT_SCOPE )

endfunction() # cframe_search_subdir_impl

# ------------------------------------------------------------------------------
# @brief Searches subdirectories for given file returning list of paths containing
#        file.
# Options:
# @param RECURSIVE [in] True if directory should recurse subdirs (default: TRUE)
# @param STOPWHENFOUND [in] True if search terminates after first file is found
#                          (default: FALSE)
# One value args:
# @param FILENAME [in] The name of the file to search for
# @param OUTVAR [out] The name of the variable to store the results in
# @param VERBOSITY [in] The verbosity level to use for messages (default: 1)
# Multivalue args:
# @param ROOTDIRS [in] List of paths to directories to search for file
#
# For example:
# @code
# cframe_search_subdirs(
#     FILENAME CMakeLists.txt
#     ROOTDIRS
#         projects
#         special/subprojA
#         optional/src/subsystem
#     OUTVAR paths
# )
# @endcode
# ------------------------------------------------------------------------------
function( cframe_search_subdirs )

  ##message( "cframe_search_subdirs" )

  # Assign default values to parameters
  set( recursive     false )
  set( stopWhenFound false )
  set( verbosity     1 )

  # Set up and parse multiple arguments
  set( options
      RECURSIVE
      STOPWHENFOUND
  )
  set( oneValueArgs
      FILENAME
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

  if ( DEFINED cframe_search_subdirs_FILENAME )
    set( filename ${cframe_search_subdirs_FILENAME} )
  else()
    cframe_message(
        MODE FATAL_ERROR
        TAGS CFrame DirectoryUtils
        VERBOSITY ${verbosity}
        MESSAGE "cframe_search_dirs() FILENAME not specified, aborting"
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

  if ( cframe_search_subdirs_RECURSIVE )
    set( recursive TRUE )
  endif()
  if ( cframe_search_subdirs_STOPWHENFOUND )
    set( stopWhenFound TRUE )
  endif()

  ##message( "filename: ${filename}" )
  ##message( "recursive: ${recursive}" )
  ##message( "stopWhenFound: ${stopWhenFound}" )
  ##message( "rootDirs: ${rootDirs}" )

  foreach( dir ${cframe_search_subdirs_ROOTDIRS} )
    cframe_search_subdir_impl(
        "${dir}" "${filename}"
        "${recursive}" "${stopWhenFound}"
        results
    )
  endforeach()

  set( ${cframe_search_subdirs_OUTVAR} ${results} PARENT_SCOPE )

endfunction() # cframe_search_subdirs
