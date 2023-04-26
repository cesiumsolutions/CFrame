/* -*-c++-*- OpenIGS - Copyright (C) 2009-2019 OpenIGS Consortium
 * This file is subject to the terms and conditions defined in the file
 * 'OPENIGS-LICENSE.txt', which is part of this source code package.
 */

#ifndef cframe_version_VersionInfo_hpp
#define cframe_version_VersionInfo_hpp

#include <cframe/version/cframeVersionAPI.h>

#include <string>
#include <vector>

#if defined( _MSC_VER )
#  pragma warning( push )
#  pragma warning( disable : 4251 ) // needs to have dll-interface to be used by
                                    // clients of class
#endif

namespace cframe {

using StringVec = std::vector<std::string>;

/**
 * @brief Provides version information.
 * @ingroup utility
 *
 */
class CFRAMEVERSION_API VersionInfo
{
public:
  /**
   * @name Structors
   * Methods for constructing and initializing the VersionInfo.
   */
  /**@{*/

  /** Default constructor. */
  VersionInfo();

  /** Initializing constructor. */
  explicit VersionInfo( std::string const & productName,
                        std::string const & productType,
                        std::string const & productFile = "",
                        uint8_t             major       = 0,
                        uint8_t             minor       = 0,
                        uint8_t             patch       = ~0,
                        uint8_t             build       = ~0,
                        std::string const & name        = "",
                        std::string const & releaseType = "",
                        std::string const & commitId    = "" );

  /** Destructor. */
  ~VersionInfo();

  /**@}*/

  /**
   * @name Accessors
   * Methods to retrieve the characteristics of the VersionInfo.
   */
  /**@{*/

  /** Queries whether any data is set (actually only if productName is empty).
   */
  bool isEmpty() const;

  std::string productName; /**< The name of the product (e.g. application or
                              library) being represented by this version. */
  std::string productType; /**< The type of the product, e.g. Application,
                              Library, ModulePackage, Plugin, UnitTest, etc. */
  std::string productFile; /**< The (base) name of the filename on disk
                              containing the implementation of the product. */
  uint8_t     major;       /**< The major version number. */
  uint8_t     minor;       /**< The minor version number. */
  uint8_t     patch;       /**< The patch version number. */
  uint8_t     build;       /**< The build version number. */
  std::string name;        /**< The name used to refer to this version. */
  std::string
      releaseType;      /**< The release distribution type, e.g. Alpha, Beta,
                           ReleaseCandidate, Release, Experimental, Development. */
  std::string commitId; /**< The id for the commit in the source code version
                           control system. */

  /** Retrieve a string appropriate for use in displaying the version
   * information for the product. */
  std::string getDisplayString() const;

  /** Retrieve a string appropriate for use in packaging the product. */
  std::string getPackageString() const;

  /** Retrieve the version numbers in '.' format. */
  std::string getNumberString() const;

  /** Retrieve the version numbers bit-combined into a single number. */
  uint32_t getVersionNumber() const;

  /** Retrieve the build configuration used for building the binary version of
   * the product. */
  std::string getBuildConfiguration() const;

  /**@}*/

  /**
   * @name Global
   * Methods Application-wide VersionInfo operations.
   */
  /**@{*/

  using VersionInfoVec = std::vector<cframe::VersionInfo>;

  /** Return list of all registered versions. */
  static VersionInfoVec const & versionInfos();

  /** Return list of all registered products. */
  static StringVec products();

  /** Get version information for specified product. */
  static cframe::VersionInfo
  getRegisteredVersionInfo( std::string const & productName );

  /** Add VersionInfo information to internal registry. */
  static bool registerVersionInfo( cframe::VersionInfo const & versionInfo );

  /**@}*/

}; // class VersionInfo

extern CFRAMEVERSION_API bool operator==( cframe::VersionInfo const & lhs,
                                          cframe::VersionInfo const & rhs );
extern CFRAMEVERSION_API bool operator!=( cframe::VersionInfo const & lhs,
                                          cframe::VersionInfo const & rhs );
extern CFRAMEVERSION_API bool operator<( cframe::VersionInfo const & lhs,
                                         cframe::VersionInfo const & rhs );

} // namespace cframe

/**
 * @brief Macro to automatically register a VersionInfo object upon startup or
 * when library is loaded.
 * @ingroup utility
 * This should be placed in a .cpp file in the global namespace for a product.
 * The CFrame CMake-based build system automates this process by providing the
 * cframe_generate_version_files() macro which should be placed in the
 * CMakeLists.txt (or other appropriate cmake configuration file) for the
 * product just before the add_executable() or add_library() call.
 *
 * @see cframe_generate_version_files
 */
#define CFRAME_DEFINE_GET_VERSION_INFO( _productName,                          \
                                        _productType,                          \
                                        _productFile,                          \
                                        _major,                                \
                                        _minor,                                \
                                        _patch,                                \
                                        _build,                                \
                                        _name,                                 \
                                        _releaseType,                          \
                                        _commitId )                            \
  cframe::VersionInfo const & get##_productName##VersionInfo()                 \
  {                                                                            \
    static cframe::VersionInfo s_VersionInfo( #_productName,                   \
                                              #_productType,                   \
                                              #_productFile,                   \
                                              _major,                          \
                                              _minor,                          \
                                              _patch,                          \
                                              _build,                          \
                                              _name,                           \
                                              #_releaseType,                   \
                                              #_commitId );                    \
    return s_VersionInfo;                                                      \
  }                                                                            \
  static bool s_##_productNameCFrameVersionInfoRegistered =                    \
      cframe::VersionInfo::registerVersionInfo(                                \
          get##_productName##VersionInfo() )

#if defined( _MSC_VER )
#  pragma warning( pop )
#endif

#endif // cframe_version_VersionInfo_hpp
