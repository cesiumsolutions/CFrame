/* -*-c-*- OpenIGS - Copyright (C) 2009-2019 OpenIGS Consortium
 * This file is subject to the terms and conditions defined in the file
 * 'OPENIGS-LICENSE.txt', which is part of this source code package.
 */

#ifndef cframe_version_VersionAPI_h
#define cframe_version_VersionAPI_h

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @file cframeVersionAPI.h
 * @brief Linkage definitions for CFrame Version Library API
 */

/**
 * @namespace cframe
 * @brief the namespace used by all CFrame Version software components.
 */

/* Definitions for exporting or importing the CFrame Version Library API */
#if defined( _MSC_VER ) || defined( __CYGWIN__ ) || defined( __MINGW32__ ) ||  \
    defined( __BCPLUSPLUS__ ) || defined( __MWERKS__ )
#  if defined cframeversion_STATIC
#    define CFRAMEVERSION_API
#  elif defined cframeversion_EXPORTS
#    define CFRAMEVERSION_API __declspec( dllexport )
#  else
#    define CFRAMEVERSION_API __declspec( dllimport )
#  endif
#else
#  define CFRAMEVERSION_API
#endif

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* cframe_version_VersionAPI_h */
