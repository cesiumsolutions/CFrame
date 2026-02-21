

if ( NOT IMGUI_VERSION )
    set( IMGUI_VERSION 1.89.9-docking CACHE STRING "ImGui Version" )
endif()

if ( NOT IMGUI_DIR )
    cframe_search_paths(
        imgui-${IMGUI_VERSION}
        "${CFRAME_EXTERN_SEARCH_PATHS}"
        IMGUI_DIR
    )
    if ( "${IMGUI_DIR}" STREQUAL "" )
        message(
            FATAL_ERROR
            "ImGui not found, set IMGUI_DIR or CFRAME_EXTERN_SEARCH_PATHS"
        )
    endif()
endif()

set(
    IMGUI_BACKENDS ""
    CACHE STRING "ImGui backends to use"
)

set(
    IMGUI_INCLUDE_DIRS
    ${IMGUI_DIR}/include
    ${IMGUI_DIR}/include/imgui
    ${IMGUI_DIR}/include/imgui/backends
    CACHE STRING "ImGui Include directories"
)
set(
    IMGUI_LIBRARY_DIR
    ${IMGUI_DIR}/lib
    CACHE PATH "ImGui Library directory"
)
set(
    IMGUI_LIBRARIES
    optimized imgui debug imgui${CMAKE_DEBUG_POSTFIX}
    optimized imgui_node_editor debug imgui_node_editor${CMAKE_DEBUG_POSTFIX}
    CACHE STRING "ImGui Libraries"
)
foreach( BACKEND ${IMGUI_BACKENDS} )
    list(
        APPEND IMGUI_LIBRARIES
        optimized imgui_${BACKEND}
        debug imgui_${BACKEND}${CMAKE_DEBUG_POSTFIX}
    )
endforeach()

message( STATUS "IMGUI_INCLUDE_DIRS = ${IMGUI_INCLUDE_DIRS}" )
message( STATUS "IMGUI_LIBRARY_DIR  = ${IMGUI_LIBRARY_DIR}" )
message( STATUS "IMGUI_LIBRARIES    = ${IMGUI_LIBRARIES}" )
