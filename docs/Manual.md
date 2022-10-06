# CFrame: User's Manual
-----------------------
This document describes the process for integrating disparate/separate software projects that use the CMake build system.

## Administrative Stuff

### Revision Log
| Version | Date | Description |
| :---: |:---:| --- |
| 0.1 | 2018/08/18 | Initial release. |

### License Summary

### Prerequisites
This document assumes the reader knows how to develop their own software and a basic knowledge of CMake and how to use the CMake tools to build their software.

### Resources
CMake can be downloaded from [here](http://www.cmake.org/download).

Saccades information can be found [here](http://www.cesiumsolutions.com/saccades).

Cesium Solutions general information can be found [here](http://www.cesiumsolutions.com).

## Motivation

## General Process

### Installation

Download CFrame from <TODO> and place somewhere in your filesystem conveninent
for referencing in your development environment.

### Initial Reference

In your project's top-level CMakeLists.txt file, preferably as early as possible, add the CFrame's distribution directory to the CMAKE_MODULE_PATH. A common way for doring this would be to make a user-definable variable (e.g. CFRAME_DIR) and then include the CFrame file. For example:

~~~~
cmake_minimum_required(VERSION 3.0)
project(cframetestproject)

# CFrame setup and initialization
set( CFRAME_DIR "" CACHE PATH "Directory containing CFrame distribution" )
set( CMAKE_MODULE_PATH ${CFRAME_DIR} )
include( CFrame )
~~~~

Once the CFrame main initialization script has been loaded, the various subsystems that CFrame offers can be initialized like:

~~~~
cframe_initialize()
~~~~

By default this initializes all the subsystems offered by CFrame. However, individual subsystems can be initialized as needed. For example:

~~~~
cframe_initialize( MESSAGING PROJECT_MGMT TARGET_MGMT )
~~~~

This explicitly initializes all of the (currently available) subsystems. A subset of this list can be initialized according to your needs/desires. Each of these subsystems are described in the following sections.

## Messaging Subsystem

The Messaging subsystem is built on top of the standard CMake `message` command. It attempts to replicate and/or provide similar functionality as logging systems of more traditional programming languages.

The CFrame messaging `cframe_message` in addition to specifing the parameters that the CMake `message` command provides, allows the specification of two more attributes:

* MODE: Corresponds to the Mode parameter of the standard CMake `message` function.
* VERBOSITY: A numeric value indicating a verbosity level, where a higher value indicates more verbosity, and -1 indicates the highest level of verbosity.
* TAGS: A list of freeform strings associated with the message, similar to the Android log() function. If no tags are specified, the CFRAME_MESSAGE_DEFAULT_TAG will be assigned to it (which itself may be empty).

The primary reason for providing these additional attributes is to allow for the filtering of messages. The cframe_message() function reads the following variables to determine whether the message should actually be shown:

* `CFRAME_MESSAGE_VERBOSITY`: Indicates the verbosity level value above which messages will not be shown. Therefore, if a message is specified with a level greater than the value of this variable, it will not be shown. Default value is 2.
* `CFRAME_MESSAGE_TAG_FILTER`: A regular expression determining which messages with their corresponding tags will be shown. Default value is '*' for all messages. If a message has an empty tag, it will not be filtered on the basis of the Tag. This includes messages who's Tag is empty as the result of being default assigned an empty `CFRAME_MESSAGE_DEFAULT_TAG'.
* `CFRAME_MESSAGE_DEFAULT_MODE`: The default model assigned to a (CFrame) message if the one is not explicitly specified. The default value for this is: WARN.
* `CFRAME_MESSAGE_DEFAULT_VERBOSITY`: The default verbosity level assigned to a (CFrame) message if one is not explicitly specified. The default value for this is 1.
* `CFRAME_MESSAGE_DEFAULT_TAG`: The default tag associated with a message whose tag has not been explicitly specified. The default value for this is an empty string.

These variables are initialized and read by the Messaging subsystem and will appear as variables in the CMake configuration interface. This allows more tight controls over what messages will be shown and can be helpful when debugging CMake scripts.

The following are some examples of CFrame messages:

~~~~
cframe_message(
    MODE WARN
    VERBOSITY 2
    TAGS "Graphics"
    "A fairly detailed message related to a Graphics software component"
)

cframe_message(
    "A message that will be assigned the default values for each of the attributes"
)
~~~~

The CFrame Messaging subsystems can be used standalone without the other subsystems from CFrame. However, as it is used by all the other CFrame subsystems, whenever any of those Subsystems are loaded (i.e. in the call to `cframe_initialize()`), then the Messaging subsystem will automatically be loaded,

## Project Subsystem



## Target Subsystem





## Software Module Instructions

## Framework Internals

## Appendices

### License

### Roadmap/TODOs

* Handling of project subdirectories
    * Define ```CFRAME_SETUP_PROJECT_SUBDIR``` or something like that
    * For the top level:
        * ```CFRAME_SET_PROJECT_SUBDIRS``` which includes each SUBDIR/SUBDIR.cmake
    * Defines:
        * ```CFRAME_SUBDIRS_HEADERS_PUBLIC```
        * ```CFRAME_SUBDIRS_HEADERS_PRIVATE```
        * ```CFRAME_SUBDIRS_SOURCES```

* Automate and standardize (unit) testing configuration
    * Catch
    * GoogleTest
    * Boost.unit_test

* Handling of external packages
    * Define a ```CFRAME_EXTERNALS_POLICY``` which can take one of the following:
        * Manual: all externals must be specified explicitly, maybe using
          a ```CFRAME_EXTERNALS_DIR``` as the base
        * Conan: Use the conan package manager

* Standard way for handling platform/compiler dependencies
    * Define canonical form for platform identification so can be used for
      example as directory names

      For example: win64-vc14, ubuntu16.04-64, or something like that. This could
      be used to automatically specify externals directory for Manual
      ```CFRAME_EXTERNALS_POLICY``` and for build directory specification.

* Add Platform specific variables, for example:
    * ```CFRAME_OS_LIBRARIES```
    * ```CFRAME_LOADER_LIBRARIES```

* Add support for automatic versioning
    * Specify ```CFRAME_VERSION_TECHNIQUE```
    * Provide a standard CFrame implementation of versioning (similar to OpenIGS's Version)
    * cframe_build_target function accepts VERSION specification

* Handle projects scattered in file system, not just as children of one directory
    * Read project names and locations from a file specified by
      ```CFRAME_PROJECTS_FILE```

* Use source file filter
