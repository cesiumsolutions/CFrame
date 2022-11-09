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
# Forwards call to target_include_directories based on a list of directory
# specifications that may include the keywords PUBLIC, PRIVATE, and INTERFACE.
# Separates the list out based on these keywords and calls the lists to
# target_include_directories accordingly.
#
# @param TARGET [in] Name of target to add include directories to.
# @param INCLUDE_DIRS [in] List of directories to include with possible embedded
#                          scope keywords PUBLIC, PRIVATE, INTERFACE.
# @see cframe_build_target
# -----------------------------------------------------------------------------
function( cframe_target_include_directories TARGET INCLUDE_DIRS )

  set( scope PRIVATE )

  foreach( entry ${INCLUDE_DIRS} )

    if ( (${entry} STREQUAL "PUBLIC") OR
         (${entry} STREQUAL "PRIVATE") OR
         (${entry} STREQUAL "INTERFACE") )
      set( scope ${entry} )
    else()
      target_include_directories( ${TARGET} "${scope}" "${entry}" )
    endif()

  endforeach()

endfunction() # cframe_target_include_directories

# -----------------------------------------------------------------------------
# Function to encapsulate the most common standard steps for building a target.
#
# Parameters:
#   TARGET_NAME         - name of the target to build
#   OUTPUT_NAME         - name of the output, if not specified, uses TARGET_NAME
#   PROJECT_LABEL       - the name to display in IDEs, defaults to TARGET_NAME
#   TYPE                - the type of target, either "Library", "Executable", "Interface", "Test" or "Custom"
#   LINK_TYPE           - the linking type for Library targets: STATIC, SHARED, or DEFAULT (the default)
#   GROUP               - The organization group to place the library in (for IDE build environments)
#   INCLUDE_DIRS        - a list of directories to include
#   DEFINES             - a list of preprocessor definitions
#   COMPILE_FLAGS       - a list of compilation flags
#   LINK_FLAGS          - a list of link flags
#   LIBRARY_DIRS        - a list of library path dirs
#   LIBRARIES           - a list of library dependencies
#   HEADERS_PUBLIC      - a list of public header files (that will be installed to the HEADERS_INSTALL_DIR)
#   HEADERS_PRIVATE     - a list of private header files
#   FILES_PUBLIC        - a list of public files (that will be installed to the FILES_INSTALL_DIR)
#   FILES_PRIVATE       - a list of private files
#   SOURCES             - a list of source files
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
       DEFINES
       COMPILE_FLAGS
       LINK_FLAGS
       LIBRARY_DIRS
       LIBRARIES
       HEADERS_PUBLIC
       HEADERS_PRIVATE
       FILES_PUBLIC
       FILES_PRIVATE
       SOURCES
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
  cframe_message( MODE STATUS VERBOSITY 4 "DEFINES:             ${ARGS_DEFINES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "COMPILE_FLAGS:       ${ARGS_COMPILE_FLAGS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LINK_FLAGS:          ${ARGS_LINK_FLAGS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LIBRARY_DIRS:        ${ARGS_LIBRARY_DIRS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LIBRARIES:           ${ARGS_LIBRARIES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_PUBLIC:      ${ARGS_HEADERS_PUBLIC}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_PRIVATE:     ${ARGS_HEADERS_PRIVATE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_PUBLIC:        ${ARGS_FILES_PUBLIC}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_PRIVATE:       ${ARGS_FILES_PRIVATE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "SOURCES:             ${ARGS_SOURCES}" )
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

  if ( DEFINED ARGS_DEFINES )
      add_definitions( ${ARGS_DEFINES} )
  endif()

  # ----------------------
  # Qt specific processing
  # ----------------------

  # Process Qt MOC Files
  if ( ARGS_QT_MOCFILES )
    qt_wrap_cpp(
        ${ARGS_TARGET_NAME}
        ${ARGS_TARGET_NAME}_MOCSOURCES
        ${ARGS_QT_MOCFILES}
    )

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
  if ( DEFINED ARGS_LIBRARY_DIRS )
    link_directories( ${ARGS_LIBRARY_DIRS} )
  endif()

  if ( DEFINED ARGS_LINK_TYPE )
    if ( ARGS_LINK_TYPE STREQUAL "SHARED" )
      set( LINK_TYPE SHARED )
    elseif( ARGS_LINK_TYPE STREQUAL "STATIC" )
      set( LINK_TYPE STATIC )
    elseif( ARGS_LINK_TYPE STREQUAL "INTERFACE" )
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

  # When building static libraries, add the corresponding compile definition for each of the linked in libraries
  # This requires that:
  #   - all libraries be specified that will be linked even though CMake automatically links in
  #     derivative dependent libraries (only when building shared libs)
  #   - the library names use the <libname>_STATIC to indicate static linking
  #   - the ARGS_LIBRARIES doesn't use full paths for its elements
  if ( NOT BUILD_SHARED_LIBS )
    foreach( TARGET_LIB ${ARGS_LIBRARIES} )
      if ( NOT (TARGET_LIB STREQUAL "optimized") AND NOT (TARGET_LIB STREQUAL "debug") )
        add_definitions( -D${TARGET_LIB}_STATIC )
      endif()
    endforeach()
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

  # If no sources (either specified or generated) were found, sppecify target
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
    if ( "ARGS_LINK_TYPE" STREQUAL "DYNAMIC" )
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
    set_property(
        TARGET ${ARGS_TARGET_NAME}
        PROPERTY
            INTERFACE_SOURCES
                ${ARGS_HEADERS_PUBLIC}
                ${ARGS_FILES_PUBLIC}
                ${ARGS_HEADERS_PRIVATE}
                ${ARGS_FILES_PRIVATE}
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

  if( DEFINED ARGS_LIBRARIES )
    if ( "${ARGS_TYPE}" STREQUAL "INTERFACE")
      target_link_libraries(
          ${ARGS_TARGET_NAME} INTERFACE
          ${ARGS_LIBRARIES}
      )
    else()
      target_link_libraries(
          ${ARGS_TARGET_NAME}
          ${ARGS_LIBRARIES}
      )
    endif()
  endif()

  # -----------------------
  # Set include directories
  # -----------------------
  if ( DEFINED ARGS_INCLUDE_DIRS )
    cframe_target_include_directories(
        ${ARGS_TARGET_NAME}
        "${ARGS_INCLUDE_DIRS}"
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
  if ( NOT WIN32 AND NOT BUILD_SHARED_LIBS )
    if( NOT "${ARGS_TYPE}" STREQUAL "INTERFACE" )
      # Ensure that static libraries use position independent code on Linux
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          POSITION_INDEPENDENT_CODE ON
      )
    endif()
  endif()

  # set target compile flags
  if ( DEFINED ARGS_COMPILE_FLAGS OR DEFINED CFRAME_OS_COMPILE_FLAGS )
      set_target_properties(
          ${ARGS_TARGET_NAME} PROPERTIES
          COMPILE_FLAGS
              ${ARGS_COMPILE_FLAGS}
              ${CFRAME_OS_COMPILE_FLAGS}
      )
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
