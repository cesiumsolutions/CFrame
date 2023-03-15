# -----------------------------------------------------------------------------
#
# Convenience functions for installing files.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Installs specified files in subdirectory consisting of the relative directory
# relative to the base directory and including any directory part of the
# filename as additional subdirectories.
#
# BASE_DIRECTORY The directory from which to take relative path part from.
#                Defaults to ${PROJECT_SOURCE_DIR}
# RELATIVE_PATH The path to calculate the directory relative to the BASE_DIRECTORY.
#               Defaults to ${CMAKE_CURRENT_SOURCE_DIR}
# FILE List of files to install, which may constain subdirectory parts to them.
# -----------------------------------------------------------------------------
function ( cframe_install_files )

  cframe_message( MODE STATUS VERBOSITY 3
      "CFrame: FUNCTION: cframe_install_files"
  )

  # -----------------------------------
  # Set up and parse multiple arguments
  # -----------------------------------
  set( options
  )
  set( oneValueArgs
       BASE_DIRECTORY
       RELATIVE_PATH
  )
  set( multiValueArgs
      FILES
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  if ( NOT ARGS_BASE_DIRECTORY )
    set( baseDir ${PROJECT_SOURCE_DIR} )
  else()
    set( baseDir ${ARGS_BASE_DIRECTORY} )
  endif()

  if ( NOT ARGS_RELATIVE_PATH )
    set( relPath ${CMAKE_CURRENT_SOURCE_DIR} )
  else()
    set( relPath ${ARGS_RELATIVE_PATH} )
  endif()

  cmake_path(
      RELATIVE_PATH   relPath
      BASE_DIRECTORY  ${baseDir}
      OUTPUT_VARIABLE parentPath
  )

  foreach( file ${ARGS_FILES} )
    cmake_path( GET file PARENT_PATH subDir )
    install(
        FILES ${file}
        DESTINATION ${parentPath}/${subDir}
    )

  endforeach()

endfunction() # cframe_install_files
