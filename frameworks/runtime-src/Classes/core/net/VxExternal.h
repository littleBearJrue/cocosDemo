
#ifndef __VX_EXTERNAL_H__
#define __VX_EXTERNAL_H__


#include "cocos2d.h"
#include "cocos-ext.h"

#include <ctime>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iostream>
#include <algorithm>
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <regex>
#endif
#include <sys/stat.h>


/************************************************************************/
/* Protobuf
/************************************************************************/
#include <google/protobuf/message_lite.h>
#include <google/protobuf/stubs/common.h>

/************************************************************************/
/* Jni
/************************************************************************/
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <jni.h>
#endif

/************************************************************************/
/* Error
/************************************************************************/
#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
#include <errno.h>
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

/************************************************************************/
/* Socket
/************************************************************************/
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
/* Namespace
/************************************************************************/

USING_NS_CC;
USING_NS_CC_EXT;
using namespace std;

/************************************************************************/
/* int type
/************************************************************************/
typedef unsigned int uint;

#ifdef _MSC_VER
typedef __int8  int8;
typedef __int16 int16;
typedef __int32 int32;
typedef __int64 int64;

typedef unsigned __int8  uint8;
typedef unsigned __int16 uint16;
typedef unsigned __int32 uint32;
typedef unsigned __int64 uint64;
#else
typedef int8_t  int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

typedef uint8_t  uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;
#endif

#endif	// __VX_EXTERNAL_H__
