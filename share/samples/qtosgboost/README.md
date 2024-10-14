# QtOSGBoost Example Library and Application

This sample project is intended as a starting point for testing and implementing
CFrame functionality. It is a fully functional library which exports symbols and
uses some commonly used external libaries.

## Prerequisites:

Ubuntu:
    Install the following packages: (e.g. with sudo apt install <package>)
    - libboost-all_dev
    - qtbase5-dev
    - libopenscenegraph-dev

Windows:
    Have precompiled libraries available, e.g. from openigs-extern-win repo.

## CMake Configuration Variables

All:
    CMAKE_INSTALL_PREFIX:PATH - path to where to install
    - e.g.: /path/to/install/qtosgbooost

Windows:
    BOOST_ROOT:PATH - path to boost installation
    - e.g.: /path/to/openigs-extern-win/boost_1_81_0

    QTDIR:PATH - path to Qt installation
    e.g.:
    - C:/Qt/Qt5.15.1/5.15.1/msvc2019_64
    - /path/to/openigs-extern-win/Qt5.15.1/5.15.1/msvc2019_64

    OSG_DIR:PATH - path to OpenSceneGraph installation
    - e.g.: /path/to/openigs-extern-win/win64-vc17/OpenSceneGraph-3.6.

## Post-installation

Windows:
    Copy the external dependencies to install
    e.g.:
    - from: /path/to/openigs-extern-win/win64-vc17/openigs-2.8.0-deps/minimal/Release
    - to: /path/to/install/qtosgboost/bin

## Execution

Linux:
    - set LD_LIBRARY_PATH to, e.g.: /path/install/install/qtosgboost/lib

All:
    - run the qtosgboostviewer executable in the /path/to/install/qtosgboost/bin directory
