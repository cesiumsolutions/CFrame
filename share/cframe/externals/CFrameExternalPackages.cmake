# -----------------------------------------------------------------------------
#
# This file contains functions to deal with external packages.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Specifies the desire to use an external package and specific components thereof.
# @param PACKAGE Specifies which Package that will be used
# @param COMPONENTS Specifies which components of said Package will be used
#
# Modifies global STRING variables called CFRAME_EXTERNAL_PACKAGES and for
# each package CFRAME_EXTERNAL_${PACKAGE}_COMPONENTS.
# Note: that these must first be converted to lists in order to remove duplicates.
# -----------------------------------------------------------------------------
function( cframe_use_external_package )

  cframe_message( STATUS 3 "CFrame: FUNCTION: cframe_use_external_package" )

  # Parse arguments
  set( options )
  set( oneValueArgs PACKAGE )
  set( multiValueArgs COMPONENTS )
  cmake_parse_arguments(
      cframe_use_external_package
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )
  set( PACKAGE ${cframe_use_external_package_PACKAGE} )
  set( COMPONENT_LIST_STRING ${cframe_use_external_package_COMPONENTS} )
  cframe_message( STATUS 2
      "CFrame: Using external package: ${PACKAGE} with components: ${COMPONENT_LIST_STRING}"
  )

  cframe_message( STATUS 3
      "CFrame: Original external package list: ${CFRAME_EXTERNAL_PACKAGES}"
  )
  cframe_message( STATUS 3
      "CFrame: Original components for ${PACKAGE}: ${CFRAME_EXTERNAL_${PACKAGE}_COMPONENTS}"
  )

  # Update the package list
  set( PACKAGE_LIST_UPDATED )
  cframe_merge_list_strings(
      "${CFRAME_EXTERNAL_PACKAGES}" "${PACKAGE}"
      TRUE FALSE
      PACKAGE_LIST_UPDATED
  )
  set( CFRAME_EXTERNAL_PACKAGES "${PACKAGE_LIST_UPDATED}" CACHE INTERNAL "" )
  cframe_message( STATUS 3
      "CFrame: Updated package list: ${CFRAME_EXTERNAL_PACKAGES}"
  )

  # Update package components list
  set( COMPONENT_LIST_UPDATED )
  cframe_merge_list_strings(
      "${CFRAME_EXTERNAL_${PACKAGE}_COMPONENTS}" "${COMPONENT_LIST_STRING}"
      TRUE TRUE
      COMPONENT_LIST_UPDATED
  )
  set( CFRAME_EXTERNAL_${PACKAGE}_COMPONENTS "${COMPONENT_LIST_UPDATED}" CACHE INTERNAL "" )
  cframe_message( STATUS 3
      "CFrame: Updated components for ${PACKAGE}: ${CFRAME_EXTERNAL_${PACKAGE}_COMPONENTS}"
  )

endfunction() # cframe_use_external_package

# -----------------------------------------------------------------------------
# Uses the default external package setup for specified package and corresponding
# components.
# @param PACKAGE The name of the package to load, corresponding to the Find${PACKAGE}.cmake Module
# @param COMPONENTS Any specific components to be loaded for the package.
# -----------------------------------------------------------------------------
macro( cframe_setup_external_package PACKAGE COMPONENTS )

  cframe_message( STATUS 3 "CFrame: MACRO: cframe_setup_package" )
  cframe_message( STATUS 4 "CFrame: Package: ${PACKAGE}" )
  cframe_message( STATUS 4 "CFrame: Components: ${COMPONENTS}" )

  find_package( ${PACKAGE} REQUIRED ${COMPONENTS} )
  string( TOUPPER ${PACKAGE} UPACKAGE )

  if ( ${${UPACKAGE}_FOUND} )

    cframe_message( STATUS 3 "CFrame: Successfully found package ${PACKAGE}" )
    cframe_message( STATUS 4 "CFrame: ${PACKAGE} Version:      ${${UPACKAGE}_VERSION}" )
    cframe_message( STATUS 4 "CFrame: ${PACKAGE} Definitions:  ${${UPACKAGE}_DEFINITIONS}" )
    cframe_message( STATUS 4 "CFrame: ${PACKAGE} Include Dirs: ${${UPACKAGE}_INCLUDE_DIRS}" )
    cframe_message( STATUS 4 "CFrame: ${PACKAGE} Library Dirs: ${${UPACKAGE}_LIBRARY_DIRS}" )
    cframe_message( STATUS 4 "CFrame: ${PACKAGE} Libraries:    ${${UPACKAGE}_LIBRARIES}" )

    add_definitions( ${${UPACKAGE}_DEFINITIONS} )
    include_directories( ${${UPACKAGE}_INCLUDE_DIRS} )
    link_directories( ${${UPACKAGE}_LIBRARY_DIRS} )

  else()

    cframe_message( SEND_ERROR 1 "CFrame: Could not default setup package ${PACKAGE}" )

  endif()

endmacro() # cframe_setup_package

