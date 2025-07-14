# -----------------------------------------------------------------------------
#
# Convenience functions for building targets.
#
# -----------------------------------------------------------------------------

set(
    CFRAME_SOURCE_DISPLAY_MODE "TREE"
    CACHE STRING "Mode for displaying sources in IDEs such as Visual Studio"
)
set_property(
    CACHE CFRAME_SOURCE_DISPLAY_MODE
    PROPERTY STRINGS TREE FLAT DEFAULT
)

option( BUILD_SHARED_LIBS "Toggle whether to build Shared Libraries" ON )


# -----------------------------------------------------------------------------
# Forwards call to specified target function based on a list of argument
# specifications that may include the keywords PUBLIC, PRIVATE, and INTERFACE.
# Separates the list out based on these keywords and calls the lists to the
# target function accordingly.
#
# @param TARGET [in] Name of target to set compile options to.
# @param FUNCTION_NAME Name of the target function to call without the "target_"
#                      prefix, e.g. include_directories, link_libraries, etc.
# @param ARGS [in] List of arguments to the function to set with possible
#                  embedded scope keywords PUBLIC, PRIVATE, INTERFACE.
# @see cframe_build_target
# -----------------------------------------------------------------------------
function( cframe_target_scoped_function TARGET FUNCTION_NAME ARGS )

  get_target_property( type ${TARGET} TYPE )

  set( SCOPES PUBLIC PRIVATE INTERFACE )
  cframe_list_mapify( "${SCOPES}" "${ARGS}" _ARGS )

  foreach( SCOPE ${SCOPES} )

    # Note: For INTERFACE targets, only INTERFACE can be specified as Scope
    if ( ${type} STREQUAL "INTERFACE_LIBRARY" )

      # Functions for compiliation, e.g. compile_options, compile_definitions
      # cannot be set on INTERFACE targets
      string( FIND "${FUNCTION_NAME}" "compile" pos )
      if ( ${pos} GREATER_EQUAL 0 )
        return()
      endif()

      set( ARG_SCOPE INTERFACE )
    else()
      set( ARG_SCOPE ${SCOPE} )
    endif()

    if ( NOT "${${SCOPE}_ARGS}" STREQUAL "" )

      # Have to do a special case for Link Libraries :(
      if ( "${FUNCTION_NAME}" STREQUAL "link_libraries" )
        # Library specifications may have "optimized" or "debug" in them so must
        # specify them all at once for each CONFIG
        set( CONFIGS default optimized debug )
        cframe_list_mapify( "${CONFIGS}" "${${SCOPE}_ARGS}" _LIBS )

        foreach( CONFIG ${CONFIGS} )
          if ( NOT "${${CONFIG}_LIBS}" STREQUAL "" )
            if ( NOT "${CONFIG}" STREQUAL "default" )
              set( LIB_CONFIG "${CONFIG}" )
            endif()
            cmake_language(
                CALL "target_${FUNCTION_NAME}"
                "${TARGET}" "${ARG_SCOPE}" "${LIB_CONFIG}" "${${CONFIG}_LIBS}"
            )
          endif()
        endforeach()

      elseif( ("${FUNCTION_NAME}" STREQUAL "include_directories") OR
              ("${FUNCTION_NAME}" STREQUAL "link_directories") )
        # Note: Need to call for each ARG individually because relative paths
        # in directory-related functons cause an error for some reason.
        # E.g.  include_directories, link_directories
        foreach( ARG ${${SCOPE}_ARGS} )
          cmake_language(
              CALL "target_${FUNCTION_NAME}"
              "${TARGET}" "${ARG_SCOPE}" "${ARG}"
          )
        endforeach()

      else()
        cmake_language(
            CALL "target_${FUNCTION_NAME}"
            "${TARGET}" "${ARG_SCOPE}" "${${SCOPE}_ARGS}"
        )
      endif()

    endif() # Non-empty ${SCOPE}_ARGS

  endforeach()

endfunction() # cframe_target_scoped_function

# -----------------------------------------------------------------------------
# Function to encapsulate the most common standard steps for building a target.
#
# Parameters:
#   TARGET_NAME         - name of the target to build
#   OUTPUT_NAME         - name of the output, if not specified, uses TARGET_NAME
#   PROJECT_LABEL       - the name to display in IDEs, defaults to TARGET_NAME
#   TYPE                - the type of target, either "Library", "Executable", "Interface", "Test" or "Custom"
#   LINK_TYPE           - the linking type for Library targets: STATIC, SHARED, INTERFACE, or DEFAULT (the default)
#   GROUP               - The organization group to place the library in (for IDE build environments)
#   INCLUDE_DIRS        - a list of directories to use to look for include files
#                         with specified scope of PUBLIC, PRIVATE, INTERFACE
#   COMPILE_OPTIONS     - a list of compile options, qualified with PUBLIC, PRIVATE, INTERFACE
#   COMPILE_DEFINITIONS - a list of compile definitions, qualified with PUBLIC, PRIVATE, INTERFACE
#   LINK_DIRS           - a list of directory to use to look up library
#                         dependencies, with specied scope PUBLIC, PRIVATE
#                         or INTERFACE
#   LIBRARIES           - a list of library dependencies
#   HEADERS_PUBLIC      - a list of public header files (that will be installed to the HEADERS_INSTALL_DIR)
#   HEADERS_PRIVATE     - a list of private header files
#   FILES_PUBLIC        - a list of public files (that will be installed to the FILES_INSTALL_DIR)
#   FILES_PRIVATE       - a list of private files
#   SOURCES             - a list of source files
#   PROPERTIES          - a list of properties for the target
#   QT_MOCFILES         - a list of qt moc files
#   QT_UIFILES          - a list of qt ui files
#   QT_QRCFILES         - a list of qt resource files
#   NO_INSTALL          - Flag to indicate not to install the target in the standard location
#   HEADERS_INSTALL_DIR - the directory to install public headers to
#   FILES_INSTALL_DIR   - the directory to install public files to
#   BINARY_INSTALL_DIR  - the directory (prefix) where compiled targets will be installed to
#
# Global variables referenced:
#
#   CFRAME_SOURCE_DISPLAY_MODE - controls how sources are displayed in IDEs: FLAT, TREE, DEFAULT
#   CFRAME_VERBOSITY
#   CFRAME_OS_COMPILE_FLAGS
#   CFRAME_INSTALL_BIN_DIR
#   CFRAME_INSTALL_LIB_DIR
#   CFRAME_INSTALL_DEV_DIR
#
# Global variables defined/modified:
#
#  BUILD_TARGET_${TARGET_NAME} - defines option
#  BUILD_GROUP_${GROUP}        - defines option
#
# @todo Add "Test" target TYPE - Note: CMake uses "TEST" as a keyword :(
# @todo Allow building of both STATIC and SHARED libraries simultaneously
# @todo Add specification of any number of FILTER_TAGS to be used for filtering.
# @todo Add DEFINE_SYMBOL option(?)
# -----------------------------------------------------------------------------
function( cframe_build_target )

  cframe_message( MODE STATUS VERBOSITY 3
      "CFrame: FUNCTION: cframe_build_target"
  )

  # -----------------------------------
  # Set up and parse multiple arguments
  # -----------------------------------
  set( options
       NO_INSTALL
  )
  set( oneValueArgs
       TARGET_NAME
       OUTPUT_NAME
       PROJECT_LABEL
       TYPE
       LINK_TYPE
       GROUP
       HEADERS_INSTALL_DIR
       FILES_INSTALL_DIR
       BINARY_INSTALL_DIR
  )
  set( multiValueArgs
       INCLUDE_DIRS
       COMPILE_OPTIONS
       COMPILE_DEFINITIONS
       LINK_DIRS
       LIBRARIES
       HEADERS_PUBLIC
       HEADERS_PRIVATE
       FILES_PUBLIC
       FILES_PRIVATE
       SOURCES
       PROPERTIES
       QT_MOCFILES
       QT_UIFILES
       QT_QRCFILES
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  cframe_message( MODE STATUS VERBOSITY 4 "Parameters for cframe_build_target:" )
  cframe_message( MODE STATUS VERBOSITY 4 "TARGET_NAME:         ${ARGS_TARGET_NAME}" )
  cframe_message( MODE STATUS VERBOSITY 4 "OUTPUT_NAME:         ${ARGS_OUTPUT_NAME}" )
  cframe_message( MODE STATUS VERBOSITY 4 "PROJECT_LABEL:       ${ARGS_PROJECT_LABEL}" )
  cframe_message( MODE STATUS VERBOSITY 4 "TYPE:                ${ARGS_TYPE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LINK_TYPE:           ${ARGS_LINK_TYPE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "GROUP:               ${ARGS_GROUP}" )
  cframe_message( MODE STATUS VERBOSITY 4 "INCLUDE_DIRS:        ${ARGS_INCLUDE_DIRS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "COMPILE_OPTIONS:     ${ARGS_COMPILE_OPTIONS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "COMPILE_DEFINITIONS: ${ARGS_COMPILE_DEFINITIONS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LINK_DIRS:           ${ARGS_LINK_DIRS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LIBRARIES:           ${ARGS_LIBRARIES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_PUBLIC:      ${ARGS_HEADERS_PUBLIC}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_PRIVATE:     ${ARGS_HEADERS_PRIVATE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_PUBLIC:        ${ARGS_FILES_PUBLIC}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_PRIVATE:       ${ARGS_FILES_PRIVATE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "SOURCES:             ${ARGS_SOURCES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "PROPERTIES:          ${ARGS_PROPERTIES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "QT_MOCFILES:         ${ARGS_QT_MOCFILES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "QT_UIFILES:          ${ARGS_QT_UIFILES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "QT_QRCFILES:         ${ARGS_QT_QRCFILES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "NO_INSTALL:          ${ARGS_NO_INSTALL}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_INSTALL_DIR: ${ARGS_HEADERS_INSTALL_DIR}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_INSTALL_DIR:   ${ARGS_FILES_INSTALL_DIR}" )
  cframe_message( MODE STATUS VERBOSITY 4 "BINARY_INSTALL_DIR:  ${ARGS_BINARY_INSTALL_DIR}" )

  # ------------------------------------
  # Preliminary Build checks and filters
  # ------------------------------------
  # Apply rough build filters: BUILD_${ARGS_TARGET_NAME} takes precedence if it is defined.
  # Otherwise use the value of BUILD_${ARGS_GROUP}
  # If neither exist, the default is to build the target
  # Note: Don't add the option for BUILD_${ARGS_TARGET_NAME}, otherwise it will always
  # be defined and you'd have to turn all the targets off manually if you want to turn off a whole group

  # Apply filtering toggles at the Project level
  if ( NOT DEFINED ARGS_TARGET_NAME )
    cframe_message( MODE WARNING VERBOSITY 1
        "CFrame: cframe_build_target no TARGET_NAME parameter specified"
    )
    return()
  else()
    option( BUILD_TARGET_${ARGS_TARGET_NAME} "Set ON to build target ${ARGS_TARGET_NAME}." ON )
    if ( BUILD_TARGET_${ARGS_TARGET_NAME} MATCHES OFF )
      cframe_message( MODE STATUS VERBOSITY 3
          "CFrame: Skipping target: ${ARGS_TARGET_NAME}"
      )
      return()
    else()
      cframe_message( MODE STATUS VERBOSITY 4
          "CFrame: Building target: ${ARGS_TARGET_NAME}"
      )
    endif()
  endif()

  # Apply filtering toggles at the Group level
  if ( DEFINED ARGS_GROUP )
    option( BUILD_GROUP_${ARGS_GROUP} "Set ON to build group ${ARGS_GROUP}." ON )
    if ( BUILD_GROUP_${ARGS_GROUP} MATCHES OFF )
      cframe_message( MODE STATUS VERBOSITY 3
          "CFrame: Skipping group: ${ARGS_GROUP}"
      )
      return()
    else()
      cframe_message( MODE STATUS VERBOSITY 4
          "CFrame: Building group: ${ARGS_GROUP}"
      )
    endif()
  endif()

  # Check for valid Type
  string( TOUPPER ${ARGS_TYPE} ARGS_TYPE )
  if ( NOT DEFINED ARGS_TYPE )
    cframe_message( MODE WARNING VERBOSITY 1
        "CFrame: cframe_build_target no TYPE parameter specified"
    )
    return()
  elseif ( NOT ( (${ARGS_TYPE} STREQUAL "LIBRARY") OR
                 (${ARGS_TYPE} STREQUAL "INTERFACE") OR
                 (${ARGS_TYPE} STREQUAL "EXECUTABLE") OR
##                 (${ARGS_TYPE} STREQUAL "TEST") OR
                 (${ARGS_TYPE} STREQUAL "CUSTOM") ) )
    cframe_message( MODE FATAL_ERROR VERBOSITY 0
        "CFrame: cframe_build_target invalid type: ${ARGS_TYPE}"
    )
    return()
  endif()

  # Apply fine-grained build filters on a per file level using the CFRAME_FILE_EXCLUDE_LIST
##  cframe_filter_list( ARGS_HEADERS_PUBLIC  CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_HEADERS_PRIVATE CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_FILES_PUBLIC    CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_FILES_PRIVATE   CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_SOURCES         CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_QT_MOCFILES     CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_QT_UIFILES      CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( ARGS_QT5_QRCFILES    CFRAME_FILE_EXCLUDE_LIST )

  # ----------------------
  # Qt specific processing
  # ----------------------

  # Process Qt MOC Files
  if ( ARGS_QT_MOCFILES )
    if ( QT_VERSION_5 )
      qt5_wrap_cpp(
          ${ARGS_TARGET_NAME}_MOCSOURCES
          ${ARGS_QT_MOCFILES}
          TARGET ${ARGS_TARGET_NAME}
      )
    else()
      qt_wrap_cpp(
          ${ARGS_TARGET_NAME}
          ${ARGS_TARGET_NAME}_MOCSOURCES
          ${ARGS_QT_MOCFILES}
      )
    endif()

    source_group(
        \\generated\\moc_files FILES
        ${${ARGS_TARGET_NAME}_MOCSOURCES}
    )

    if ( ARGS_DEBUG )
      cframe_message( MODE STATUS VERBOSITY 3
          "CFrame: ${ARGS_TARGET_NAME} Generated MOC Files: "
          "${${ARGS_TARGET_NAME}_MOCSOURCES}"
      )
    endif()
  endif()

  # Process Qt UI Files
  if ( DEFINED ARGS_QT_UIFILES )
    if ( QT_VERSION_5 )
      foreach( UIFILE ${ARGS_QT_UIFILES} )
        qt5_wrap_ui( ${ARGS_TARGET_NAME}_UIHEADERS ${UIFILE} )
      endforeach()
    else()
      qt_wrap_ui(
          ${ARGS_TARGET_NAME}
          ${ARGS_TARGET_NAME}_UISOURCES
          ${ARGS_TARGET_NAME}_UIHEADERS
          ${ARGS_QT_UIFILES}
      )
    endif()

    source_group(
        \\ui_files FILES
        ${ARGS_QT_UIFILES}
    )
    source_group(
        \\generated\\ui_files FILES
        ${${ARGS_TARGET_NAME}_UIHEADERS}
        ${${ARGS_TARGET_NAME}_UISOURCES}
    )

    cframe_message( MODE STATUS VERBOSITY 3
        "CFrame: ${ARGS_TARGET_NAME} Generated UI Files: "
        "${${ARGS_TARGET_NAME}_UIHEADERS}"
        "${${ARGS_TARGET_NAME}_UISOURCES}"
    )
  endif()

  # Process Qt QRC Files
  if ( DEFINED ARGS_QT_QRCFILES )
    if ( QT_VERSION_4 )
      qt4_add_resources(
          ${ARGS_TARGET_NAME}_RESOURCES
          ${ARGS_QT_QRCFILES}
      )
    else()
      qt5_add_resources(
          ${ARGS_TARGET_NAME}_RESOURCES
          ${ARGS_QT_QRCFILES}
      )
    endif()

    source_group(
        \\qrc_files FILES
        ${ARGS_TARGET_NAME_QT_QRCFILES}
    )
    source_group(
        \\generated\\qrc_files FILES
        ${${ARGS_TARGET_NAME}_RESOURCES}
    )

    cframe_message( MODE STATUS VERBOSITY 3
        "${ARGS_TARGET_NAME} Generated Qt Resource Files: "
        "${${ARGS_TARGET_NAME}_RESOURCES}"
    )
  endif()

  # --------------------------------
  # Massaging of dependent libraries
  # --------------------------------
  if ( DEFINED ARGS_LINK_TYPE )
    if ( "${ARGS_LINK_TYPE}" STREQUAL "SHARED" )
      set( LINK_TYPE SHARED )
    elseif( "${ARGS_LINK_TYPE}" STREQUAL "STATIC" )
      set( LINK_TYPE STATIC )
    elseif( "${ARGS_LINK_TYPE}" STREQUAL "INTERFACE" )
      set( LINK_TYPE INTERFACE )
    endif()
  endif()
  if ( NOT DEFINED LINK_TYPE )
    if ( BUILD_SHARED_LIBS )
      set( LINK_TYPE SHARED )
    else()
      set( LINK_TYPE STATIC )
    endif()
  endif()

  # -----------------
  # Set up the Target
  # -----------------
  set( ${ARGS_TARGET_NAME}_ALL_FILES
      ${ARGS_HEADERS_PUBLIC}
      ${ARGS_HEADERS_PRIVATE}
      ${ARGS_FILES_PUBLIC}
      ${ARGS_FILES_PRIVATE}
      ${ARGS_SOURCES}
      ${ARGS_QT_MOCFILES}
      ${${ARGS_TARGET_NAME}_MOCSOURCES}
      ${ARGS_QT_UIFILES}
      ${${ARGS_TARGET_NAME}_UIHEADERS}
      ${${ARGS_TARGET_NAME}_UISOURCES}
      ${ARGS_QT_QRCFILES}
      ${${ARGS_TARGET_NAME}_RESOURCES}
  )

  set( ${ARGS_TARGET_NAME}_ALL_SOURCES
      ${ARGS_SOURCES}
      ${${ARGS_TARGET_NAME}_MOCSOURCES}
      ${${ARGS_TARGET_NAME}_UISOURCES}
      ${${ARGS_TARGET_NAME}_RESOURCES}
  )

  # If no sources (either specified or generated) were found, specify target
  # type as "INTERFACE"
  if ( ("${${ARGS_TARGET_NAME}_ALL_SOURCES}" STREQUAL "") AND
       ("${ARGS_TYPE}" STREQUAL "LIBRARY") )
    set( ARGS_TYPE "INTERFACE" )
    cframe_message( MODE STATUS VERBOSITY 1
        "CFrame: Automatically setting target ${ARGS_TARGET_NAME}
           as Custom type because no sources (neither specified nor generated) were
           found."
    )
  endif() # Automatic conversion to "Custom" type


  if ( "${CFRAME_SOURCE_DISPLAY_MODE}" STREQUAL "FLAT" )
    source_group(
        \\ FILES
        ${ARGS_HEADERS_PUBLIC}
        ${ARGS_HEADERS_PRIVATE}
        ${ARGS_SOURCES}
        ${ARGS_FILES_PUBLIC}
        ${ARGS_FILES_PRIVATE}
    )
  elseif ( "${CFRAME_SOURCE_DISPLAY_MODE}" STREQUAL "TREE" )
    # Generated files that are output outside the source tree  (e.g. in the
    # ${CMAKE_CURRENT_BINARY_DIR} ) will cause an error, so exclude them
    foreach( file
        ${ARGS_HEADERS_PUBLIC}
        ${ARGS_HEADERS_PRIVATE}
        ${ARGS_SOURCES}
        ${ARGS_FILES_PUBLIC}
        ${ARGS_FILES_PRIVATE}
    )
      get_filename_component( abs_path ${file} REALPATH )
      file( RELATIVE_PATH rel_path ${CMAKE_CURRENT_SOURCE_DIR} ${abs_path} )
      string( FIND ${rel_path} ".." result )
      if ( ${result} EQUAL -1 )
        list( APPEND display_files ${file} )
      endif()
    endforeach()

    source_group(
        TREE ${CMAKE_CURRENT_SOURCE_DIR}
        FILES
            ${display_files}
    )
  endif()

  if ( "${ARGS_TYPE}" STREQUAL "LIBRARY" )

    # Only add the static definition for the library if a special link type isn't specified
    if ( DEFINED ARGS_LINK_TYPE )
      if ( ARGS_LINK_TYPE STREQUAL "STATIC" )
        add_definitions( -D${ARGS_TARGET_NAME}_STATIC )
      endif()
    elseif ( NOT BUILD_SHARED_LIBS )
      add_definitions( -D${ARGS_TARGET_NAME}_STATIC )
    endif()

    add_library(
        ${ARGS_TARGET_NAME} ${LINK_TYPE}
        ${${ARGS_TARGET_NAME}_ALL_FILES}
    )
    if ( "LINK_TYPE" STREQUAL "DYNAMIC" )
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          LINK_DEPENDS_NO_SHARED TRUE
      )
    endif()

##  elseif( ("${ARGS_TYPE}" STREQUAL "EXECUTABLE") OR
##          ("${ARGS_TYPE}" STREQUAL "TEST") )
  elseif( "${ARGS_TYPE}" STREQUAL "EXECUTABLE" )

    add_executable(
        ${ARGS_TARGET_NAME}
        ${${ARGS_TARGET_NAME}_ALL_FILES}
    )

  elseif( "${ARGS_TYPE}" STREQUAL "INTERFACE" )
    add_library( ${ARGS_TARGET_NAME} INTERFACE )

    foreach( INTERFACE_FILE ${${ARGS_TARGET_NAME}_ALL_FILES} )
      get_filename_component( ABS_FILE_PATH ${INTERFACE_FILE} ABSOLUTE )
      list( APPEND INTERFACE_FILES ${ABS_FILE_PATH} )
    endforeach()

    set_property(
        TARGET ${ARGS_TARGET_NAME}
        PROPERTY
            INTERFACE_SOURCES
                ${INTERFACE_FILES}
    )
    ## HACK: Interfaces don't show up in IDEs, so make a custom target
    message( STATUS
        "CFrame: Adding custom target for interface: "
        "${ARGS_TARGET_NAME}_display"
    )
    add_custom_target( ${ARGS_TARGET_NAME}_display
        SOURCES
            ${ARGS_HEADERS_PUBLIC}
            ${ARGS_FILES_PUBLIC}
            ${ARGS_HEADERS_PRIVATE}
            ${ARGS_FILES_PRIVATE}
    )

##    if ( "${ARGS_TYPE}" STREQUAL "TEST" )
##      get_target_property(
##          TEST_EXECUTABLE ${ARGS_TARGET_NAME} LOCATION
##      )
##
##      string( REGEX
##              REPLACE "\\$\\(.*\\)" "\${CTEST_CONFIGURATION_TYPE}"
##              TEST_EXECUTABLE "${TEST_EXECUTABLE}"
##      )
##
##      add_test( ${TESTNAME} ${TEST_EXECUTABLE} )
##    endif() # Test type

  elseif( "${ARGS_TYPE}" STREQUAL "CUSTOM" )
    add_custom_target(
        ${ARGS_TARGET_NAME}
        SOURCES
            ${${ARGS_TARGET_NAME}_ALL_FILES}
    )
  endif() # Custom type

  # Set the output name if it is defined and different than the target name
  # And set the DEFINE_SYMBOL to the OUTPUT_NAME to ensure consistency with the actual output name.
  if ( (DEFINED ARGS_OUTPUT_NAME)
       AND
       (NOT ("${ARGS_TARGET_NAME}" STREQUAL "${ARGS_OUTPUT_NAME}")) )
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          OUTPUT_NAME   ${ARGS_OUTPUT_NAME}
          DEFINE_SYMBOL ${ARGS_OUTPUT_NAME}_EXPORTS
      )
  endif()

  if ( DEFINED ARGS_PROJECT_LABEL )
    if( NOT "${ARGS_TYPE}" STREQUAL "INTERFACE" )
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          PROJECT_LABEL   ${ARGS_PROJECT_LABEL}
      )
    else()
      set_target_properties(
          ${ARGS_TARGET_NAME}_display PROPERTIES
          PROJECT_LABEL   ${ARGS_PROJECT_LABEL}
      )
    endif()
  endif()

  if ( "${LINK_TYPE}" STREQUAL "STATIC" )
    set(
        ARGS_COMPILE_DEFINITIONS
        "${ARGS_COMPILE_DEFINITIONS}"
        PUBLIC
            ${ARGS_TARGET_NAME}_STATIC
    )
  endif()

  # ----------------------------------------------------------------
  # Set Target Options, Definitions, Include and Link specifications
  # Usually set by the CMake target_* functions.
  # ----------------------------------------------------------------
  if ( DEFINED ARGS_COMPILE_OPTIONS )
    cframe_target_scoped_function(
        ${ARGS_TARGET_NAME} "compile_options" "${ARGS_COMPILE_OPTIONS}"
    )
  endif()

  if ( DEFINED ARGS_COMPILE_DEFINITIONS )
    cframe_target_scoped_function(
        ${ARGS_TARGET_NAME} "compile_definitions" "${ARGS_COMPILE_DEFINITIONS}"
    )
  endif()

  if ( "${ARGS_TYPE}" STREQUAL "INTERFACE" )
    target_compile_definitions(
      ${ARGS_TARGET_NAME} INTERFACE $<IF:$<CONFIG:DEBUG>,DEBUG,NDEBUG>
    )
  elseif ( NOT "${ARGS_TYPE}" STREQUAL "CUSTOM" )
    target_compile_definitions(
      ${ARGS_TARGET_NAME} PUBLIC $<IF:$<CONFIG:DEBUG>,DEBUG,NDEBUG>
    )
  endif()

  if ( DEFINED ARGS_INCLUDE_DIRS )
    cframe_target_scoped_function(
        ${ARGS_TARGET_NAME} "include_directories" "${ARGS_INCLUDE_DIRS}"
    )
  endif()

  if ( DEFINED ARGS_LINK_DIRS )
    cframe_target_scoped_function(
        ${ARGS_TARGET_NAME} "link_directories" "${ARGS_LINK_DIRS}"
    )
  endif()

  if( DEFINED ARGS_LIBRARIES )
    cframe_target_scoped_function(
        ${ARGS_TARGET_NAME} "link_libraries" "${ARGS_LIBRARIES}"
    )
  endif()

  # -----------------------------------
  # Set various other target properties
  # -----------------------------------
  set_property(
      SOURCE ${ARGS_HEADERS_PUBLIC}
      PROPERTY PUBLIC_HEADER
  )

  if( NOT "${ARGS_TYPE}" STREQUAL "INTERFACE" )
    set_target_properties(
        ${ARGS_TARGET_NAME}
        PROPERTIES
            DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
    )
  endif()

  if ( DEFINED ARGS_PROPERTIES )
    set_target_properties(
        ${ARGS_TARGET_NAME}
        PROPERTIES
            ${ARGS_PROPERTIES}
    )
  endif()

  # set the target group
  if ( DEFINED ARGS_GROUP )
    if( NOT "${ARGS_TYPE}" STREQUAL "INTERFACE" )
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          FOLDER ${ARGS_GROUP}
      )
    else()
      set_target_properties(
          ${ARGS_TARGET_NAME}_display PROPERTIES
          FOLDER ${ARGS_GROUP}
      )
    endif()
  endif()

  # set PIC on shared libraries
  if ( NOT WIN32 )
    if( NOT "${ARGS_TYPE}" STREQUAL "INTERFACE" )
      # Ensure that static libraries use position independent code on Linux
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          POSITION_INDEPENDENT_CODE ON
      )
    endif()
  endif()

  # install standard target artifacts
  if ( NOT ARGS_NO_INSTALL AND
       NOT "${ARGS_TYPE}" STREQUAL "CUSTOM" )
      if ( DEFINED ARGS_BINARY_INSTALL_DIR )
        set( BINARY_INSTALL_PREFIX ${ARGS_BINARY_INSTALL_DIR}/ )
      endif()
      install(
          TARGETS ${ARGS_TARGET_NAME}
          RUNTIME DESTINATION ${BINARY_INSTALL_PREFIX}${CFRAME_INSTALL_BIN_DIR} COMPONENT Runtime
          LIBRARY DESTINATION ${BINARY_INSTALL_PREFIX}${CFRAME_INSTALL_LIB_DIR} COMPONENT Runtime
          ARCHIVE DESTINATION ${BINARY_INSTALL_PREFIX}${CFRAME_INSTALL_DEV_DIR} COMPONENT Development
      )
  endif()

  # install public headers
  if ( DEFINED ARGS_HEADERS_INSTALL_DIR )
      install(
          FILES ${ARGS_HEADERS_PUBLIC}
          DESTINATION ${ARGS_HEADERS_INSTALL_DIR}
      )
  endif()

  # install public files
  if ( DEFINED ARGS_FILES_PUBLIC AND
       DEFINED ARGS_FILES_INSTALL_DIR )
    install(
        FILES ${ARGS_FILES_PUBLIC}
        DESTINATION ${ARGS_FILES_INSTALL_DIR}
    )
  endif()

endfunction() # cframe_build_target


# -----------------------------------------------------------------------------
# Setup the variables for the subdirectory containing source files for a target.
# - PREFIX:   The prefix to be prepended to the name of each variable.
# - SUBDIR:   The subdirectory of the current source directory containing files.
# - FOLDER:   The folder to display the files in (for IDE-based environments).
# - HEADERS_PUBLIC:      Public header files.
# - HEADERS_PRIVATE:     Private header files.
# - HEADERS_INSTALL_DIR: The directory where to install HEADERS_PUBLIC files.
# - SOURCES:             Source files.
# - FILES_PUBLIC:        Miscellaneous public files.
# - FILES_PRIVATE        Miscellaneous private files
# - FILES_INSTALL_DIR:  The directory where to install FILES_PUBLIC files.
# -----------------------------------------------------------------------------
function( cframe_target_subdir )

  # -----------------------------------
  # Set up and parse multiple arguments
  # -----------------------------------
  set( options
  )
  set( oneValueArgs
      PREFIX
      SUBDIR
      FOLDER
      HEADERS_INSTALL_DIR
      FILES_INSTALL_DIR
  )
  set( multiValueArgs
     HEADERS_PUBLIC
     HEADERS_PRIVATE
     SOURCES
     FILES_PUBLIC
     FILES_PRIVATE
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  set( CATEGORIES
      HEADERS_PUBLIC
      HEADERS_PRIVATE
      SOURCES
      FILES_PUBLIC
      FILES_PRIVATE
  )

  if ( NOT ARGS_PREFIX )
    message( SEND_ERROR
        "cframe_target_subdir: No PREFIX argument provided."
    )
    return()
  endif()
  if ( NOT ARGS_SUBDIR )
    message( SEND_ERROR
        "cframe_target_subdir: No SUBDIR argument provided."
    )
    return()
  endif()

  foreach( CATEGORY ${CATEGORIES} )
    foreach( FILE ${ARGS_${CATEGORY}} )
      list( APPEND ${ARGS_PREFIX}_${CATEGORY} ${ARGS_SUBDIR}/${FILE} )
    endforeach() # CATEGORY Files

    set(
        ${ARGS_PREFIX}_${CATEGORY} ${${ARGS_PREFIX}_${CATEGORY}}
        PARENT_SCOPE
    )

    if ( ARGS_FOLDER )
      source_group(
          ${ARGS_FOLDER} FILES
          ${${ARGS_PREFIX}_${CATEGORY}}
      )
    else()
      source_group(
          TREE ${CMAKE_CURRENT_SOURCE_DIR}
          FILES
              ${${ARGS_PREFIX}_${CATEGORY}}
      )
    endif()

  endforeach() # CATEGORIES

endfunction() # cframe_target_subdir

# -----------------------------------------------------------------------------
# Function to create a project and installation based on a directory and
# preserve its subdirectory structure.
#
# Parameters:
#   TARGET_NAME         - name of the target to build
#   PROJECT_LABEL       - the name to display in IDEs, defaults to TARGET_NAME
#   GROUP               - The organization group to place the library in
#                         (for IDE build environments)
#   RELATIVE_DIR        - The directory from which files should be relative to.
#                         Defaults to ${CMAKE_CURRENT_SOURCE_DIR}
#   FILE_PATTERN        - The pattern to use for including files. Defaults to *.
#   EXCLUDE_FILTERS     - Regular expressions to filter files out of discovered files.
#   INSTALL_DIR         - the directory to install files to
#
# Global variables defined/modified:
#
#  BUILD_TARGET_${TARGET_NAME} - defines option
#  BUILD_GROUP_${GROUP}        - defines option
# -----------------------------------------------------------------------------
function( cframe_directory_target )

  cframe_message( MODE STATUS VERBOSITY 3
      "CFrame: FUNCTION: cframe_directory_target"
  )

  # -----------------------------------
  # Set up and parse multiple arguments
  # -----------------------------------
  set( options
  )
  set( oneValueArgs
       TARGET_NAME
       PROJECT_LABEL
       GROUP
       RELATIVE_DIR
       FILE_PATTERN
       INSTALL_DIR
  )
  set( multiValueArgs
       EXCLUDE_FILTERS
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  if ( NOT DEFINED ARGS_RELATIVE_DIR )
    set( ARGS_RELATIVE_DIR ${CMAKE_CURRENT_SOURCE_DIR} )
  endif()
  if ( NOT DEFINED ARGS_FILE_PATTERN )
    set( ARGS_FILE_PATTERN "*")
  endif()

  file(
      GLOB_RECURSE ALL_FILES
      LIST_DIRECTORIES FALSE
      RELATIVE "${ARGS_RELATIVE_DIR}"
      "${ARGS_FILE_PATTERN}"
  )

  # Filter files
  foreach( FILTER ${ARGS_EXCLUDE_FILTERS} )
    list(
        FILTER ALL_FILES
        EXCLUDE REGEX "${FILTER}"
    )
  endforeach() # ARGS_EXCLUDE_FILTERS loop

  source_group(
      TREE "${ARGS_RELATIVE_DIR}"
      FILES "${ALL_FILES}"
  )

  # Based on:
  # https://stackoverflow.com/questions/11096471/how-can-i-install-a-hierarchy-of-files-using-cmake
  if ( DEFINED ARGS_INSTALL_DIR )

    file( GLOB items "${ARGS_RELATIVE_DIR}/${ARGS_FILE_PATTERN}" )

    foreach( item ${items} )
      if ( IS_DIRECTORY ${item} )
        list( APPEND dirsToDeploy ${item} )
      else()
        list( APPEND filesToDeploy ${item} )
      endif()
    endforeach()

    install(
        DIRECTORY ${dirsToDeploy}
        DESTINATION ${ARGS_INSTALL_DIR}
    )
    install(
        FILES ${filesToDeploy}
        DESTINATION ${ARGS_INSTALL_DIR}
    )
  endif() # ARGS_INSTALL_DIR Defined

  cframe_build_target(
      TARGET_NAME   "${ARGS_TARGET_NAME}"
      PROJECT_LABEL "${ARGS_PROJECT_LABEL}"
      TYPE          Custom
      GROUP         "${ARGS_GROUP}"
      FILES_PUBLIC
          ${ALL_FILES}
  )

endfunction() # cframe_directory_target
