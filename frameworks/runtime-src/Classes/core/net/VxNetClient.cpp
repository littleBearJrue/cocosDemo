
#include "VxNetClient.h"
#include "VxMsg.h"
#include "VxTime.h"
//#include "VxTimer.h"
//#include "VxEnv.h"
#include "VxLocalObject.h"
//#include "VxMsgManager.h"
#include "VxDef.h"
#include "VxIOStream.h"
#include "XGCCallLuaManager.h"
#include "NxProtocol.h"


#define __VX_NET_CLIENT_USE_MEMORY_BUFFER__

/************************************************************************/
/* VxNetAddress
/************************************************************************/
VxNetAddress::VxNetAddress()
	: m_nPort(0)
	, m_sAddress("")
{
}

VxNetAddress::VxNetAddress(const std::string& sServerName, const std::string& sAddress, int nPort)
	: m_sAddress(sAddress)
	, m_nPort(nPort)
	, m_sServerName(sServerName)
{
}

/************************************************************************/
/* VxNetSendStreamData
/************************************************************************/
class VxNetSendStreamData
{
public:
	VxNetSendStreamData(VxNetSendCb func, void* arg, int startPos, int totalSize)
		: m_func(func), m_arg(arg), m_startPos(startPos), m_sentSize(0), m_totalSize(totalSize), m_lastCallbackTime(0)
	{
	}

	void runEventCb(int eventId, void* eventArg)
	{
		if(m_func)
		{
			int nTime = VxTime::getCurrMilliSecs();
			//if(m_lastCallbackTime + VxEnvNet::getSendEventCbDuration() <= nTime)
			{
				m_lastCallbackTime = nTime;
				//VxMsgManager::dispatchExecMsg(VXMODULE_ID_DATA, (VxFuncPtrAAA)m_func, m_arg, (void*)eventId, eventArg);
			}
			//m_func(m_arg, eventId, eventArg);
		}
	}
public:
	VxNetSendCb m_func;
	void* m_arg;
	int m_totalSize;
	int m_startPos;
	int m_sentSize;
	int64 m_lastCallbackTime;
};


/************************************************************************/
/* VxNetClient
/************************************************************************/

VxNetClient::VxNetClient(int nNetSocketId, const char* addr, unsigned port)
	//: VxMsgModule(VXMODULE_ID_DYNAMIC)
{
	m_nConnectCount = 0;
	m_nNetSocketId = nNetSocketId;
	m_socket = new VxSocketClient(addr, port);
	m_socket->setInternalBufferSize(VXSOCKETCLIENT_INTERNAL_BUFFER_SIZE);
	m_socket->registerEventCb(VxNetClient::_netClientEventCb, this);

#if defined(__VX_NET_CLIENT_USE_MEMORY_BUFFER__)

#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	m_recvBuffer = new VxCacheIOStream(64, 128);
	m_sendBuffer = new VxCacheIOStream(64, 128);
#else
	m_recvBuffer = new VxCacheIOStream(VXSTREAM_MEMORY_BUFFER_DEFAULT_SIZE);
	m_sendBuffer = new VxCacheIOStream(VXSTREAM_MEMORY_BUFFER_DEFAULT_SIZE);
#endif

#else

#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	m_recvBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str(), 128);
	m_sendBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str(), 128);
#else
	m_recvBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str());
	m_sendBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str());
#endif

#endif
	m_socket->setRecvBuffer(m_recvBuffer);
	m_socket->setSendBuffer(m_sendBuffer);
	//setMsgProcFunc(VxNetClient::_netClientProcFunc, this);
	//VxMutexManager::create(&m_sSendingListMutex);
	registerEventCb(VxNetClient::_netClientAsyncEventCb, this);
}

VxNetClient::~VxNetClient()
{
	//VxMutexManager::destroy(&m_sSendingListMutex);


/*	for(std::list<VxMsg*>::iterator i = m_msgList.begin(); m_msgList.end() != i; ++i)
	{
		if (*i)
		{
			(*i)->release();
		}
}
	m_msgList.clear();*/

#if !defined(__VX_NET_CLIENT_USE_MEMORY_BUFFER__)
	VxPath::destroyRandomPath(m_recvBuffer->getIOFilePath());
	VxPath::destroyRandomPath(m_sendBuffer->getIOFilePath());
#endif
	
	VX_SAFE_RELEASE_NULL(m_recvBuffer);
	VX_SAFE_RELEASE_NULL(m_sendBuffer);

	VX_SAFE_DELETE(m_socket);
}

void VxNetClient::connect()
{
	if(0 == m_nConnectCount)
	{
		VXLOG("VxNetClient::connect, start begin");
		//this->start();
		VXLOG("VxNetClient::connect, start end");
	}
	m_recvBuffer->reset();
	m_sendBuffer->reset();
	++m_nConnectCount;
	m_totalSend = 0;
	m_totalSent = 0;
	m_totalRecv = 0;
	VXLOG("VxNetClient::connect, connect begin");
	m_socket->connect();
	VXLOG("VxNetClient::connect, connect end");

}

void VxNetClient::disconnect()
{

}

void VxNetClient::close()
{
	VXLOG("VxNetClient::close, begin");
	m_socket->close();
	VXLOG("VxNetClient::close, m_socket->close end");

	{
		//VxLocalMutex sLocalMutex(&(m_sSendingListMutex));
		std::lock_guard<std::mutex> lk(m_sSendingListMutex);
		VXLOG("VxNetClient::close, runMsgEventCb VXSOCKET_EVENT_CLOSED");
		runMsgEventCb(VXSOCKET_EVENT_CLOSED, NULL);
		m_sendingList.clear();
	}
	VXLOG("VxNetClient::close, end");
}

void VxNetClient::send(VxMsgNetSendStream* sendObject)
{
	//VXASSERT(this, "VxNetClient::send, error, disconnect with server.");
	if(m_socket->state() == VXSOCKET_STATE_RUNNING)
	{
		this->pushMsg(sendObject);
	}
	VX_SAFE_RELEASE_NULL(sendObject);
}

int VxNetClient::pushMsg(VxMsgNetSendStream* sendObject,bool isFront,bool bWithTypeCheck)
{
	VxMsg* msg = sendObject;

	if (!msg)
	{
		return 0;
	}

	m_socket->send(sendObject->m_stream, sendObject->m_stream->size());
	
	return 1;
}

void VxNetClient::popMsg() {
	
	/*if (!m_msgList.empty())
	{
		VxMsg* pMsg = m_msgList.front();
		pMsg->release();
		m_msgList.pop_front();
	}*/
}


void VxNetClient::registerEventCb(VxNetEventCb func, void* arg)
{
	m_eventCb.add((void*)func, arg);
}

void VxNetClient::unregisterEventCb(VxNetEventCb func, void* arg)
{
	auto s = VxPriorityFuncion((void*)func, arg);
	m_eventCb.removeFunc(&s);
	//m_eventCb.remove((void*)func, arg);
}

/*
void VxNetClient::_netClientProcFunc(void* arg, VxMsg* msg)
{
	VxNetClient* client = (VxNetClient*)arg;
	//client->netClientProcFunc(msg);
}

void VxNetClient::netClientProcFunc(VxMsg* msg)
{
	switch(msg->msgType())
	{
	case VxMsg::NET_SEND_STREAM:
		{
			VxMsgNetSendStream* _msg = (VxMsgNetSendStream*)msg;
			if(m_socket->state() == VXSOCKET_STATE_RUNNING)
			{
				//int size = 0;
				int size = _msg->copyTo(m_socket->getSendBuffer());
				{
//					VxLocalMutex sLocalMutex(&m_sSendingListMutex);
					m_sendingList.push_back(VxNetSendStreamData(_msg->m_func, _msg->m_arg, m_totalSend, size));
				}
				m_totalSend += size;
				m_socket->flush();
			}
			else
			{
				_msg->runEventCb(VXSOCKET_EVENT_CLOSED, NULL);
			}
		}
		break;
	default:
		break;
	}
}
*/
void VxNetClient::_netClientAsyncEventCb(void* arg, int eventId, void* eventArg)
{
	VxNetClient* client = (VxNetClient*)arg;
	switch(eventId)
	{
	case VXSOCKET_EVENT_CONNECT_FAILED:
	case VXSOCKET_EVENT_CLOSED:
		{
			client->close();
		}
		break;
	}
}

void VxNetClient::_netClientEventCb(void* arg, int eventId, void* eventArg)
{
	VxNetClient* client = (VxNetClient*)arg;
	bool bAsync = true;
	switch(eventId)
	{
	case VXSOCKET_EVENT_CONNECT_BEGIN:
		break;
	case VXSOCKET_EVENT_CONNECT_COMPLETE:
		break;
	case VXSOCKET_EVENT_CONNECT_FAILED:
	case VXSOCKET_EVENT_CLOSED:
		{
			//VxLocalMutex sLocalMutex(&(client->m_sSendingListMutex));
			client->runMsgEventCb(VXSOCKET_EVENT_CLOSED, NULL);
			client->m_sendingList.clear();
		}
		break;
	case VXSOCKET_EVENT_RECV:
	{
		VxString *pRecvData = (VxString *)eventArg;
		char* pBuffer = pRecvData->m_pString;
		int nBufferSize = pRecvData->m_nLength;

		VxCacheIOStream* pStream = (VxCacheIOStream*)client->m_socket->getRecvBuffer();
		pStream->flush();


		
		static int sTotalCount = 0;
		++sTotalCount;
		//printf("sTotalCount = %d\n", sTotalCount);

		{
	//		MsgHeader sMsgHeader;
			unsigned short int temp;
			unsigned int nPackageSize = 0;

#if 0
			 pStream->read((char*)&temp, sizeof(unsigned short int));
			 sMsgHeader.m_nMsgType = sMsgHeader.NF_NTOHS(temp);

			 pStream->read((char*)&nPackageSize, sizeof(unsigned  int));
			 sMsgHeader.m_nMsgSize = sMsgHeader.NF_NTOHL(nPackageSize) - MsgHeader::NF_HEAD_LENGTH;
#endif

			VxMemIOStream* pReadStream = pStream->getReadBuffer();

			if (nBufferSize > pReadStream->capacity())
			{
				VxLocalString sLocalBuffer(nBufferSize);
				pStream->read(sLocalBuffer.getString(), nBufferSize);

				XGCCallLuaManager::getInstance()->recvMsg(client->m_nNetSocketId, nBufferSize ,sLocalBuffer.getString());
			}
			else
			{
				if (nBufferSize > pReadStream->readBlockBufferSize())
				{
					pStream->fillReadBuffer();
				}
				VxString sStringBuffer = pReadStream->readBlockBuffer(nBufferSize);
				XGCCallLuaManager::getInstance()->recvMsg(client->m_nNetSocketId, nBufferSize, sStringBuffer.m_pString);
			}

			
		}




	}




		bAsync = false;
		break;
	case VXSOCKET_EVENT_SEND:
		{
			unsigned long sentSize = (unsigned long)eventArg;
			if(0 < sentSize)
			{
				client->popMsg();
			}
			client->m_totalSent += sentSize;

			
		}
		bAsync = false;
		break;
	default:
		break;
	}

	XGCCallLuaManager::getInstance()->socketEvent(client->m_nNetSocketId,eventId, eventArg);
	client->m_eventCb.run(eventId, eventArg);
	if(bAsync)
	{
		//client->m_eventCb.dispatch(VXMODULE_ID_DATA, (void*)eventId, eventArg);
	}
	else
	{
		//client->m_eventCb.run((void*)eventId, eventArg);
	}
}

void VxNetClient::runMsgEventCb(int eventId, void* eventArg)
{
	for(std::list<VxNetSendStreamData>::iterator i = m_sendingList.begin(); m_sendingList.end() != i; ++i)
	{
		i->runEventCb(eventId, eventArg);
	}
}

void VxNetClient::reconnect()
{
	++m_nConnectCount;
	m_totalSend = 0;
	m_totalSent = 0;
	m_totalRecv = 0;
	m_socket->close();
	m_recvBuffer->reset();
	m_sendBuffer->reset();
	m_socket->connect();
}
