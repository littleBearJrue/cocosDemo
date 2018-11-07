
#ifndef __VX_NET_CLIENT_H__
#define __VX_NET_CLIENT_H__

#include "VxSocketClient.h"
#include "XGDelegate.h"

class VxNetSendStreamData;
class VxMsgNetSendStream;
class VxCacheIOStream;
class VxMsg;
class VxNetAddress
{
public:
	VxNetAddress();
	VxNetAddress(const std::string& sServerName, const std::string& sAddress, int nPort);
public:
	std::string m_sServerName;
	std::string m_sAddress;
	int m_nPort;
};

class VxNetClient //: public VxMsgModule
{
public:
	VxNetClient(int nNetSocketId,const char* addr, unsigned port);
	~VxNetClient();
	void connect();
	void disconnect();
	void close();
	void send(VxMsgNetSendStream* sendObject);
	int pushMsg(VxMsgNetSendStream* sendObject, bool isFront = false, bool bWithTypeCheck = false);
	void popMsg();
	void registerEventCb(VxNetEventCb func, void* arg);
	void unregisterEventCb(VxNetEventCb func, void* arg);
private:
//	static void _netClientProcFunc(void* arg, VxMsg* msg);
//	void netClientProcFunc(VxMsg* msg);
	static void _netClientEventCb(void* arg, int eventId, void* eventArg);
	static void _netClientAsyncEventCb(void* arg, int eventId, void* eventArg);
	void runMsgEventCb(int eventId, void* eventArg);
	void reconnect();
public:
	int m_nConnectCount;
	VxSocketClient* m_socket;
	XGDelegate m_eventCb;
	int m_totalSend;
	int m_totalSent;
	int m_totalRecv;
	std::list<VxNetSendStreamData> m_sendingList;
	VxCacheIOStream* m_recvBuffer;
	VxCacheIOStream* m_sendBuffer;
	std::mutex m_sSendingListMutex;

	std::list<VxMsg*> m_msgList;
	int  m_nNetSocketId;
};


#endif	// __VX_NET_CLIENT_H__