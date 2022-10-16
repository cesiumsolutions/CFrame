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
  set( CFRAME_GIT_FILES "" )
  foreach( FILE ${CFRAME_ALL_FILES} )
    string( SUBSTRING ${FILE} 0 4 GIT_PART )
    if ( "${GIT_PART}" STREQUAL ".git" )
      list( APPEND CFRAME_GIT_FILES ${FILE} )
    endif()
  endforeach()
  if ( "{CFRAME_GIT_FILES}" )
    list( REMOVE_ITEM CFRAME_ALL_FILES ${CFRAME_GIT_FILES} )
  endif()

  source_group(
      TREE ${CFRAME_DIR}
      FILES
          ${CFRAME_ALL_FILES}
  )
  add_custom_target(
      CFrame
      SOURCES
          ${CFRAME_ALL_FILES}
  )

endif()
