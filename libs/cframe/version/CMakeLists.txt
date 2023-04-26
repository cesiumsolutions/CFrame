
include( CFrameSetupBoost )

cframe_generate_version_files(
    PRODUCT_NAME      cframeversion
    PRODUCT_TYPE      Library
    PRODUCT_FILE      cframeversion
    GENERATED_NAME    Version
    GENERATED_OUT_VAR CFRAME_VERSION_SOURCES
    API_INCLUDE_LINE  "#include <cframe/version/cframeVersionAPI.h>"
    API_DEFINITION    CFRAMEVERSION_API
    INSTALL_DIR       cframe/version
)

cframe_build_target(
    TARGET_NAME cframeversion
    TYPE        LIBRARY
    GROUP       CFrame/Libraries
    INCLUDE_DIRS
        PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/../..
            ${Boost_INCLUDE_DIRS}
    LINK_DIRS
        ${Boost_LIBRARY_DIRS}
    LIBRARIES
        ${Boost_LIBRARIES}
    HEADERS_PUBLIC
        cframeVersionAPI.h
        VersionInfo.hpp
    SOURCES
        VersionInfo.cpp
        ${CFRAME_VERSION_SOURCES}
    HEADERS_INSTALL_DIR
        include/cframe/version
)

