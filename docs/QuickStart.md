# CFrame: Quick Start Guide
---------------------------

If you have an existing CMake-based software project, just place it under the
projects directory. You can place any number of projects there. Alernatively you
can set the ```CFRAME_PROJECTS_DIR``` to point to where your projects are located.
Then configure CMake to use the top level of this framework as the build directory.
A variable for each subdirectory named ```BUILD_PROJECT_<dir name>``` will be added
as options which can be toggled dynamically, e.g. with cmake-gui.

If your project will be used by other that are specified as packages, you will
have to add one file in the root directory of your project called CFrameLists.txt.
In this file you should set the same variables that would be set in a similar way
that FindPackage() for would for your package. For example:

  * <PROJECT>_FOUND
  * <PROJECT>_VERSION
  * <PROJECT>_DEFINITIONS
  * <PROJECT>_INCLUDE_DIRS
  * <PROJECT>_LIBRARY_DIRS
  * <PROJECT>_LIBRARIES

Alternatively the ```cframe_publish_project()``` function can be used, for example:

```
cframe_publish_project(
    PROJECT ${CFRAME_CURRENT_PROJECT_NAME}
    VERSION 0 1 0 0
    DEFINITIONS
        -DSOME_SPECIAL_FLAG
    INCLUDE_DIRS
        ${CFRAME_CURRENT_PROJECT_DIR}/libs/
    LIBRARY_DIRS
    LIBRARIES
        library1
        library2
        library3
)
```

The ```CFRAME_CURRENT_PROJECT_DIR``` variable contains the name of the directory
where the current project is located, and the ```CMAKE_CURRENT_PROJECT_NAME```
contains the name of the current project. These will probably be helpful when
defining the above variables.

In the CFramePrepare.cmake you can also specify any external dependencies your
package will be using using the function:

```cframe_use_external_package( PACKAGE <package name> COMPONENTS <components...> )```

For example:
```
cframe_use_external_package(
    PACKAGE Boost
    COMPONENTS
        program_options
        signals
        system
        unit_test_framework
)
```

If multiple packages specify the same external package, then all the COMPONENTS
will be merged and the external package loaded once.

A fully compilable (and functional) example is included in the projects/cframedemo
subdirectory. The CFramePrepare.cmake for this demo can be found [here](./projects/cframedemo/CFramePrepare.cmake)

The CFrame framework provides additional utility and project-based functions.
For example, for building all but the most simple of projects, the ```cframe_build_target()```
function consolidates all of the most common tasks into one parameterized function.
It even includes handling of Qt-specific things which can be a pain to do manually.
For example:

```
cframe_build_target(
    BASENAME MyLib
    TYPE     Library
    GROUP    MyGroup
    INCLUDE_DIRS
        ..
    HEADERS_PUBLIC
        API.h
        QModelGUI.hpp
        Model.hpp
    HEADERS_PRIVATE
        ModelPrivate.hpp
    SOURCES
        QModelGUI.cpp
        Model.cpp
    QT_MOCFILES
        QModelGUI.hpp
    LIBRARIES
        ${QT_LIBRARIES}
    HEADER_INSTALL_DIR
        include/MyLib
)
```

The ```CMakeLists.txt``` files for the CFrameDemo can be found 
[here](./projects/cframedemo/libs/CFrameDemo/CMakeLists.txt)

## Further Reading

The full user manual can be found [here](Manual.md).
License information can be found [here](License.md).
