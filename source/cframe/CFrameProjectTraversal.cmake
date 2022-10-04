# -----------------------------------------------------------------------------
#
# Functions, processes and variables for traversing Projects
#
# -----------------------------------------------------------------------------

# Set the directories to look for projects to autoload
set(
    CFRAME_PROJECT_AUTOLOAD_PATHS ${CMAKE_SOURCE_DIR}/projects
    CACHE PATH
    "List of directories to automatically search for and load projects."
)

# Set the directories to search in when specifying projects with CFRAME_PROJECTS
set(
    CFRAME_PROJECT_SEARCH_PATHS ""
    CACHE PATH
    "List of directories to search for when specifying CFRAME_PROJECTS."
)

# Set the names of projects to load, using CFRAME_PROJECT_SEARCH_PATHS when an
# entry is not a full path
set(
    CFRAME_PROJECTS ""
    CACHE PATH
    "List of directories to search for when specifying CFRAME_PROJECTS."
)


# Autoload projects found in CFRAME_PROJECT_AUTOLOAD_PATHS

cframe_search_subdirs(
    FILENAME CMakeLists.txt
    ROOTDIRS ${CFRAME_PROJECT_AUTOLOAD_PATHS}
    OUTVAR projectPaths
    RECURSIVE OFF
    STOPWHENFOUND TRUE
)

message( "Project Paths: ${projectPaths}" )

foreach( projectPath ${projectPaths} )

  # Need to find if projectPath is a subdirectory of current source
  # directory in which case we can directly call add_subdirectory.
  # Otherwise, use the leaf directory as the binary directory.
  # @todo Would be nice to use the partial path under the AUTOLOAD_PATHS
  # as the binary directory.
  
  file( RELATIVE_PATH relPath ${CMAKE_CURRENT_SOURCE_DIR} ${projectPath} )
  string( SUBSTRING ${relPath} 0 2 relPathPrefix )
  message( "Project Path: ${projectPath}" )
  message( "Relative Path: ${relPath}" )
  message( "RelPathPrefix: ${relPathPrefix}" )

  if ( relPathPrefix STREQUAL ".." )
      get_filename_component( projectName ${relPath} NAME_WE )
      add_subdirectory( ${relPath} ${projectName} )
  else()
      add_subdirectory( ${relPath} )
  endif()
endforeach()


