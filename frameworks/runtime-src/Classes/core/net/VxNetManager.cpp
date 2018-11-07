
#include "VxNetManager.h"
#include "VxNetClient.h"
#include "VxMsg.h"
#include "VxStream.h"
#include "NxProtocol.h"
#include "VxBlockAllocator.h"
#include "VxDef.h"
VxAllocator* s_alloc;

#define NXPROTOCOL_FRMAE_METAHEADER_SIZE					((int)sizeof(int))

static std::map<int, VxNetClient*> s_sNetMap;
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
static int init_win_socket()
{
	static bool hasInit = false;
	if (!hasInit)
	{	
		hasInit = true;
		WSADATA wsaData;
		if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0)
		{
			return -1;
		}
		return 0;
	}
	else
	{
		return 0;
	}
}
#endif

VxNetManager::VxNetManager()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	init_win_socket();
#endif

	s_alloc = new VxBlockAllocator();
	//s_alloc = new VxAllocator();
	s_alloc->init();
	VxAlloc::setAlloc(s_alloc);
}

VxNetManager::~VxNetManager()
{

}

void VxNetManager::connectToServer(int nNetSocketId, std::string sIp, short port)
{
	if (!hasConnectServer(nNetSocketId))
	{
		//s_sNetMap[sServerName] = VxNetAddress(sServerName,sIp, port);
		s_sNetMap[nNetSocketId] =  new VxNetClient(nNetSocketId, sIp.c_str(), port);
		s_sNetMap[nNetSocketId]->registerEventCb(VxNetManager::socketEventCallback, s_sNetMap[nNetSocketId]);
		s_sNetMap[nNetSocketId]->connect();
	}
	else
	{
		printf("connectToServer has connect server %d\n", nNetSocketId);
	}
}

void VxNetManager::disconnectToServer(int nNetSocketId)
{
	auto it = s_sNetMap.find(nNetSocketId);
	

	if (it != s_sNetMap.end())
	{
		it->second->close();
		CC_SAFE_DELETE(it->second);
		s_sNetMap.erase(it);
		
		printf("disconnectToServer has connect server %d\n", nNetSocketId);
	}
	else
	{
		printf("disconnectToServer  server %d not exist", nNetSocketId);
	}
}


bool VxNetManager::hasConnectServer(int nNetSocketId)
{
	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		return true;
	}
	
	return false;
}



static VxMsgNetSendStream* createStream(int nMsgType, int nMsgSize,const char* pMsgData)
{

	//MsgHeader sMsgHeader(nMsgType, nMsgSize);



	VxMsgNetSendStream* pMsg = NULL;
	VxMemStream* pStream = NULL;
	do
	{
	
		//VxMemStream* pStream = new VxMemStream(nMsgSize + sizeof(MsgHeader), false);
		VxMemStream* pStream = new VxMemStream(nMsgSize, false);
		VxMsgNetSendStream* pMsg = VX_NEW_MSG(VxMsgNetSendStream)(pStream);//new VxMsgNetSendStream(pStream);//
		pStream->release();

		if (!pStream || !pMsg)
		{
			break;
		}
		
		//head
		/*unsigned short int temp = sMsgHeader.m_nMsgType;
		temp = sMsgHeader.NF_HTONS(temp);
		pStream->write( (char*)&temp, sizeof(short int));

		unsigned int nSize = sMsgHeader.m_nMsgSize + MsgHeader::NF_HEAD_LENGTH;
		nSize = sMsgHeader.NF_HTONL(nSize);
		pStream->write((char*)&nSize, sizeof(unsigned int));
		*/
		//data
		pStream->write((char*)pMsgData, nMsgSize);
		pStream->seek(0);
		return pMsg;

	} while (0);

	VX_SAFE_RELEASE_NULL(pStream);
	VX_SAFE_RELEASE_NULL(pMsg);

	return NULL;
}

void VxNetManager::sendMsgToServer(int nNetSocketId, const char* sMsgData,int nMsgSize)
{


	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		VxMsgNetSendStream* pSendStream = createStream(0, nMsgSize, sMsgData);

		it->second->send(pSendStream);
		//return true;
	}

}


void VxNetManager::socketEventCallback(void* pArg, int eEventId, void *pvEventArgs)
{
	VxNetClient* pClient = (VxNetClient*)pArg;
	//VXASSERT(0 <= nSocketId && nSocketId < NX_NET_SOCKET_MAXCOUNT, "");
	//VxNetClient* pClient = s_pNetData[nSocketId].m_pClient;
	VX_RETURN_IF(!pClient);

	switch (eEventId)
	{
	case VXSOCKET_EVENT_CONNECT_BEGIN:
		break;
	case VXSOCKET_EVENT_CONNECT_COMPLETE:
		break;
	case VXSOCKET_EVENT_CONNECT_FAILED:
		break;
	case VXSOCKET_EVENT_CLOSED:
		//NxNetManager::socketEventAsyncCallback(pArg, eEventId, pvEventArgs);
		break;
	default:
		break;
	}
}