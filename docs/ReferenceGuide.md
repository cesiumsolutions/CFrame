# CFrame Reference Guide
------------------------

## Administrative Functions

include( $\{CFRAME_SOURCE_DIR\}/cframe.cmake )

### cframe_initialize( subsystem(s) )

* MESSAGING: The messaging subsystem
* PROJECT: The project management subsystem
* TARGET: The target management subsystem

## Messaging

### cframe_message(...)

* MODE: Same as CMake's message() function Mode parameter
* VERBOSITY: A number indicating the level of detail of the message
* TAGS:
* default: The message to be displayed

### cframe_would_message(...)

* MODE: Same as CMake's message() function Mode parameter
* VERBOSITY: A number indicating the level of detail of the message
* TAGS:
* OUTVAR:

### CFRAME_MESSAGE_MODE_FILTER

### CFRAME_MESSAGE_VERBOSITY_LEVEL

### CFRAME_MESSAGE_TAG_FILTER



## Project Management Subsystem

### cframe_add_project_dir( dirName )

### cframe_add_project_base_dir( baseDirName )

### cframe_process_directory( dirName )

### cframe_process_subdirectories( dirName )

### cframe_process_projects()

### cframe_process_externals()

### CFRAME_PROJECT_DIRS

### CFRAME_EXTERNALS_POLICY

## Target Management Subsystem

### cframe_target(...)

* TARGET_TYPE
    * Executable
    * Library
    * Headers
    * Resources
* HEADERS_PUBLIC
* HEADERS_PRIVATE
* SOURCES
* VERSION
* INSTALL_DIR

### cframe_file_group

* FILES: The list of names of files to place in the group
* IDE_FOLDER: The folder where the files will appear in IDE-based development
  environments.
* INSTALL_DIR: The directory where the files will be installed. If not specified,
  it will be inherited from the INSTALL_DIR if used in the cframe_target() function.
* OUTPUT_VAR: The name of the variable where to store the file names. This can
  then be used for example in the cframe_target() command.

### cframe_read_source_filter_files( ... )

Reads the contents of the file specified in "filename" and appends them to the
specified variable. The entries in the file can be regular expressions or the
explicit (relative) path to the file specified in the source. Any line starting
with a '#' is considered a comment and ignored.

- FILENAMES: The names of the files to read containing source filter list.
- OUTPUT_VAR: The name of the variable to append the list of read source files
  to. Default value is CFRAME_FILTER_LIST if none is specified

### cframe_process_filter(...)

- CANDIDATE_FILES:
  The list of files to be considered.
- FILTER:
  The list of files to be removed from the CANDIDATE_FILES list.
- OUTPUT_VAR: The variable where to store the result of the filtering operation.

### CFRAME_SOURCE_FILTER_INPUT_FILES
A list of files to be used as inputs that contain a list of files that will be
excluded from being processed within the cframe_target command

### CFRAME_SOURCE_FILTER_LIST

A list of files that will be filtered out of any of the files listed in the
cframe_target function.


## Dependency Management Subsystem

## Version Subsystem

### CFRAME_VERSION_TEMPLATE_HEADER_FILES

### CFRAME_VERSION_TEMPLATE_SOURCE_FILES


### cframe_setup_version( ... )

* TARGET_NAME:
* MAJOR:
* MINOR:
* PATCH:
* BUILD:
* NAME:

### cframe_process_version( ... )

* TARGET_NAME:
*


## Platform Dependent Subsystem

### CFRAME_OS_LIBRARIES

### CFRAME_LOADER_LIBRARIES

### CFRAME_SOCKET_LIBRARIES

## Unit Test (Internal) Subsystem









