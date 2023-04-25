
# Determines whether Version File generation is enabled
# @see cframe_generate_version_files
option(
    CFRAME_VERSION_GENERATION
    "Toggle on to generate/update Version files"
    OFF
)

set(
    CFRAME_VERSION_DEFAULT_GENERATED_NAME_SUFFIX
    "_version"
    CACHE STRING
    "The suffix to append to the PRODUCT_NAME if no GENERATED_NAME is provided
    to cframe_generate_version_files"
)

# -----------------------------------------------------------------------------
# @brief Generates files that contain version information.
# Uses the specified template files to configure files replacing
# version information with the parameters passed in.
#
# Non-self-explanatory arguments are:
# @param TEMPLATE_FILE_PUBLIC Location of file to be used as input
#            for configuration and to be installed.
# @param TEMPLATE_FILE_PRIVATE Location of file to be used as input
#            for configruation.
# @param GENERATED_NAME The base name of the file(s) to be generated.
#            Defaults to PRODUCT_NAME
# @param GENERATED_EXTENSION_PUBLIC The extension to use for the generated
#            public file. Defaults to hpp.
# @param GENERATED_EXTENSION_PRIVATE The extension to use for the generated
#            private file. Defaults to cpp.
# @param GENERATED_SOURCE_GROUP The organizational node to place generated files
#            in for IDE-based environments. Defaults to: Generated.
# @param GENERATED_OUT_VAR The variable to store the location of the generated files.
# @param API_INCLUDE_LINE The #include directive to be replaced in the
#            generated files. E.g. #include <path/to/MyVersion.hpp>
# @param API_DEFINITION The macro typically used for exporting/importing symbols
#            for shared libraries (on Windows).
# @param INSTALL_DIR Subdirectory of ${CMAKE_INSTALL_PREFIX}/include where to
#            install the generated public file.
#
# For example:
# @code
# cframe_generate_version_files(
#     PRODUCT_NAME     OpenIGS
#     PRODUCT_TYPE     Library
#     PRODUCT_FILE     igs
#     TEMPLATE_FILE_PUBLIC  ${CFRAME_VERSION_TEMPLATE_FILE_PUBLIC}
#     TEMPLATE_FILE_PRIVATE ${CFRAME_VERSION_TEMPLATE_FILE_PRIVATE}
#     GENERATED_NAME   OpenIGSAPI
#     GENERATED_OUT_VAR      IGS_VERSION_SOURCES
#     API_INCLUDE_LINE "#include <igs/OpenIGSAPI.h>"
#     API_DEFINITION   OpenIGS_API
#     INSTALL_DIR      igs
# )
#
# cframe_build_target(
#     ...
#     SOURCES
#         ...
#         ${IGS_VERSION_SOURCES}
# )
# @endcode
# -----------------------------------------------------------------------------
function( cframe_generate_version_files )

  if ( NOT CFRAME_VERSION_GENERATION )
    return()
  endif()

  # -----------------------------------
  # Set up and parse multiple arguments
  # -----------------------------------
  set( options
  )
  set( oneValueArgs
      PRODUCT_NAME
      PRODUCT_TYPE
      PRODUCT_FILE
      VERSION_MAJOR
      VERSION_MINOR
      VERSION_PATCH
      VERSION_BUILD
      VERSION_NAME
      VERSION_YEAR
      VERSION_RELEASETYPE
      TEMPLATE_FILE_PUBLIC
      TEMPLATE_FILE_PRIVATE
      GENERATED_NAME
      GENERATED_EXTENSION_PUBLIC
      GENERATED_EXTENSION_PRIVATE
      GENERATED_SOURCE_GROUP
      GENERATED_OUT_VAR
      API_INCLUDE_LINE
      API_DEFINITION
      INSTALL_DIR
  )
  set( multiValueArgs
  )

  cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
  )

  # Fail when required arguments are not provided
  if ( NOT ARGS_PRODUCT_NAME )
    message( FATAL_ERROR "cframe_version used without specifying PRODUCT_NAME" )
  endif()
  if ( NOT ARGS_GENERATED_OUT_VAR )
    message( FATAL_ERROR "cframe_version used without specifying GENERATED_OUT_VAR" )
  endif()

  # Set default values for unset args
  if ( NOT ARGS_VERSION_MAJOR )
    set( ARGS_VERSION_MAJOR ${CFRAME_VERSION_MAJOR_GLOBAL} )
  endif()

  if ( NOT ARGS_VERSION_MINOR )
    set( ARGS_VERSION_MINOR ${CFRAME_VERSION_MINOR_GLOBAL} )
  endif()

  if ( NOT ARGS_VERSION_PATCH )
    set( ARGS_VERSION_PATCH ${CFRAME_VERSION_PATCH_GLOBAL} )
  endif()

  if ( NOT ARGS_VERSION_BUILD )
    set( ARGS_VERSION_BUILD ${CFRAME_VERSION_BUILD_GLOBAL} )
  endif()

  if ( NOT ARGS_VERSION_NAME )
    set( ARGS_VERSION_NAME ${CFRAME_VERSION_NAME_GLOBAL} )
  endif()

  if ( NOT ARGS_VERSION_YEAR )
    set( ARGS_VERSION_YEAR ${CFRAME_VERSION_YEAR_GLOBAL} )
  endif()

  if ( NOT ARGS_VERSION_RELEASETYPE )
    set( ARGS_VERSION_RELEASETYPE ${CFRAME_VERSION_RELEASETYPE_GLOBAL} )
  endif()

  if ( ARGS_GENERATED_NAME )
    set( GENERATED_NAME ${ARGS_GENERATED_NAME} )
  else()
    set( GENERATED_NAME ${ARGS_PRODUCT_NAME}${CFRAME_VERSION_DEFAULT_GENERATED_NAME_SUFFIX} )
  endif()

  if ( (NOT ARGS_TEMPLATE_FILE_PUBLIC) AND (NOT ARGS_TEMPLATE_FILE_PRIVATE) )
    set( ARGS_TEMPLATE_FILE_PUBLIC  ${CFRAME_VERSION_TEMPLATE_FILE_PUBLIC} )
    set( ARGS_TEMPLATE_FILE_PRIVATE ${CFRAME_VERSION_TEMPLATE_FILE_PRIVATE} )
  endif()

  if ( NOT ARGS_GENERATED_EXTENSION_PUBLIC )
    set( ARGS_GENERATED_EXTENSION_PUBLIC hpp )
  endif()

  if ( NOT ARGS_GENERATED_EXTENSION_PRIVATE )
    set( ARGS_GENERATED_EXTENSION_PRIVATE cpp )
  endif()

  if ( NOT ARGS_GENERATED_SOURCE_GROUP )
    set( ARGS_GENERATED_SOURCE_GROUP Generated )
  endif()

  if ( 0 )
    foreach( arg ${oneValueArgs} )
      message( "  ARGS_${arg}: ${ARGS_${arg}}" )
    endforeach()
  endif()

  # Set variables to be configured in template files
  set( PRODUCT_NAME ${ARGS_PRODUCT_NAME} )
  set( PRODUCT_TYPE ${ARGS_PRODUCT_TYPE} )
  set( PRODUCT_FILE ${ARGS_PRODUCT_FILE} )
  set( VERSION_MAJOR ${ARGS_VERSION_MAJOR} )
  set( VERSION_MINOR ${ARGS_VERSION_MINOR} )
  set( VERSION_PATCH ${ARGS_VERSION_PATCH} )
  set( VERSION_BUILD ${ARGS_VERSION_BUILD} )
  set( VERSION_NAME ${ARGS_VERSION_NAME} )
  set( VERSION_YEAR ${ARGS_VERSION_YEAR} )
  set( VERSION_RELEASETYPE ${ARGS_VERSION_RELEASETYPE} )
  set( API_INCLUDE_LINE ${ARGS_API_INCLUDE_LINE} )
  set( API_DEFINITION ${ARGS_API_DEFINITION} )
  set( GENERATED_EXTENSION_PUBLIC ${ARGS_GENERATED_EXTENSION_PUBLIC} )
  cframe_git_commitid( COMMIT_ID )
  cframe_git_branchid( BRANCH_ID )
  cframe_git_remotename( ${BRANCH_ID} REMOTE_NAME )
  cframe_git_remoteurl( ${REMOTE_NAME} REMOTE_URL )

  # Configure the Public (Header) file and install it
  if ( ARGS_INSTALL_DIR )
    set( GENERATED_SUBDIR ${ARGS_INSTALL_DIR} )
  else()
    set( GENERATED_SUBDIR ${ARGS_PRODUCT_NAME} )
  endif()

  if ( ARGS_TEMPLATE_FILE_PUBLIC )
    set( GENERATED_FILE_PUBLIC
       ${CMAKE_BINARY_DIR}/${GENERATED_SUBDIR}/${GENERATED_NAME}.${ARGS_GENERATED_EXTENSION_PUBLIC}
    )

    configure_file(
       ${ARGS_TEMPLATE_FILE_PUBLIC}
       ${GENERATED_FILE_PUBLIC}
    )
    list( APPEND SOURCES ${GENERATED_FILE_PUBLIC} )

    # Install the public file
    if ( ARGS_INSTALL_DIR )
      INSTALL(
          FILES ${GENERATED_FILE_PUBLIC}
          DESTINATION include/${ARGS_INSTALL_DIR}
      )
    endif()
  endif() # ARGS_TEMPLATE_FILE_PUBLIC

  # Configure the Private (Source) file
  if ( ARGS_TEMPLATE_FILE_PRIVATE )
    set( GENERATED_FILE_PRIVATE
       ${CMAKE_BINARY_DIR}/${GENERATED_SUBDIR}/${GENERATED_NAME}.${ARGS_GENERATED_EXTENSION_PRIVATE}
    )

    configure_file(
       ${ARGS_TEMPLATE_FILE_PRIVATE}
       ${GENERATED_FILE_PRIVATE}
    )
    list( APPEND SOURCES ${GENERATED_FILE_PRIVATE} )
  endif() # ARGS_TEMPLATE_FILE_PRIVATE

  source_group( \\${ARGS_GENERATED_SOURCE_GROUP} FILES ${SOURCES} )
  set( ${ARGS_GENERATED_OUT_VAR} ${SOURCES} PARENT_SCOPE )

endfunction() # cframe_generate_version_files
