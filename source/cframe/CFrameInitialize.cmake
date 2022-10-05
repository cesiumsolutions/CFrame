# -----------------------------------------------------------------------------
#
# Initializes various settings and variables.
#
# -----------------------------------------------------------------------------

# Standard CMake Utilities
include( CMakeParseArguments )

# General Purpose Low-level Utilities
include( CFrameMessage )
include( CFrameListUtilities )
include( CFrameDirectoryUtilities )

# Configuration options
include( CFrameGeneralConfiguration )

#include_directories( testtools )

#include( CFrameInternal )
#include( CFrameUtilities )
#include( CFrameExternalPackages )
#include( CFrameProjects )


# High-level CFrame-specific Utilities
include( CFrameModuleTraversal )
cframe_load_modules()

include( CFrameProjectTraversal )
cframe_load_projects()
