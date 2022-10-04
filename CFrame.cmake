# -*-cmake-*- CFrame - Copyright (C) @COPYRIGHT_YEAR_START@-@COPYRIGHT_YEAR_END@ Cesium Solutions
# This file is subject to the terms and conditions defined in the file
# 'CFRAME_LICENSE.txt', which is part of this source code package.
#
# -----------------------------------------------------------------------------
#
# Main script to be included by top-level project CMakeLists.txt files
#
# Example:
# <code>
# cmake_minimum_required( VERSION 3.20 )
# project( harman-calibration-tools )
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
# # Optionally pre-set CFRAME_PROJECTS, but these could also be set
# # interactively, e.g. within CMake GUI.
# set(
#     CFRAME_PROJECTS
#         czmharman
#         czmharman-assets
#         czmboostasio
#     CACHE STRING
#         "List of Projects to build"
# )
# # Include the main CFrame file
# include( ${CFRAME_DIR}/CFrame.cmake )
#
# # You can then include any of the optional module scripts provided by CFrame
# include( CFrameBuildCommands )
#
# # Or set/modify CFAME_MODULE_AUTOLOAD_PATHS to specify paths to automatically
# # look for module files to load
# <endcode>
# -----------------------------------------------------------------------------

cmake_path( GET CMAKE_CURRENT_LIST_FILE PARENT_PATH CFRAME_PARENT_PATH )
message( "CFRAME_PARENT_PATH: ${CFRAME_PARENT_PATH}" )

set(
    CMAKE_MODULE_PATH
    ${CFRAME_PARENT_PATH}/source/cframe
    ${CFRAME_PARENT_PATH}/share/cframe/modules
    ${CFRAME_PARENT_PATH}/share/cframe/externals
)

include( CFrameInitialize )
