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

# High-level CFrame-specific Utilities
include( CFrameProjectTraversal )



#include_directories( testtools )

#include( CFrameInternal )
#include( CFrameUtilities )
#include( CFrameExternalPackages )
#include( CFrameProjects )
#include( CFrameBuildFunctions )
