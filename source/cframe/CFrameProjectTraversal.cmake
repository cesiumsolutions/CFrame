# -----------------------------------------------------------------------------
#
# Functions and variables for traversing Projects
#
# -----------------------------------------------------------------------------

# Set the default directory to look for build projects
if ( NOT DEFINED CFRAME_PROJECT_SEARCH_PATH )
  set( CFRAME_PROJECT_SEARCH_PATH ${CMAKE_SOURCE_DIR}/projects
      CACHE PATH "Default parent directory for all projects to be compiled." )
endif()
