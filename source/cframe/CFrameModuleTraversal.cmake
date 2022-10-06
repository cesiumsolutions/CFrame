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
  foreach( moduleDir ${CFRAME_MODULE_AUTOLOAD_PATHS} )

    cframe_message(
        MODE STATUS
        TAGS CFrame LoadModules
        VERBOSITY 2
        "Scanning Module Directory: ${moduleDir}"
    )

    file(
      GLOB children
      RELATIVE ${moduleDir}
      ${moduleDir}/*
    )

    foreach( child ${children} )
      if ( NOT IS_DIRECTORY ${moduleDir}/${child} )
        get_filename_component( ext ${child} EXT )
        if ( ${ext} STREQUAL ".cmake" )
          cframe_message(
              MODE STATUS
              TAGS CFrame LoadModules
              VERBOSITY 2
              "Automatically loading module: ${moduleDir}/${child}"
          )
          include( ${moduleDir}/${child} )
        endif()
      endif()
    endforeach()

  endforeach()

  # ---------------------------------------------------------------------------
  # Load modules specified by CFRAME_MODULES.
  # ---------------------------------------------------------------------------

  foreach( module ${CFRAME_MODULES} )
    cframe_message(
        MODE STATUS
        TAGS CFrame LoadModules
        VERBOSITY 4
        "Loading module: ${module}"
    )
    include( module )
  endforeach() # CFRAME_MODULES

endfunction() # cframe_load_modules
