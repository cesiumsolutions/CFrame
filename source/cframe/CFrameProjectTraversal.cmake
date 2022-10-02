# -----------------------------------------------------------------------------
#
# Functions and variables for traversing Projects
#
# -----------------------------------------------------------------------------

# Set the default directory to look for build projects
if ( NOT DEFINED CFRAME_PROJECTS_DIR )
  set( CFRAME_PROJECTS_DIR ${CMAKE_SOURCE_DIR}/projects
      CACHE PATH "Default parent directory for all projects to be compiled."      )
endif()
