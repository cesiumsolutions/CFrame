# -----------------------------------------------------------------------------
#
# Internal macros used for setting up CFrame
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Macro: cframe_prepare_packages
#
# Do a first pass through all package directories
# and include their CFrameLists.txt file (if it exists).
#
# The Product's CFrameLists.txt should do the following:
# - specify include_directoriem s for the appropriate package subdirectories
# - specify the name of external package dependencies, and when possible
#   the components of those packages. This can be done using the function:
#
#      cframe_use_external_package( PACKAGE <name> VERSION <version> COMPONENTS <components...> ).
#
#   For example, for Boost:
#
#       cframe_use_external_package(
#           PACKAGE Boost
#           VERSION version
#           COMPONENTS
#               signals
#               system
#               unit_test_framework
#       )
#
#   Each of the lists will be reduced to make sure there are no duplicate entries.
#
# - Each Project should also publish their interfaces in a standard way so that
#   other dependent Projects can refer to then in a standard way. This done by
#   using the function:
#
#       cframe_publish_package( PACKAGE_NAME
#           PACKAGE_NAME <name of package>
#           VERSION      <parts of version identifier: major minor patch build, number of elements is optional>
#           DEFINITIONS  <list of definitions>
#           INCLUDE_DIRS <list of directories to include>
#           LIBRARY_DIRS <list of directories to search for libraries>
#           LIBRARIES    <list of libraries generated>
#       )
#
# Global parameters used:
#     CFRAME_PACKAGES_DIR
#
# -----------------------------------------------------------------------------
macro( cframe_prepare_packages )

  cframe_message( STATUS 3 "CFrame: MACRO: cframe_prepare_packages" )

  # Analyze all directories under the packages directory.
  file( GLOB PACKAGE_DIRS
      LIST_DIRECTORIES TRUE
      RELATIVE ${CFRAME_PACKAGES_DIR}
      ${CFRAME_PACKAGES_DIR}/*
  )
  cframe_message( STATUS 4 "CFrame: Product directories: ${PACKAGE_DIRS}")
  foreach( PACKAGE ${PACKAGE_DIRS} )

    # Only process package subdirectories that contain a CMakeLists.txt file
    if ( (IS_DIRECTORY ${CFRAME_PACKAGES_DIR}/${PACKAGE}) AND
         (EXISTS ${CFRAME_PACKAGES_DIR}/${PACKAGE}/CMakeLists.txt) )

      list( APPEND CFRAME_BUILD_PACKAGES ${PACKAGE} )

      # If package subdirectory contains a CFrameLists.txt file, make it active
      # by default and process it
      if ( EXISTS ${CFRAME_PACKAGES_DIR}/${PACKAGE}/CFrameLists.txt )
        option( BUILD_PACKAGE_${PACKAGE} "Build Product ${PACKAGE}" ON )
        set( CFRAME_CURRENT_PACKAGE_DIR ${CFRAME_PACKAGES_DIR}/${PACKAGE} )
        set( CFRAME_CURRENT_PACKAGE_NAME ${PACKAGE} )
        include( ${CFRAME_PACKAGES_DIR}/${PACKAGE}/CFrameLists.txt )

        cframe_message( STATUS 4
            "CFrame: ${PACKAGE} version:      ${${PACKAGE}_VERSION}"
        )
        cframe_message( STATUS 4
            "CFrame: ${PACKAGE} definitions:  ${${PACKAGE}_DEFINITIONS}"
        )
        cframe_message( STATUS 4
            "CFrame: ${PACKAGE} include dirs: ${${PACKAGE}_INCLUDE_DIRS}"
        )
        cframe_message( STATUS 4
            "CFrame: ${PACKAGE} library dirs: ${${PACKAGE}_LIBRARY_DIRS}"
        )
        cframe_message( STATUS 4
            "CFrame: ${PACKAGE} libraries:    ${${PACKAGE}_LIBRARIES}"
        )

      else()
        option( BUILD_PACKAGE_${PACKAGE} "Build Package ${PACKAGE}" OFF )
        cframe_message( WARNING 2
            "CFrame: Package: ${PACKAGE} does not contain a CFrameLists.txt."
            "It will be ignored for further processing."
            "See CFrame CMake Modular Framework documentation for further information."
        )
      endif()

      # Automaticay include any directories published by the PACKAGE
      if ( BUILD_PACKAGE_${PACKAGE} MATCHES ON )
        if ( DEFINED ${PACKAGE}_INCLUDE_DIRS )
          cframe_message( STATUS 4 "CFrame: ${PACKAGE}_INCLUDE_DIRS: ${${PACKAGE}_INCLUDE_DIRS}")
          include_directories( ${${PACKAGE}_INCLUDE_DIRS} )
        endif()
      endif()

    else()

      cframe_message( STATUS 2
          "CFrame: Project ${PACKAGE} is not a directory or does not contain a CMakeLists.txt, skipping"
      )

    endif() # is directory and CMakeLists.txt exists
  endforeach() # package subdirectory loop

endmacro() # cframe_prepare_packages

# -----------------------------------------------------------------------------
# Macro: cframe_setup_external_packages
#
# Go through each of the external dependencies listed by the packages
# and either call the Setup${EXT_DEP}.cmake or do a standard setup.
#
# -----------------------------------------------------------------------------
macro( cframe_setup_external_packages )

  cframe_message( STATUS 3 "CFrame: MACRO: cframe_external_package_setup" )

  foreach( XPACKAGE ${CFRAME_EXTERNAL_PACKAGES} )
    cframe_message( STATUS 2
        "CFrame: Setting up external package: ${XPACKAGE} with components: ${CFRAME_EXTERNAL_${XPACKAGE}_COMPONENTS}"
    )

    # If there is a specialized external package setup file, call it, otherwise
    # do normal package processing
    if ( EXISTS ${${PROJECT_NAME}_SOURCE_DIR}/share/${PROJECT_NAME}/cmake/Setup${XPACKAGE}.cmake )
      cframe_message( STATUS 3 "CFrame: Using share/${PROJECT_NAME}/cmake/Setup${XPACKAGE}.cmake" )
      include( ${${PROJECT_NAME}_SOURCE_DIR}/share/${PROJECT_NAME}/cmake/Setup${XPACKAGE}.cmake )
    else()
      cframe_message( STATUS 3 "CFrame: Using standard external setup for package: ${XPACKAGE}" )
      cframe_setup_external_package( ${XPACKAGE} "${CFRAME_EXTERNAL_${XPACKAGE}_COMPONENTS}" )
    endif()
  endforeach()

endmacro() # cframe_setup_external_packages

# -----------------------------------------------------------------------------
# Macro: cframe_build_packages
#
# Now go through each of the package directories again and add their
# subdirectories. The CFRAME_BUILD variable will be set to true so that each
# package can either build using CFrame conventions or their own conventions.
#
# For example, in the root CMakeLists.txt of the package, the following check
# can be made:
#
#   if ( ${CFRAME_BUILD} )
#     include( CFrameBuild.cmake )
#   else()
#     .. do standard internal build
#   endif()
#
# -----------------------------------------------------------------------------
macro( cframe_build_packages )

  cframe_message( STATUS 3 "CFrame: MACRO: cframe_build_packages" )
  cframe_message( STATUS 4 "CFrame: Products: ${CFRAME_BUILD_PACKAGES}")

  set( CFRAME_BUILD TRUE )
  foreach( PACKAGE ${CFRAME_BUILD_PACKAGES} )
    if ( BUILD_PACKAGE_${PACKAGE} MATCHES ON )
      # @todo Find a better way to determine if CMAKE_PACKAGES_DIR is outside
      # of CFrame's source directory
      if ( IS_ABSOLUTE ${CFRAME_PACKAGES_DIR} )
        add_subdirectory( ${CFRAME_PACKAGES_DIR}/${PACKAGE} ${PACKAGE} )
      else()
        add_subdirectory( ${CFRAME_PACKAGES_DIR}/${PACKAGE} )
      endif()
    endif()
  endforeach()
  set( CFRAME_BUILD FALSE )

endmacro() # cframe_build_packages

# -----------------------------------------------------------------------------
# Macro: cframe_main
#
# Main body of CFrame root CMakeLists.txt
# -----------------------------------------------------------------------------
macro( cframe_main )

  cframe_message( STATUS 3 "CFrame: MACRO: cframe_main" )

  cframe_prepare_packages()

  cframe_setup_external_packages()

  cframe_build_packages()

endmacro() # cframe_prepare