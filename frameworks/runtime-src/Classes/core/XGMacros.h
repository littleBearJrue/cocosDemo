#ifndef __XG_MACROS_H__
#define __XG_MACROS_H__
#include "cocos2d.h"
#include <ctime>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iostream>
#include <algorithm>
#include <map>
#include <functional>

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <regex>
#endif


#include <sys/stat.h>


#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <winsock.h>   
typedef int socklen_t;
#else
#include <sys/socket.h>
#include <netinet/in.h>   
#include <netdb.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <arpa/inet.h>
typedef int SOCKET;
#define INVALID_SOCKET -1   
#define SOCKET_ERROR -1  
#endif


/************************************************************************/
/* File
/************************************************************************/
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <direct.h>
#include <io.h>
#else
#include <unistd.h>
#endif


#define VXFILE_OPEN_MODE_CREATE_ALWAYS					"wb+"
#define VXFILE_OPEN_MODE_CREATE							"rb+"
#define VXFILE_OPEN_MODE_APPEND							"ab+"


#define XG_SINGLETON(T) static T *getInstance() \
{\
	static T * pInstance = NULL;\
	if(!pInstance)\
{\
	pInstance = new T();\
}\
	return pInstance;\
}


#define XG_SINGLET_DECLARE(T) \
	public: \
	static T** getSingletInstancePtr() \
		{ \
	static T* m_pInst = NULL; \
	return &m_pInst; \
		} \
	static T* getInstance() \
		{ \
	T** m_pInst = getSingletInstancePtr(); \
	if(!(*m_pInst)) \
			{ \
		*m_pInst = new T(); \
			} \
		return *m_pInst; \
		} \
	static void pureInstance() \
		{ \
	T** m_pInst = getSingletInstancePtr(); \
	if(*m_pInst) delete(*m_pInst); \
	*m_pInst = NULL; \
		} 


#define XG_RETURN_IF(a) \
	if(a) \
{\
	return; \
}


#define XG_RETURN_VALUE_IF(a,b) \
	if(a) \
{\
	return b; \
}


#define XG_SAFE_DELETE(a) if(a != nullptr){ delete a; a = nullptr; }


#define XG_SINGLET_WITH_INIT_DECLARE(T) \
	public: \
	static T** getSingletInstancePtr() \
{ \
	static T* m_pInst = NULL; \
	return &m_pInst; \
} \
	static T* getInstance() \
{ \
	T** m_pInst = getSingletInstancePtr(); \
if (!(*m_pInst)) \
{ \
	*m_pInst = new T(); \
} \
	return *m_pInst; \
} \
	static void pureInstance() \
{ \
	T** m_pInst = getSingletInstancePtr(); \
if (*m_pInst) delete(*m_pInst); \
	*m_pInst = NULL; \
} \
	static void init()\
{\
	getInstance(); \
}\
	static void release()\
{\
	pureInstance(); \
}

/************************************************************************/
/* int type
/************************************************************************/
typedef unsigned int uint;

USING_NS_CC;

#ifdef _MSC_VER

#ifdef B2_SETTINGS_H

#else
typedef __int8  int8;
typedef __int16 int16;
typedef __int32 int32;
typedef unsigned __int8  uint8;
typedef unsigned __int16 uint16;
typedef unsigned __int32 uint32;
#endif

typedef __int64 int64;
typedef unsigned __int64 uint64;

#else

#ifdef B2_SETTINGS_H

#else
typedef int8_t  int8;
typedef int16_t int16;
typedef int32_t int32;
typedef uint8_t  uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
#endif

typedef int64_t int64;
typedef uint64_t uint64;
#endif

#ifdef DEBUG
#define FILE_PATH_PRE  "../Server/data/"
#else
#define FILE_PATH_PRE  "data/"
#endif


#endif /* __XG_DEFINE_H__ */
