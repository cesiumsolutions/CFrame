# -----------------------------------------------------------------------------
# Set External packages and search paths
# -----------------------------------------------------------------------------

set( CFRAME_EXTERN_SETUP_SEARCH_PATHS
    ${CFRAME_DIR}/share/cframe/externals
    CACHE STRING
    "List of directories to search for external library setup scripts."
)

set( CFRAME_EXTERN_LIBS Boost
    CACHE STRING
    "List of external libraries to setup"
)

# Automatically add imported targets from find_package() to global scope
set( CMAKE_FIND_PACKAGE_TARGETS_GLOBAL TRUE )

# -----------------------------------------------------------------------------
# Load all external libraries specified in the CFRAME_EXTERN_LIBS variable
# and looking for a corresponding setup script in CFRAME_EXTERNAL_SEARCH_PATHS.
# -----------------------------------------------------------------------------
macro( cframe_setup_externals )

  foreach( extLib ${CFRAME_EXTERN_LIBS} )

    foreach( extPath ${CFRAME_EXTERN_SETUP_SEARCH_PATHS} )

      cframe_message( MODE DEBUG VERBOSITY 2
          "Checking existence of: ${extPath}/CFrameSetup${extLib}.cmake"
      )

      if ( EXISTS "${extPath}/CFrameSetup${extLib}.cmake" )
        cframe_message( MODE STATUS VERBOSITY 1
            "Setting up external library: ${extLib} from ${extPath}/CFrameSetup${extLib}.cmake"
        )
        include( "${extPath}/CFrameSetup${extLib}.cmake" )
        set( ${extLib}_FOUND 1 )
        break()
      endif()

    endforeach() # foreach CFRAME_EXTERNAL_SEARCH_PATH

    if ( NOT "${${extLib}_FOUND}" )
      cframe_message( MODE FATAL_ERROR VERBOSITY 0
          "Could not find Setup for library: ${extLib}"
      )
    endif()

  endforeach() # foreach CFRAME_EXTERN_LIBS

endmacro() # cframe_setup_externals
