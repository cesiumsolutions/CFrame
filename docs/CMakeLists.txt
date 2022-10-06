cframe_build_target(
    TARGET_NAME   ${PROJECT_NAME}_docs
    PROJECT_LABEL Documents
    GROUP         CFrameSources
    TYPE          Custom
    FILES_PUBLIC
        License.md
        Manual.md
        QuickStart.md
        ../README.md
    FILES_INSTALL_DIR
        docs/${PROJECT_NAME}
)
