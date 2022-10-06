CFrame Subsystems:
------------------

# Targets:
- Declarative form of functions for defining:
  - targets
  - file groups
  - file exclusions

# Version:
- Conventions and Declarative form of functions for setting up version files and
  information
- Sub framework for getting information from version control system:
  - Git
  - Mercurial
  - Subversion
  - CVS

# Copyright:
- Conventions and Declarative form of functions for setting up copyright notices.

# Projects:
- Conventions and functions for dynamically specifying projects to include in
  build

# Extern:
- Sub framework for configuring different ways of handling external/3rd party
  dependencies
  - Manual: Location of external dependencies specified manually
  - Automatic: Use OS/Platforms specific method for automatically locating
               external dependencies (e.g. Linux various package managers)
  - Conan: Use Conan for handling external dependencies
  - Vcpkg: Use Vcpkg for handling external dependencies
  - Hunter: Use Hunter "    "        "         "
  - Chocolatey: Use Chocolatey "  "  " "
  - Brew: Use Brew "   "   "   "

# UnitTest:
- Subframework for configuring different unit test frameworks:
  - Catch2
  - Boost.UnitTest
  - GoogleTest
  
