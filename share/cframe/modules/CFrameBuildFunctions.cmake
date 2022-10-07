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

  set( keyword PRIVATE )
  set( includeDirs "" )

  foreach( entry ${INCLUDE_DIRS} )

    if ( (${entry} STREQUAL "PUBLIC") OR
         (${entry} STREQUAL "PRIVATE") OR
         (${entry} STREQUAL "INTERFACE") )
      list( LENGTH includeDirs numDirs )
      if ( ${numDirs} GREATER 0 )
        cframe_message(
            MODE STATUS VERBOSITY 3 TAGS CFrame BuildFunctions
            "cframe_target_include_directories( ${TARGET} ${keyword} ${includeDirs}"
        )
        target_include_directories( ${TARGET} "${keyword}" "${includeDirs}" )
      endif()

      set( keyword ${entry} )
      set( includeDirs "" )
    else()
      list( APPEND includeDirs ${entry} )
    endif()

  endforeach()

  # Handle residual values
  list( LENGTH includeDirs numDirs )
  if ( ${numDirs} GREATER 0 )
    cframe_message(
        MODE STATUS VERBOSITY 3 TAGS CFrame BuildFunctions
        "cframe_target_include_directories( ${TARGET} ${keyword} ${includeDirs}"
    )
    target_include_directories( ${TARGET} "${keyword}" "${includeDirs}" )
  endif()

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
      cframe_build_target
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  cframe_message( MODE STATUS VERBOSITY 4 "Parameters for cframe_build_target:" )
  cframe_message( MODE STATUS VERBOSITY 4 "TARGET_NAME:         ${cframe_build_target_TARGET_NAME}" )
  cframe_message( MODE STATUS VERBOSITY 4 "OUTPUT_NAME:         ${cframe_build_target_OUTPUT_NAME}" )
  cframe_message( MODE STATUS VERBOSITY 4 "PROJECT_LABEL:       ${cframe_build_target_PROJECT_LABEL}" )
  cframe_message( MODE STATUS VERBOSITY 4 "TYPE:                ${cframe_build_target_TYPE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LINK_TYPE:           ${cframe_build_target_LINK_TYPE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "GROUP:               ${cframe_build_target_GROUP}" )
  cframe_message( MODE STATUS VERBOSITY 4 "INCLUDE_DIRS:        ${cframe_build_target_INCLUDE_DIRS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "DEFINES:             ${cframe_build_target_DEFINES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "COMPILE_FLAGS:       ${cframe_build_target_COMPILE_FLAGS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LINK_FLAGS:          ${cframe_build_target_LINK_FLAGS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LIBRARY_DIRS:        ${cframe_build_target_LIBRARY_DIRS}" )
  cframe_message( MODE STATUS VERBOSITY 4 "LIBRARIES:           ${cframe_build_target_LIBRARIES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_PUBLIC:      ${cframe_build_target_HEADERS_PUBLIC}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_PRIVATE:     ${cframe_build_target_HEADERS_PRIVATE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_PUBLIC:        ${cframe_build_target_FILES_PUBLIC}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_PRIVATE:       ${cframe_build_target_FILES_PRIVATE}" )
  cframe_message( MODE STATUS VERBOSITY 4 "SOURCES:             ${cframe_build_target_SOURCES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "QT_MOCFILES:         ${cframe_build_target_QT_MOCFILES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "QT_UIFILES:          ${cframe_build_target_QT_UIFILES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "QT_QRCFILES:         ${cframe_build_target_QT_QRCFILES}" )
  cframe_message( MODE STATUS VERBOSITY 4 "NO_INSTALL:          ${cframe_build_target_NO_INSTALL}" )
  cframe_message( MODE STATUS VERBOSITY 4 "HEADERS_INSTALL_DIR: ${cframe_build_target_HEADERS_INSTALL_DIR}" )
  cframe_message( MODE STATUS VERBOSITY 4 "FILES_INSTALL_DIR:   ${cframe_build_target_FILES_INSTALL_DIR}" )
  cframe_message( MODE STATUS VERBOSITY 4 "BINARY_INSTALL_DIR:  ${cframe_build_target_BINARY_INSTALL_DIR}" )

  # ------------------------------------
  # Preliminary Build checks and filters
  # ------------------------------------
  # Apply rough build filters: BUILD_${cframe_build_target_TARGET_NAME} takes precedence if it is defined.
  # Otherwise use the value of BUILD_${cframe_build_target_GROUP}
  # If neither exist, the default is to build the target
  # Note: Don't add the option for BUILD_${cframe_build_target_TARGET_NAME}, otherwise it will always
  # be defined and you'd have to turn all the targets off manually if you want to turn off a whole group

  # Apply filtering toggles at the Project level
  if ( NOT DEFINED cframe_build_target_TARGET_NAME )
    cframe_message( MODE WARNING VERBOSITY 1
        "CFrame: cframe_build_target no TARGET_NAME parameter specified"
    )
    return()
  else()
    option( BUILD_TARGET_${cframe_build_target_TARGET_NAME} "Set ON to build target ${cframe_build_target_TARGET_NAME}." ON )
    if ( BUILD_TARGET_${cframe_build_target_TARGET_NAME} MATCHES OFF )
      cframe_message( MODE STATUS VERBOSITY 3
          "CFrame: Skipping target: ${cframe_build_target_TARGET_NAME}"
      )
      return()
    else()
      cframe_message( MODE STATUS VERBOSITY 4
          "CFrame: Building target: ${cframe_build_target_TARGET_NAME}"
      )
    endif()
  endif()

  # Apply filtering toggles at the Group level
  if ( DEFINED cframe_build_target_GROUP )
    option( BUILD_GROUP_${cframe_build_target_GROUP} "Set ON to build group ${cframe_build_target_GROUP}." ON )
    if ( BUILD_GROUP_${cframe_build_target_GROUP} MATCHES OFF )
      cframe_message( MODE STATUS VERBOSITY 3
          "CFrame: Skipping group: ${cframe_build_target_GROUP}"
      )
      return()
    else()
      cframe_message( MODE STATUS VERBOSITY 4
          "CFrame: Building group: ${cframe_build_target_GROUP}"
      )
    endif()
  endif()

  # Check for valid Type
  string( TOUPPER ${cframe_build_target_TYPE} cframe_build_target_TYPE )
  if ( NOT DEFINED cframe_build_target_TYPE )
    cframe_message( MODE WARNING VERBOSITY 1
        "CFrame: cframe_build_target no TYPE parameter specified"
    )
    return()
  elseif ( NOT ( (${cframe_build_target_TYPE} STREQUAL "LIBRARY") OR
                 (${cframe_build_target_TYPE} STREQUAL "INTERFACE") OR
                 (${cframe_build_target_TYPE} STREQUAL "EXECUTABLE") OR
##                 (${cframe_build_target_TYPE} STREQUAL "TEST") OR
                 (${cframe_build_target_TYPE} STREQUAL "CUSTOM") ) )
    cframe_message( MODE FATAL_ERROR VERBOSITY 0
        "CFrame: cframe_build_target invalid type: ${cframe_build_target_TYPE}"
    )
    return()
  endif()

  # Make some shorter more convenient names
  set( _TARGET_NAME          ${cframe_build_target_TARGET_NAME} )
  set( _OUTPUT_NAME          ${cframe_build_target_OUTPUT_NAME} )
  set( _PROJECT_LABEL        ${cframe_build_target_PROJECT_LABEL} )
  set( _TYPE                 ${cframe_build_target_TYPE} )
  set( _LINK_TYPE            ${cframe_build_target_LINK_TYPE} )
  set( _GROUP                ${cframe_build_target_GROUP} )
  set( _INCLUDE_DIRS         ${cframe_build_target_INCLUDE_DIRS} )
  set( _DEFINES              ${cframe_build_target_DEFINES} )
  set( _COMPILE_FLAGS        ${cframe_build_target_COMPILE_FLAGS} )
  set( _LINK_FLAGS           ${cframe_build_target_LINK_FLAGS} )
  set( _LIBRARY_DIRS         ${cframe_build_target_LIBRARY_DIRS} )
  set( _LIBRARIES            ${cframe_build_target_LIBRARIES} )
  set( _HEADERS_PUBLIC       ${cframe_build_target_HEADERS_PUBLIC} )
  set( _HEADERS_PRIVATE      ${cframe_build_target_HEADERS_PRIVATE} )
  set( _SOURCES              ${cframe_build_target_SOURCES} )
  set( _QT_MOCFILES          ${cframe_build_target_QT_MOCFILES} )
  set( _QT_UIFILES           ${cframe_build_target_QT_UIFILES} )
  set( _QT_QRCFILES          ${cframe_build_target_QT_QRCFILES} )
  set( _NO_INSTALL           ${cframe_build_target_NO_INSTALL} )
  set( _HEADERS_INSTALL_DIR  ${cframe_build_target_HEADERS_INSTALL_DIR} )
  set( _FILES_INSTALL_DIR    ${cframe_build_target_FILES_INSTALL_DIR} )
  set( _BINARY_INSTALL_DIR   ${cframe_build_target_BINARY_INSTALL_DIR} )

  # Apply fine-grained build filters on a per file level using the CFRAME_FILE_EXCLUDE_LIST
##  cframe_filter_list( _HEADERS_PUBLIC  CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _HEADERS_PRIVATE CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _FILES_PUBLIC    CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _FILES_PRIVATE   CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _SOURCES         CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _QT_MOCFILES     CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _QT_UIFILES      CFRAME_FILE_EXCLUDE_LIST )
##  cframe_filter_list( _QT5_QRCFILES    CFRAME_FILE_EXCLUDE_LIST )

  if ( DEFINED cframe_build_target_DEFINES )
      add_definitions( ${cframe_build_target_DEFINES} )
  endif()

  # ----------------------
  # Qt specific processing
  # ----------------------

  # Process Qt MOC Files
  if ( cframe_build_target_QT_MOCFILES )
    qt_wrap_cpp(
        ${cframe_build_target_TARGET_NAME}
        ${cframe_build_target_TARGET_NAME}_MOCSOURCES
        ${cframe_build_target_QT_MOCFILES}
    )

    source_group(
        \\generated\\moc_files FILES
        ${${cframe_build_target_TARGET_NAME}_MOCSOURCES}
    )

    if ( cframe_build_target_DEBUG )
      cframe_message( MODE STATUS VERBOSITY 3
          "CFrame: ${cframe_build_target_TARGET_NAME} Generated MOC Files: "
          "${${cframe_build_target_TARGET_NAME}_MOCSOURCES}"
      )
    endif()
  endif()

  # Process Qt UI Files
  if ( DEFINED cframe_build_target_QT_UIFILES )
    if ( QT_VERSION_5 )
      foreach( UIFILE ${cframe_build_target_QT_UIFILES} )
        qt5_wrap_ui( ${cframe_build_target_TARGET_NAME}_UIHEADERS ${UIFILE} )
      endforeach()
    else()
      qt_wrap_ui(
          ${cframe_build_target_TARGET_NAME}
          ${cframe_build_target_TARGET_NAME}_UISOURCES
          ${cframe_build_target_TARGET_NAME}_UIHEADERS
          ${cframe_build_target_QT_UIFILES}
      )
    endif()

    source_group(
        \\ui_files FILES
        ${cframe_build_target_QT_UIFILES}
    )
    source_group(
        \\generated\\ui_files FILES
        ${${cframe_build_target_TARGET_NAME}_UIHEADERS}
        ${${cframe_build_target_TARGET_NAME}_UISOURCES}
    )

    cframe_message( MODE STATUS VERBOSITY 3
        "CFrame: ${cframe_build_target_TARGET_NAME} Generated UI Files: "
        "${${cframe_build_target_TARGET_NAME}_UIHEADERS}"
        "${${cframe_build_target_TARGET_NAME}_UISOURCES}"
    )
  endif()

  # Process Qt QRC Files
  if ( DEFINED cframe_build_target_QT_QRCFILES )
    if ( QT_VERSION_4 )
      qt4_add_resources(
          ${cframe_build_target_TARGET_NAME}_RESOURCES
          ${cframe_build_target_QT_QRCFILES}
      )
    else()
      qt5_add_resources(
          ${cframe_build_target_TARGET_NAME}_RESOURCES
          ${cframe_build_target_QT_QRCFILES}
      )
    endif()

    source_group(
        \\qrc_files FILES
        ${cframe_build_target_TARGET_NAME_QT_QRCFILES}
    )
    source_group(
        \\generated\\qrc_files FILES
        ${${cframe_build_target_TARGET_NAME}_RESOURCES}
    )

    cframe_message( MODE STATUS VERBOSITY 3
        "${cframe_build_target_TARGET_NAME} Generated Qt Resource Files: "
        "${${cframe_build_target_TARGET_NAME}_RESOURCES}"
    )
  endif()

  # --------------------------------
  # Massaging of dependent libraries
  # --------------------------------
  if ( DEFINED cframe_build_target_LIBRARY_DIRS )
    link_directories( ${cframe_build_target_LIBRARY_DIRS} )
  endif()

  if ( DEFINED cframe_build_target_LINK_TYPE )
    if ( cframe_build_target_LINK_TYPE STREQUAL "SHARED" )
      set( LINK_TYPE SHARED )
    elseif( cframe_build_target_LINK_TYPE STREQUAL "STATIC" )
      set( LINK_TYPE STATIC )
    elseif( cframe_build_target_LINK_TYPE STREQUAL "INTERFACE" )
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
  #   - the cframe_build_target_LIBRARIES doesn't use full paths for its elements
  if ( NOT BUILD_SHARED_LIBS )
    foreach( TARGET_LIB ${cframe_build_target_LIBRARIES} )
      if ( NOT (TARGET_LIB STREQUAL "optimized") AND NOT (TARGET_LIB STREQUAL "debug") )
        add_definitions( -D${TARGET_LIB}_STATIC )
      endif()
    endforeach()
  endif()

  # -----------------
  # Set up the Target
  # -----------------
  set( ${cframe_build_target_TARGET_NAME}_ALL_FILES
      ${cframe_build_target_HEADERS_PUBLIC}
      ${cframe_build_target_HEADERS_PRIVATE}
      ${cframe_build_target_FILES_PUBLIC}
      ${cframe_build_target_FILES_PRIVATE}
      ${cframe_build_target_SOURCES}
      ${cframe_build_target_QT_MOCFILES}
      ${${cframe_build_target_TARGET_NAME}_MOCSOURCES}
      ${cframe_build_target_QT_UIFILES}
      ${${cframe_build_target_TARGET_NAME}_UIHEADERS}
      ${${cframe_build_target_TARGET_NAME}_UISOURCES}
      ${cframe_build_target_QT_QRCFILES}
      ${${cframe_build_target_TARGET_NAME}_RESOURCES}
  )

  set( ${cframe_build_target_TARGET_NAME}_ALL_SOURCES
      ${cframe_build_target_SOURCES}
      ${${cframe_build_target_TARGET_NAME}_MOCSOURCES}
      ${${cframe_build_target_TARGET_NAME}_UISOURCES}
      ${${cframe_build_target_TARGET_NAME}_RESOURCES}
  )

  # If no sources (either specified or generated) were found, sppecify target
  # type as "INERFACE"
  if ( ("${${cframe_build_target_TARGET_NAME}_ALL_SOURCES}" STREQUAL "") AND
       ("${cframe_build_target_TYPE}" STREQUAL "LIBRARY") )
    set( cframe_build_target_TYPE "INTERFACE" )
    cframe_message( MODE STATUS VERBOSITY 1
        "CFrame: Automatically setting target ${cframe_build_target_TARGET_NAME}
           as Custom type because no sources (neither specified nor generated) were
           found."
    )
  endif() # Automatic conversion to "Custom" type


  if ( "${CFRAME_SOURCE_DISPLAY_MODE}" STREQUAL "FLAT" )
    source_group(
        \\ FILES
        ${cframe_build_target_HEADERS_PUBLIC}
        ${cframe_build_target_HEADERS_PRIVATE}
        ${cframe_build_target_SOURCES}
        ${cframe_build_target_FILES_PUBLIC}
        ${cframe_build_target_FILES_PRIVATE}
    )
  elseif ( "${CFRAME_SOURCE_DISPLAY_MODE}" STREQUAL "TREE" )
    # Generated files that are output outside the source tree  (e.g. in the
    # ${CMAKE_CURRENT_BINARY_DIR} ) will cause an error, so exclude them
    foreach( file
        ${cframe_build_target_HEADERS_PUBLIC}
        ${cframe_build_target_HEADERS_PRIVATE}
        ${cframe_build_target_SOURCES}
        ${cframe_build_target_FILES_PUBLIC}
        ${cframe_build_target_FILES_PRIVATE}
    )
      get_filename_component( abs_path ${file} REALPATH )
      file( RELATIVE_PATH rel_path ${PROJECT_SOURCE_DIR} ${abs_path} )
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

  if ( "${cframe_build_target_TYPE}" STREQUAL "LIBRARY" )

    # Only add the static definition for the library if a special link type isn't specified
    if ( DEFINED cframe_build_target_LINK_TYPE )
      if ( "cframe_build_target_LINK_TYPE" STREQUAL "STATIC" )
        add_definitions( -D${cframe_build_target_TARGET_NAME}_STATIC )
      endif()
    elseif ( NOT BUILD_SHARED_LIBS )
      add_definitions( -D${cframe_build_target_TARGET_NAME}_STATIC )
    endif()
    add_library(
        ${cframe_build_target_TARGET_NAME} ${LINK_TYPE}
        ${${cframe_build_target_TARGET_NAME}_ALL_FILES}
    )
    if ( "cframe_build_target_LINK_TYPE" STREQUAL "DYNAMIC" )
      set_target_properties(
          ${cframe_build_target_TARGET_NAME} PROPERTIES
          LINK_DEPENDS_NO_SHARED TRUE
      )
    endif()

##  elseif( ("${cframe_build_target_TYPE}" STREQUAL "EXECUTABLE") OR
##          ("${cframe_build_target_TYPE}" STREQUAL "TEST") )
  elseif( "${cframe_build_target_TYPE}" STREQUAL "EXECUTABLE" )

    add_executable(
        ${cframe_build_target_TARGET_NAME}
        ${${cframe_build_target_TARGET_NAME}_ALL_FILES}
    )

  elseif( "${cframe_build_target_TYPE}" STREQUAL "INTERFACE" )
    add_library( ${cframe_build_target_TARGET_NAME} INTERFACE )
    set_property(
        TARGET ${cframe_build_target_TARGET_NAME}
        PROPERTY
            INTERFACE_SOURCES
                ${cframe_build_target_HEADERS_PUBLIC}
                ${cframe_build_target_FILES_PUBLIC}
                ${cframe_build_target_HEADERS_PRIVATE}
                ${cframe_build_target_FILES_PRIVATE}
    )
    ## HACK: Interfaces don't show up in IDEs, so make a custom target
    message( STATUS
        "CFrame: Adding custom target for interface: "
        "${cframe_build_target_TARGET_NAME}_display"
    )
    add_custom_target( ${cframe_build_target_TARGET_NAME}_display
        SOURCES
            ${cframe_build_target_HEADERS_PUBLIC}
            ${cframe_build_target_FILES_PUBLIC}
            ${cframe_build_target_HEADERS_PRIVATE}
            ${cframe_build_target_FILES_PRIVATE}
    )

##    if ( "${cframe_build_target_TYPE}" STREQUAL "TEST" )
##      get_target_property(
##          TEST_EXECUTABLE ${cframe_build_target_TARGET_NAME} LOCATION
##      )
##
##      string( REGEX
##              REPLACE "\\$\\(.*\\)" "\${CTEST_CONFIGURATION_TYPE}"
##              TEST_EXECUTABLE "${TEST_EXECUTABLE}"
##      )
##
##      add_test( ${TESTNAME} ${TEST_EXECUTABLE} )
##    endif() # Test type

  elseif( "${cframe_build_target_TYPE}" STREQUAL "CUSTOM" )
    add_custom_target(
        ${cframe_build_target_TARGET_NAME}
        SOURCES
            ${${cframe_build_target_TARGET_NAME}_ALL_FILES}
    )
  endif() # Custom type

  # Set the output name if it is defined and different than the target name
  # And set the DEFINE_SYMBOL to the OUTPUT_NAME to ensure consistency with the actual output name.
  if ( (DEFINED cframe_build_target_OUTPUT_NAME)
       AND
       (NOT ("${cframe_build_target_TARGET_NAME}" STREQUAL "${cframe_build_target_OUTPUT_NAME}")) )
      set_target_properties(
          ${cframe_build_target_TARGET_NAME} PROPERTIES
          OUTPUT_NAME   ${cframe_build_target_OUTPUT_NAME}
          DEFINE_SYMBOL ${cframe_build_target_OUTPUT_NAME}_EXPORTS
      )
  endif()

  if ( DEFINED cframe_build_target_PROJECT_LABEL )
    if( NOT "${cframe_build_target_TYPE}" STREQUAL "INTERFACE" )
      set_target_properties(
          ${cframe_build_target_TARGET_NAME} PROPERTIES
          PROJECT_LABEL   ${cframe_build_target_PROJECT_LABEL}
      )
    else()
      set_target_properties(
          ${cframe_build_target_TARGET_NAME}_display PROPERTIES
          PROJECT_LABEL   ${cframe_build_target_PROJECT_LABEL}
      )
    endif()
  endif()

  if( DEFINED cframe_build_target_LIBRARIES )
    if ( "${cframe_build_target_TYPE}" STREQUAL "INTERFACE")
      target_link_libraries(
          ${cframe_build_target_TARGET_NAME} INTERFACE
          ${cframe_build_target_LIBRARIES}
      )
    else()
      target_link_libraries(
          ${cframe_build_target_TARGET_NAME}
          ${cframe_build_target_LIBRARIES}
      )
    endif()
  endif()

  # -----------------------
  # Set include directories
  # -----------------------
  if ( DEFINED cframe_build_target_INCLUDE_DIRS )
    cframe_target_include_directories(
        ${cframe_build_target_TARGET_NAME}
        "${cframe_build_target_INCLUDE_DIRS}"
    )
  endif()

  # -----------------------------------
  # Set various other target properties
  # -----------------------------------
  set_property(
      SOURCE ${cframe_build_target_HEADERS_PUBLIC}
      PROPERTY PUBLIC_HEADER
  )

  if( NOT "${cframe_build_target_TYPE}" STREQUAL "INTERFACE" )
    set_target_properties(
        ${cframe_build_target_TARGET_NAME}
        PROPERTIES
            DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
    )
  endif()

  # set the target group
  if ( DEFINED cframe_build_target_GROUP )
    if( NOT "${cframe_build_target_TYPE}" STREQUAL "INTERFACE" )
      set_target_properties(
          ${cframe_build_target_TARGET_NAME} PROPERTIES
          FOLDER ${cframe_build_target_GROUP}
      )
    else()
      set_target_properties(
          ${cframe_build_target_TARGET_NAME}_display PROPERTIES
          FOLDER ${cframe_build_target_GROUP}
      )
    endif()
  endif()

  # set PIC on shared libraries
  if ( NOT WIN32 AND NOT BUILD_SHARED_LIBS )
    if( NOT "${cframe_build_target_TYPE}" STREQUAL "INTERFACE" )
      # Ensure that static libraries use position independent code on Linux
      set_target_properties(
          ${cframe_build_target_TARGET_NAME} PROPERTIES
          POSITION_INDEPENDENT_CODE ON
      )
    endif()
  endif()

  # set target compile flags
  if ( DEFINED cframe_build_target_COMPILE_FLAGS OR DEFINED CFRAME_OS_COMPILE_FLAGS )
      set_target_properties(
          ${cframe_build_target_TARGET_NAME} PROPERTIES
          COMPILE_FLAGS
              ${cframe_build_target_COMPILE_FLAGS}
              ${CFRAME_OS_COMPILE_FLAGS}
      )
  endif()

  # install standard target artifacts
  if ( NOT cframe_build_target_NO_INSTALL AND
       NOT "${cframe_build_target_TYPE}" STREQUAL "CUSTOM" )
      if ( DEFINED cframe_build_target_BINARY_INSTALL_DIR )
        set( BINARY_INSTALL_PREFIX ${cframe_build_target_BINARY_INSTALL_DIR}/ )
      endif()
      install(
          TARGETS ${cframe_build_target_TARGET_NAME}
          RUNTIME DESTINATION ${BINARY_INSTALL_PREFIX}${CFRAME_INSTALL_BIN_DIR} COMPONENT Runtime
          LIBRARY DESTINATION ${BINARY_INSTALL_PREFIX}${CFRAME_INSTALL_LIB_DIR} COMPONENT Runtime
          ARCHIVE DESTINATION ${BINARY_INSTALL_PREFIX}${CFRAME_INSTALL_DEV_DIR} COMPONENT Development
      )
  endif()

  # install public headers
  if ( DEFINED cframe_build_target_HEADERS_INSTALL_DIR )
      install(
          FILES ${cframe_build_target_HEADERS_PUBLIC}
          DESTINATION ${cframe_build_target_HEADERS_INSTALL_DIR}
      )
  endif()

  # install public files
  if ( DEFINED cframe_build_target_FILES_PUBLIC AND
       DEFINED cframe_build_target_FILES_INSTALL_DIR )
    install(
        FILES ${cframe_build_target_FILES_PUBLIC}
        DESTINATION ${cframe_build_target_FILES_INSTALL_DIR}
    )
  endif()

endfunction() # cframe_build_target
