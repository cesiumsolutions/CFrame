# -----------------------------------------------------------------------------
#
# Contains Package and Project-related setup functions.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------
function( cframe_publish_package )

  cframe_message( STATUS 3 "CFrame: FUNCTION: cframe_publish_package")

  # -----------------------------------
  # Set up and parse multiple arguments
  # -----------------------------------
  set( options
  )
  set( oneValueArgs
      PACKAGE
  )
  set( multiValueArgs
      VERSION
      DEFINITIONS
      INCLUDE_DIRS
      LIBRARY_DIRS
      LIBRARIES
  )

  cmake_parse_arguments(
      cframe_publish_package
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  cframe_message( STATUS 4 "Parameters for cframe_publish_package:" )
  cframe_message( STATUS 4 "PACKAGE:       ${cframe_publish_package_PACKAGE}" )
  cframe_message( STATUS 4 "VERSION:       ${cframe_publish_package_VERSION}" )
  cframe_message( STATUS 4 "DEFINITIONS:   ${cframe_publish_package_DEFINITIONS}" )
  cframe_message( STATUS 4 "INCLUDE_DIRS:  ${cframe_publish_package_INCLUDE_DIRS}" )
  cframe_message( STATUS 4 "LIBRARY_DIRS:  ${cframe_publish_package_LIBRARY_DIRS}" )
  cframe_message( STATUS 4 "LIBRARIES:     ${cframe_publish_package_LIBRARIES}" )

  # Check that minimal values are defined and valid
  if ( NOT DEFINED cframe_publish_package_PACKAGE )
    cframe_message( WARNING 1 "CFrame: cframe_publish_package no PACKAGE parameter specified" )
    return()
  endif()

  string( TOUPPER ${cframe_publish_package_PACKAGE} UPACKAGE )

  cframe_message( STATUS 3 "CFrame: ${cframe_publish_package_PACKAGE} publishing the following variables." )

  set( ${UPACKAGE}_FOUND TRUE
      CACHE INTERNAL "$(cframe_publish_package_PACKAGE} package was found."
  )
  cframe_message( STATUS 3
      "${UPACKAGE}_FOUND        = ${${UPACKAGE}_FOUND}"
  )

  if ( DEFINED cframe_publish_package_VERSION )
    set( ${UPACKAGE}_VERSION ${cframe_publish_package_VERSION}
        CACHE STRING "$(cframe_publish_package_PACKAGE} package version."
    )
    cframe_message( STATUS 3
        "${UPACKAGE}_VERSION      = ${${UPACKAGE}_VERSION}"
    )
  endif()

  if ( DEFINED cframe_publish_package_DEFINITIONS )
    set( ${UPACKAGE}_DEFINITIONS ${cframe_publish_package_DEFINITIONS}
        CACHE STRING "${cframe_publish_package_PACKAGE} package list of definitions."
    )
    cframe_message( STATUS 3
        "${UPACKAGE}_DEFINITIONS  = ${${UPACKAGE}_DEFINITIONS}"
    )
  endif()

  if ( DEFINED cframe_publish_package_INCLUDE_DIRS )
    set( ${UPACKAGE}_INCLUDE_DIRS ${cframe_publish_package_INCLUDE_DIRS}
        CACHE STRING "${cframe_publish_package_PACKAGE} package list of include directories."
    )
    cframe_message( STATUS 3
        "${UPACKAGE}_INCLUDE_DIRS = ${${UPACKAGE}_INCLUDE_DIRS}"
    )
  endif()

  if ( DEFINED cframe_publish_package_LIBRARY_DIRS )
    set( ${UPACKAGE}_LIBRARY_DIRS ${cframe_publish_package_LIBRARY_DIRS}
        CACHE STRING "${cframe_publish_package_PACKAGE} package list of library directories."
    )
    cframe_message( STATUS 3
        "${UPACKAGE}_LIBRARY_DIRS = ${${UPACKAGE}_LIBRARY_DIRS}"
    )
  endif()

  if ( DEFINED cframe_publish_package_LIBRARIES )
    set( ${UPACKAGE}_LIBRARIES ${cframe_publish_package_LIBRARIES}
        CACHE STRING "${cframe_publish_package_PACKAGE} package list of libraries."
    )
    cframe_message( STATUS 3
        "${UPACKAGE}_LIBRARIES    = ${${UPACKAGE}_LIBRARIES}"
    )
  endif()

endfunction() # cframe_publish_package

# -----------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------
macro( cframe_setup_project_subdir )

  cframe_message( STATUS 3 "CFrame: FUNCTION: cframe_setup_project_subdir")

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
      FILES_PUBLIC
      FILES_PRIVATE
      SOURCES
  )

  cmake_parse_arguments(
      cframe_setup_project_subdir
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  cframe_message( STATUS 4 "Parameters for cframe_setup_project_subdir:" )
  cframe_message( STATUS 4 "PREFIX:               ${cframe_setup_project_subdir_PREFIX}" )
  cframe_message( STATUS 4 "SUBDIR:               ${cframe_setup_project_subdir_SUBDIR}" )
  cframe_message( STATUS 4 "FOLDER:               ${cframe_setup_project_subdir_FOLDER}" )
  cframe_message( STATUS 4 "HEADERS_INSTALL_DIR:  ${cframe_setup_project_subdir_HEADERS_INSTALL_DIR}" )
  cframe_message( STATUS 4 "FILES_INSTALL_DIR:    ${cframe_setup_project_subdir_FILESS_INSTALL_DIR}" )
  cframe_message( STATUS 4 "HEADERS_PUBLIC:       ${cframe_setup_project_subdir_HEADERS_PUBLIC}" )
  cframe_message( STATUS 4 "HEADERS_PRIVATE:      ${cframe_setup_project_subdir_HEADERS_PRIVATE}" )
  cframe_message( STATUS 4 "FILES_PUBLIC:         ${cframe_setup_project_subdir_FILES_PUBLIC}" )
  cframe_message( STATUS 4 "FILES_PRIVATE:        ${cframe_setup_project_subdir_FILES_PRIVATE}" )
  cframe_message( STATUS 4 "SOURCES:              ${cframe_setup_project_subdir_SOURCES}" )

  set( PREFIX               ${cframe_setup_project_subdir_PREFIX} )
  set( SUBDIR               ${cframe_setup_project_subdir_SUBDIR} )
  set( FOLDER               ${cframe_setup_project_subdir_FOLDER} )
  set( HEADERS_INSTALL_DIR  ${cframe_setup_project_subdir_HEADERS_INSTALL_DIR} )
  set( FILES_INSTALL_DIR    ${cframe_setup_project_subdir_FILESS_INSTALL_DIR} )
  set( HEADERS_PUBLIC       ${cframe_setup_project_subdir_HEADERS_PUBLIC} )
  set( HEADERS_PRIVATE      ${cframe_setup_project_subdir_HEADERS_PRIVATE} )
  set( FILES_PUBLIC         ${cframe_setup_project_subdir_FILES_PUBLIC} )
  set( FILES_PRIVATE        ${cframe_setup_project_subdir_FILES_PRIVATE} )
  set( SOURCES              ${cframe_setup_project_subdir_SOURCES} )

  # Allow the case for a SUBDIR which is actually the current directory, in which case
  # SUBDIR should be undefined and the SEP will also remain undefined below
  if ( NOT ${SUBDIR} STREQUAL "" )
    set( SEP "/" )
  endif()

  foreach( FILE ${HEADERS_PUBLIC} )
    list( APPEND ${PREFIX}_HEADERS_PUBLIC ${SUBDIR}${SEP}${FILE} )
  endforeach()
  set( ${PREFIX}_HEADERS_PUBLIC ${${PREFIX}_HEADERS_PUBLIC} PARENT_SCOPE )
  cframe_message( STATUS 4 "CFrame: ${PREFIX}_HEADERS_PUBLIC: ${${PREFIX}_HEADERS_PUBLIC}" )

  foreach( FILE ${HEADERS_PRIVATE} )
    list( APPEND ${PREFIX}_HEADERS_PRIVATE ${SUBDIR}${SEP}${FILE} )
  endforeach()
  set( ${PREFIX}_HEADERS_PRIVATE ${${PREFIX}_HEADERS_PRIVATE} PARENT_SCOPE )
  cframe_message( STATUS 4 "CFrame: ${PREFIX}_HEADERS_PRIVATE: ${${PREFIX}_HEADERS_PRIVATE}" )

  foreach( FILE ${FILES_PUBLIC} )
    list( APPEND ${PREFIX}_FILES_PUBLIC ${SUBDIR}${SEP}${FILE} )
  endforeach()
  set( ${PREFIX}_FILES_PUBLIC ${${PREFIX}_FILES_PUBLIC} PARENT_SCOPE )
  cframe_message( STATUS 4 "CFrame: ${PREFIX}_FILES_PUBLIC: ${${PREFIX}_FILES_PUBLIC}" )

  foreach( FILE ${FILES_PRIVATE} )
    list( APPEND ${PREFIX}_FILES_PRIVATE ${SUBDIR}${SEP}${FILE} )
  endforeach()
  set( ${PREFIX}_FILES_PRIVATE ${${PREFIX}_FILES_PRIVATE} PARENT_SCOPE )
  cframe_message( STATUS 4 "CFrame: ${PREFIX}_FILES_PRIVATE: ${${PREFIX}_FILES_PRIVATE}" )

  foreach( FILE ${SOURCES} )
    list( APPEND ${PREFIX}_SOURCES ${SUBDIR}${SEP}${FILE} )
  endforeach()
  set( ${PREFIX}_SOURCES ${${PREFIX}_FILES_SOURCES} PARENT_SCOPE )
  cframe_message( STATUS 4 "CFrame: ${PREFIX}_SOURCES: ${${PREFIX}_SOURCES}" )

  source_group(
      \\${FOLDER} FILES
      ${${PREFIX}_HEADERS_PUBLIC}
      ${${PREFIX}_HEADERS_PRIVATE}
      ${${PREFIX}_FILES_PUBLIC}
      ${${PREFIX}_FILES_PRIVATE}
      ${${PREFIX}_SOURCES}
  )

  if ( DEFINED cframe_setup_project_subdir_HEADERS_INSTALL_DIR )
    install(
        FILES
            ${${PREFIX}_HEADERS_PUBLIC}
        DESTINATION
            ${cframe_setup_project_subdir_HEADERS_INSTALL_DIR}
    )
  endif()

  if (DEFINED cframe_setup_project_subdir_FILES_INSTALL_DIR )
    install(
        FILES
            ${${PREFIX}_FILES_PUBLIC}
        DESTINATION
            ${cframe_setup_project_subdir_FILES_INSTALL_DIR}
    )
  endif()

endmacro() # cframe_setup_project_subdir