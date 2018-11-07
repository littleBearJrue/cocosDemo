
#ifndef __NX_PROTOCOL_H__
#define __NX_PROTOCOL_H__

#include "VxDef.h"
#include <cstring>
#include <cerrno>
#include <cstdio>
#include <csignal>
#include <cstdint>
#include <iostream>
#include <map>
#include <vector>
#include <functional>
#include <memory>
#include <list>
#include <vector>
#include <cassert>

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <WinSock2.h>
#include <windows.h>

#define _WS2_32_WINSOCK_SWAP_LONGLONG(l)            \
            ( ( ((l) >> 56) & 0x00000000000000FFLL ) |       \
              ( ((l) >> 40) & 0x000000000000FF00LL ) |       \
              ( ((l) >> 24) & 0x0000000000FF0000LL ) |       \
              ( ((l) >>  8) & 0x00000000FF000000LL ) |       \
              ( ((l) <<  8) & 0x000000FF00000000LL ) |       \
              ( ((l) << 24) & 0x0000FF0000000000LL ) |       \
              ( ((l) << 40) & 0x00FF000000000000LL ) |       \
              ( ((l) << 56) & 0xFF00000000000000LL ) )

#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC

#include <libkern/OSByteOrder.h>

#endif

#include <netinet/in.h>


#include <sys/socket.h>
#include <unistd.h>

#endif

/*class ProtocolHeader
{
public:
	ProtocolHeader(int nFrameSize = 0, int nSessionId = 0, int nMsgCount = 1)
		: m_nFrameSize(nFrameSize), m_nSessionId(nSessionId), m_nMsgCount(nMsgCount)
	{
	}
public:
	int m_nFrameSize;
	int m_nSessionId;
	int m_nMsgCount;
};*/




class MsgHeader
{
public:
	MsgHeader(short int nMsgType = 0, int nMsgSize = 0)
		: m_nMsgType(nMsgType), m_nMsgSize(nMsgSize)
	{
	}
	enum 
	{
		NF_HEAD_LENGTH = 6,
	};

	int64_t NF_HTONLL(int64_t nData)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

		const unsigned __int64 Retval = _WS2_32_WINSOCK_SWAP_LONGLONG(nData);
		return Retval;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
		return HTONLL(nData);
#else
		return htobe64(nData);
#endif
	}

	int64_t NF_NTOHLL(int64_t nData)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		const unsigned __int64 Retval = _WS2_32_WINSOCK_SWAP_LONGLONG(nData);
		return Retval;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		return NTOHLL(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
		return betoh64(nData);
#else
		return be64toh(nData);
#endif
	}

	int32_t NF_HTONL(int32_t nData)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		return htonl(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		return HTONL(nData);
#else
		return htobe32(nData);
#endif
	}

	int32_t NF_NTOHL(int32_t nData)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		return ntohl(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		return NTOHL(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
		return betoh32(nData);
#else
		return be32toh(nData);
#endif
	}

	int16_t NF_HTONS(int16_t nData)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		return htons(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		return HTONS(nData);
#else
		return htobe16(nData);
#endif
	}

	int16_t NF_NTOHS(int16_t nData)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		return ntohs(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		return NTOHS(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
		return betoh16(nData);
#else
		return be16toh(nData);
#endif
	}

public:
	short int m_nMsgType;
	int m_nMsgSize;
};

class NxProtocol 
{
public:
	static int getEventType(int nProtocolMsgType);
	static int getProtocolType(int nEventType);

public:
	

	

public:
	NxProtocol();
	~NxProtocol();
	
};

#endif	// __NX_PROTOCOL_H__

