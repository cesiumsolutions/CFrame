# CFrame TODO

- Auto install of external dependencies
  - including implicit dependencies, e.g. plugin dlls
  - Nonexistent

- External Dependency Management
  V Manual (CFRAME_EXTERN_DIR)
  - vcpkg
  - Conan
    - consumer
    - producer
  - CMake Package Manager
  x hunter

- Building of internal packages
  - as part of build process
  - as imported packages
  - make CMake for those packages compatible with both situations
  - pkgconfig

- Test Tool Integration
  - Catch2
  - Boost Unit Test
  - Google Test

- Version Management

- Android Build Support

- CI/CD
  - one-step checkout/build/test/deploy
  - integration with build servers

## CMake New Features

- Types:
  - support plural versions, STRINGS, DIRECTORIES, FILEPATHS, etc
  - cmake-gui supports plural versions

- coupled options
  - e.g. when one option is toggled on, a set of other options should also be toggled on
  - hierarchy of options
  - many-to-many relationship
