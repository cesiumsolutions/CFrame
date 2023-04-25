# -----------------------------------------------------------------------------
#
# Sets up including of the CFrame source in the solution (e.g. in IDEs)
#
# -----------------------------------------------------------------------------

option( CFRAME_INCLUDE_CFRAME_SOURCE
    "Set to ON to include CFrame source in solution."
    ON
)

if ( ${CFRAME_INCLUDE_CFRAME_SOURCE} )
  
  file(
      GLOB_RECURSE CFRAME_ALL_FILES
      LIST_DIRECTORIES FALSE
      RELATIVE ${CFRAME_DIR}
      *
  )

  # Remove .git directory files
  list(
      FILTER CFRAME_ALL_FILES
      EXCLUDE REGEX ".git"
  )

  source_group(
      TREE ${CFRAME_DIR}
      PREFIX CFrame
      FILES
          ${CFRAME_ALL_FILES}
  )
  add_custom_target(
      cframe-source
      SOURCES
          ${CFRAME_ALL_FILES}
  )

  set_target_properties(
      cframe-source PROPERTIES
      FOLDER CFrame
  )

endif()
