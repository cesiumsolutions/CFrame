# -----------------------------------------------------------------------------
# @file CframeProjectTraversal.cmake
# Variables and processes for looking for and loading Projects
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

# -----------------------------------------------------------------------------
# Autoload projects found in CFRAME_PROJECT_AUTOLOAD_PATHS.
# -----------------------------------------------------------------------------

cframe_search_subdirs(
    FILENAME CMakeLists.txt
    ROOTDIRS ${CFRAME_PROJECT_AUTOLOAD_PATHS}
    OUTVAR projectPaths
    RECURSIVE OFF
    STOPWHENFOUND TRUE
)

foreach( projectPath ${projectPaths} )
  cframe_add_subdirectory( ${projectPath} )
endforeach() # projectPaths

# -----------------------------------------------------------------------------
# Load projects found by CFRAME_PROJECTS using CFRAME_PROJECT_SEARCH_PATHS.
# -----------------------------------------------------------------------------

foreach( projectName ${CFRAME_PROJECTS} )

  foreach ( searchPath ${CFRAME_PROJECT_SEARCH_PATHS} )
    if ( IS_DIRECTORY ${searchPath}/${projectName} )
      cframe_add_subdirectory( ${searchPath}/${projectName} )
    endif()
  endforeach()

endforeach() # CFRAME_PROJECTS
