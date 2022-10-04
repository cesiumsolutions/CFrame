# -----------------------------------------------------------------------------
# @file CFrameModuleTraversal.cmake
# Variables and functions for looking for and loading Projects
#
# -----------------------------------------------------------------------------

# Set the directories to look for projects to autoload
set(
    CFRAME_MODULE_AUTOLOAD_PATHS ${CMAKE_SOURCE_DIR}/share/cframe/modules
    CACHE PATH
    "List of directories to automatically search for and load Modules."
)

# Set the names of modules to load, using CMAKE_MODULE_PATH when an
# entry is not a full path
set(
    CFRAME_MODULES ""
    CACHE PATH
    "List of modules to load, references CMAKE_MODULE_PATH."
)

# -----------------------------------------------------------------------------
# Load modules using CFRAME_MODULE_AUTOLOAD_PATHS, CFRAME_MODULES variables.
# -----------------------------------------------------------------------------
function( cframe_load_modules )

  # ---------------------------------------------------------------------------
  # Autoload modules found in CFRAME_MODULE_AUTOLOAD_PATHS.
  # ---------------------------------------------------------------------------
  cframe_search_subdirs(
      FILENAME CMakeLists.txt
      ROOTDIRS ${CFRAME_PROJECT_AUTOLOAD_PATHS}
      OUTVAR modulePaths
      RECURSIVE OFF
      STOPWHENFOUND TRUE
  )

  foreach( modulePath ${modulePaths} )
    message( "Automatically adding Module: ${modulePath}" )
    include( ${modulePath} )
  endforeach() # modulePaths

  # ---------------------------------------------------------------------------
  # Load modules specified by CFRAME_MODULES.
  # ---------------------------------------------------------------------------

  foreach( module ${CFRAME_MODULES} )

    include( module )

  endforeach() # CFRAME_MODULES

endfunction() # cframe_load_modules
