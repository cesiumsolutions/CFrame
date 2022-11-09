# -*-cmake-*- CFrame - Copyright (C) @COPYRIGHT_YEAR_START@-@COPYRIGHT_YEAR_END@ Cesium Solutions
# This file is subject to the terms and conditions defined in the file
# 'CFRAME_LICENSE.txt', which is part of this source code package.
#
# -----------------------------------------------------------------------------
#
# Main script to be included by top-level project CMakeLists.txt files
#
# Example toplevel CMakeLists.txt:
# <code>
# cmake_minimum_required( VERSION 3.10 )
# project( my-awesome-project )
#
# set( CFRAME_DIR "" CACHE PATH "Directory to CFrame" )
# if ( NOT EXISTS ${CFRAME_DIR} )
#   message(
#       "CFRAME_DIR not specified or not found,"
#       " please check and set appropriately."
#   )
#   exit()
# endif()
#
# # Optionally pre-set/modify CFRAME_MODULE_AUTOLOAD_PATHS to specify paths to
# # automatically look for module files to load (can also be done in cmake-gui
# # or on the command line).
# # (default: ${CFRAME_DIR}/share/cframe/modules)
# set( CFRAME_MODULE_AUTOLOAD_PATHS
#      ${CFRAME_DIR}/share/cframe/modules
#      /path/to/myproject/cmake/modules
# )
#
# # Optionally pre-set CFRAME_PROJECTS (can also be done in cmake-gui or on the
# # command line).
# set(
#     CFRAME_PROJECTS
#         project1
#         project2
#         project3
#     CACHE STRING
#         "List of Projects to build"
# )
#
# # Bootstrap CFrame. This will automatically load CMake modules specified by
# # CFRAME_MODULE_AUTOLOAD_PATHS, CFRAME_MODULES, and projects specified by
# # CFRAME_PROJECT_AUTOLOAD_PATHS, and CFRAME_PROJECTS.
# include( ${CFRAME_DIR}/CFrame.cmake )
#
# <endcode>
# -----------------------------------------------------------------------------

get_filename_component(
    CFRAME_PARENT_PATH ${CMAKE_CURRENT_LIST_FILE} DIRECTORY
)
list(
    APPEND
    CMAKE_MODULE_PATH
    ${CFRAME_PARENT_PATH}/source/cframe
    ${CFRAME_PARENT_PATH}/share/cframe/modules
    ${CFRAME_PARENT_PATH}/share/cframe/externals
)

# Standard CMake Utilities
include( CMakeParseArguments )

# Option to control whether internal CFrame tests are run.
option( CFRAME_RUN_TESTS "Toggle to run internal CFrame tests" OFF )

# General Purpose Low-level Utilities
include( CFrameMessage )
include( CFrameListUtilities )
include( CFrameDirectoryUtilities )

# CFrame-specific low-level stuff
include( CFrameIncludeCFrameSource )

# Bootstrap Modules loading
include( CFrameModuleTraversal )
cframe_load_modules()

# Variable to specify list of directory paths to look for external dependencies.
set(
    CFRAME_EXTERN_SEARCH_PATHS ""
    CACHE STRING
    "Directory paths to look for external dependencies."
)

# Add projects based on variables
include( CFrameProjectTraversal )
cframe_load_projects()
