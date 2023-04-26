# -*-cmake-*- CFrame - Copyright (C) @COPYRIGHT_YEAR_START@-@COPYRIGHT_YEAR_END@ Cesium Solutions
# This file is subject to the terms and conditions defined in the file
# 'CFRAME_LICENSE.txt', which is part of this source code package.
#
# -----------------------------------------------------------------------------
#
# @file Top-level CMakeLists file that can be used in lieu of making a custom
# top-level CMakeLists for a project.
#
# If your project consists only of sub-projects with no main projects (which is
# preferred IMHO), then you can then use this file to bootstrap CFrame, which
# can then load all of your subprojects. No need to make a boilerplate top-level
# CMakeLists file which will itself just bootstrap CFrame.
#
# The Project name can be modified from its default name ("cframe") to something
# more appropriate by setting the CFRAME_PROJECT_NAME either in cmake-gui or
# from the command line/script. This is mainly useful for IDE-based build
# environments.
#
# To use, just specify the the containing directory of this file as the source
# directory to use for CMake. Then set a combination of the following variables
# to load your sub-projects (either in cmake-gui or on the command line/script).
#
# - CFRAME_AUTOLOAD_PATHS:
#       List of directory paths to automatically load sub-projects. Directories
#       will be recursively searched until a CMakeLists.txt file is found. That
#       directory will then be added using add_subdirectory().
#
# - CFRAME_PROJECT_SEARCH_PATHS:
#       List of directory paths to search for when loading the projects
#       specified in CFRAME_PROJECTS.
#
# - CFRAME_PROJECTS:
#       List of project names to load. If it is just a simple name, it will be
#       searched for as a subdirectory of any of the directory paths specified
#       in CFRAME_PROJECT_SEARCH_PATHS.
#       If it is a full path, then it will just be used as is and the project
#       name will be used as the leaf directory in the full directory path.
#       In either case, add_subdirectory() will be called on the resulting
#       directory (either relative to a search path or absolute path).
#
# -----------------------------------------------------------------------------

cmake_minimum_required( VERSION 3.10 )
project( CFrame )

set(
    CFRAME_DIR ${CMAKE_SOURCE_DIR}
    CACHE PATH "Directory to CFrame"
)

include( ${CFRAME_DIR}/CFrame.cmake )

# Handle customization of top-level Project name
# Note: CMake always uses the last call to project() as the top level Project
#       name.
set(
    CFRAME_PROJECT_NAME "CFrame"
    CACHE STRING "Name of top level Project"
)
if ( NOT "${CFRAME_PROJECT_NAME}" STREQUAL "CFrame" )
  project( ${CFRAME_PROJECT_NAME} )
endif()

add_subdirectory( libs )
