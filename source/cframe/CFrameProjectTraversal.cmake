# -----------------------------------------------------------------------------
# @file CFrameProjectTraversal.cmake
# Variables and functions for looking for and loading Projects
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
    "List of projects to load, referencing CFRAME_PROJECT_SEARCH_PATHS."
)

# -----------------------------------------------------------------------------
# Load projects using CFRAME_PROJECT_AUTOLOAD_PATHS, CFRAME_PROJECTS variables.
# -----------------------------------------------------------------------------
function( cframe_load_projects )

  # ---------------------------------------------------------------------------
  # Autoload projects found in CFRAME_PROJECT_AUTOLOAD_PATHS.
  # ---------------------------------------------------------------------------
  cframe_search_subdirs(
      FILTER CMakeLists.txt
      ROOTDIRS ${CFRAME_PROJECT_AUTOLOAD_PATHS}
      OUTVAR projectPaths
      RECURSIVE OFF
      STOPWHENFOUND TRUE
  )

  foreach( projectPath ${projectPaths} )
    message( "Automatically adding Project: ${projectPath}" )
    cframe_add_subdirectory( ${projectPath} )
  endforeach() # projectPaths

  # ---------------------------------------------------------------------------
  # Load projects found by CFRAME_PROJECTS using CFRAME_PROJECT_SEARCH_PATHS.
  # ---------------------------------------------------------------------------

  foreach( projectName ${CFRAME_PROJECTS} )

    if ( IS_DIRECTORY ${projectName} )
      cframe_add_subdirectory( ${projectName} )
    else()
      foreach ( searchPath ${CFRAME_PROJECT_SEARCH_PATHS} )
        if ( IS_DIRECTORY ${searchPath}/${projectName} )
          message( "Adding Project: ${searchPath}/${projectName}" )
          cframe_add_subdirectory( ${searchPath}/${projectName} )
        endif()
      endforeach()

    endif()


  endforeach() # CFRAME_PROJECTS

endfunction() # cframe_load_projects
