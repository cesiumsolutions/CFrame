/* -*-c-*- OpenIGS - Copyright (C) 2009-2019 OpenIGS Consortium
 * This file is subject to the terms and conditions defined in the file
 * 'OPENIGS-LICENSE.txt', which is part of this source code package.
 */

#ifndef qtosgboostapi_h
#define qtosgboostapi_h

#ifdef __cplusplus
extern "C" {
#endif

/* Definitions for exporting or importing the QtOSGBoost Library API */
#if defined( _MSC_VER ) || defined( __CYGWIN__ ) || defined( __MINGW32__ ) ||  \
    defined( __BCPLUSPLUS__ ) || defined( __MWERKS__ )
#  if defined qtosgboost_STATIC
#    define QTOSGBOOST_API
#  elif defined qtosgboost_EXPORTS
#    define QTOSGBOOST_API __declspec( dllexport )
#  else
#    define QTOSGBOOST_API __declspec( dllimport )
#  endif
#else
#  define QTOSGBOOST_API
#endif

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* qtosgboostapi_h */
