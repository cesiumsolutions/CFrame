# -----------------------------------------------------------------------------
#
# Initializes various variables related to platform-specific library loading
#
# -----------------------------------------------------------------------------

# ---------------------------------------------
# Handle selection of Library Loading Libraries
# ---------------------------------------------

if ( ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux") OR
     ("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin") )
  set(
      CFRAME_SYSTEM_LOADER_LIBRARIES ${CMAKE_DL_LIBS} elf
      CACHE STRING
      "Libraries to link for runtime dynamic loading."
  )
else()

endif()
