# CFrame: A CMake-based source code framework
---------------------------------------------

CFrame is a higher level framework for organizing and setting up CMake-based
software projects. it is primarily intended for more complex projects that may have multiple components that can be mixed and and may be shared among several projects. CFrame allows you to organize these projects while also separating and sharing CMake scripts, or using some standard CMake scripts that CFrame offers.

The guiding principles of CFrame include:

- Application of software design principles to CMake scripts, including modularity, scalability, and reuse.
- Be as non-intrusive as possible, offering users the choice as to what degree and how they want to use CFrame in their own projects.
- Function as a repository for general-purpose or reusable scripts that incorporate CMake best practices and offer common functionality needed by larger software projects that is not included in CMake





It provides a library of commonly used functions and a
module directory structure where any number of software projects can be
plugged in and they immediately inherit all of the functionality provided
by the framework.

The framework aims to be as non-intrusive as possible to allow existing
software projects to be integrated, although there are some intrusive
conventions which will allow a software project to take advantage of some
of the provided facilities.

The purpose is to provide a common standard framework to take care of much
of the boilerplate code and to avoid having to copy CMake script files
between projects. Also, a project can be divided up into smaller components
which allows one to be more selective with what is built.

The [Quick Start Guide](./docs/QuickStart.md) provides the basic information
to setup a project using CFrame.  
The [User's Manual](./docs/Manual.md) provides a more in depth guide for using
CFrame.  
The [Reference Guide](./docs/ReferenceGuide.md) provides a references for all
functions and variables provided by CFrame.
License information can be found [here](.docs/License.md).
