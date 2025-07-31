/* -*-c++-*- OpenIGS - Copyright (C) 2009-2019 OpenIGS Consortium
 * This file is subject to the terms and conditions defined in the file
 * 'OPENIGS-LICENSE.txt', which is part of this source code package.
 */

#include "VersionInfo.hpp"

#include <boost/algorithm/string.hpp>
#include <boost/serialization/singleton.hpp> // to be replaced in the future by a generic singleton

#include <exception>
#include <sstream>

// See https://bugzilla.redhat.com/show_bug.cgi?id=130601
#if defined major
#  undef major
#endif
#if defined minor
#  undef minor
#endif

namespace cframe {

using TheVersions =
    boost::serialization::singleton<VersionInfo::VersionInfoVec>;

class VersionInfoException : public std::exception
{
public:
  VersionInfoException( std::string const & message ) : mMessage( message )
  {
  }
  ~VersionInfoException() override = default;

  char const * what() const noexcept override
  {
    return mMessage.c_str();
  }

private:
  std::string mMessage;
}; // class VersionInfoException

VersionInfo::VersionInfo()
    : productName()
    , productType()
    , productFile()
    , major( 0 )
    , minor( 0 )
    , patch( ~0 )
    , build( ~0 )
    , name()
    , releaseType()
    , commitId()
{
} // VersionInfo::VersionInfo

VersionInfo::VersionInfo( std::string const & prodName,
                          std::string const & prodType,
                          std::string const & prodFilename,
                          uint8_t             maj,
                          uint8_t             min,
                          uint8_t             ptch,
                          uint8_t             bld,
                          std::string const & nm,
                          std::string const & relType,
                          std::string const & commId )
    : productName( prodName )
    , productType( prodType )
    , productFile( prodFilename )
    , major( maj )
    , minor( min )
    , patch( ptch )
    , build( bld )
    , name( nm )
    , releaseType( relType )
    , commitId( commId )
{
  if ( productName.empty() ) {
    throw VersionInfoException( "VersionInfo product name is empty" );
  }
} // VersionInfo::VersionInfo

VersionInfo::~VersionInfo()
{
} // VersionInfo::~VersionInfo

bool
VersionInfo::isEmpty() const
{
  return productName.empty();
} // VersionInfo::isEmpty

std::string
VersionInfo::getDisplayString() const
{
  std::ostringstream oss;

  oss << productName << " " << getNumberString() << " ";

  if ( !name.empty() ) {
    oss << '(' << name << ") ";
  }

  oss << releaseType << " "
      << boost::algorithm::to_lower_copy( getBuildConfiguration() );

  return oss.str();
} // VersionInfo::getDisplayString

std::string
VersionInfo::getPackageString() const
{
  std::ostringstream oss;
  oss << boost::algorithm::to_lower_copy( productName ) << '-'
      << getNumberString() << boost::algorithm::to_lower_copy( releaseType )
      << '-' << boost::algorithm::to_lower_copy( getBuildConfiguration() );
  return oss.str();
} // VersionInfo::getPackageString

std::string
VersionInfo::getNumberString() const
{
  std::ostringstream oss;
  oss << (int)major << '.' << (int)minor;

  if ( patch != 0xff ) {
    oss << '.' << (int)patch;
    if ( build != 0xff ) {
      oss << '.' << (int)build;
    }
  }

  return oss.str();
} // VersionInfo::getNumberString

uint32_t
VersionInfo::getVersionNumber() const
{
  uint32_t number =
      ( major << 24 ) + ( minor << 16 ) +
      ( patch != static_cast<uint8_t>( ~0 ) ? ( patch << 8 ) : 0 ) +
      ( build != static_cast<uint8_t>( ~0 ) ? ( build << 0 ) : 0 );
  return number;
} // VersionInfo::getVersionNumber

std::string
VersionInfo::getBuildConfiguration() const
{
#if defined DEBUG || defined _DEBUG
  return "Debug";
#else
  return "Optimized";
#endif
} // VersionInfo::getBuildConfiguration

VersionInfo::VersionInfoVec const &
VersionInfo::versionInfos()
{
  return TheVersions::get_const_instance();
} // VersionInfo::versions

StringVec
VersionInfo::products()
{
  StringVec              prods;
  VersionInfoVec const & vs = versionInfos();
  for ( std::size_t v = 0; v < vs.size(); ++v ) {
    prods.push_back( vs[v].productName );
  }
  return prods;
} // VersionInfo::products

cframe::VersionInfo
VersionInfo::getRegisteredVersionInfo( std::string const & productName )
{
  VersionInfoVec const & versInfos = versionInfos();
  for ( std::size_t v = 0, vz = versInfos.size(); v < vz; ++v ) {
    if ( versInfos[v].productName == productName ) {
      return versInfos[v];
    }
  }

  return VersionInfo();
} // VersionInfo::getRegisteredVersion

bool
VersionInfo::registerVersionInfo( cframe::VersionInfo const & versionInfo )
{
  VersionInfoVec &         versInfos = TheVersions::get_mutable_instance();
  VersionInfoVec::iterator viiter =
      std::find( versInfos.begin(), versInfos.end(), versionInfo );
  if ( viiter != versInfos.end() ) {
    return false;
  }

  versInfos.push_back( versionInfo );
  return true;
} // VersionInfo::registerVersion

bool
operator==( cframe::VersionInfo const & lhs, cframe::VersionInfo const & rhs )
{
  return lhs.productName == rhs.productName &&
         lhs.productType == rhs.productType &&
         lhs.productFile == rhs.productFile &&
         lhs.getVersionNumber() == rhs.getVersionNumber() &&
         lhs.name == rhs.name && lhs.releaseType == rhs.releaseType &&
         lhs.getBuildConfiguration() == rhs.getBuildConfiguration();
} // operator==

bool
operator!=( cframe::VersionInfo const & lhs, cframe::VersionInfo const & rhs )
{
  return !operator==( lhs, rhs );
} // operator!=

bool
operator<( cframe::VersionInfo const & lhs, cframe::VersionInfo const & rhs )
{
  return lhs.productName == rhs.productName
             ? lhs.getVersionNumber() < rhs.getVersionNumber()
             : lhs.productName < rhs.productName;
} // operator<

} // namespace cframe
