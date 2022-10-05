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

# High-level CFrame-specific Utilities
include( CFrameModuleTraversal )
cframe_load_modules()

include( CFrameProjectTraversal )
cframe_load_projects()
