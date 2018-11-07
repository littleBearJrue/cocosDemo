#include "XGCCallLuaManager.h"
#include <mutex>
#include <thread>
#include "VxConst.h"
//#include "MsgProtocol.pb.h"

USING_NS_CC;

#if __cplusplus    
extern "C" {
#endif    
	void ccl_socketEvent(lua_State *L, int nNetSocketId, int eventId, const char * pStr);
	void ccl_recvMsgFromServer(lua_State *L, int nNetSocketId, int msgSize,const char * pStr);

	void ccl_downloaderOnTaskProgress(lua_State *L, const std::string &identifier, int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpected);
	void ccl_downloaderOnDataTaskSuccess(lua_State *L, const std::string &identifier, unsigned char* pData, int nSize);
	void ccl_downloaderOnFileTaskSuccess(lua_State *L, const std::string &identifier);
	void ccl_downloaderOnTaskError(lua_State *L, const std::string &identifier, int errorCode, int errorCodeInternal, const std::string& errorStr);

	void ccl_systemCallLuaEvent(lua_State* L, int nKey, const char* sJsonData);

#if __cplusplus    

}

#endif  


class SocketEventData
{
public :
	SocketEventData(int nNetSocketId, int eventId, char *argv, int msgType = -1)
		: m_nNetSocketId(nNetSocketId)
		, m_eventId(eventId)
		, m_argv(argv)
		, m_msgType(msgType)
	{

	}
	int m_nNetSocketId;
	int m_eventId;
	int m_msgType;
	char* m_argv;
};

class RecvMsgData
{
public:
	RecvMsgData(int nNetSocketId, int msgSize,char *argv)
		: m_nNetSocketId(nNetSocketId)
		, m_argv(argv)
		//, m_msgType(msgType)
		, m_msgSize(msgSize)
	{

	}
	int m_nNetSocketId;
	//int m_msgType;
	int m_msgSize;
	char* m_argv;

};


static std::mutex s_mutex;
//static std::mutex s_mutexRecv;

static std::list<SocketEventData> s_socketDataList;
static std::list<RecvMsgData> s_recvMsgDataList;


XGCCallLuaManager::XGCCallLuaManager()
	:m_pLuaState(nullptr)
{
	Director::getInstance()->getScheduler()->schedule(schedule_selector(XGCCallLuaManager::loop),this,0,false);
	//schedule_selector(XGCCallLuaManager::loop), this, 0, false
}

XGCCallLuaManager::~XGCCallLuaManager()
{
}

void XGCCallLuaManager::loop(float dt)
{
	std::lock_guard<std::mutex> lk(s_mutex);
	if (!s_socketDataList.empty())
	{
		for (auto it = s_socketDataList.begin(); it != s_socketDataList.end(); it++)
		{
			ccl_socketEvent(m_pLuaState, it->m_nNetSocketId, it->m_eventId, it->m_argv);
		}
		s_socketDataList.clear();
	}


	if (!s_recvMsgDataList.empty())
	{
		for (auto it = s_recvMsgDataList.begin(); it != s_recvMsgDataList.end(); it++)
		{
			ccl_recvMsgFromServer(m_pLuaState, it->m_nNetSocketId, it->m_msgSize,it->m_argv);

			delete[] it->m_argv;
		}
		s_recvMsgDataList.clear();
	}
	
}

void XGCCallLuaManager::setLuaState(lua_State *L)
{
	m_pLuaState = L;
}

void XGCCallLuaManager::socketEvent(int nNetSocketId, int eventId, void* argv)
{
	std::lock_guard<std::mutex> lk(s_mutex);

	if (eventId == VXSOCKET_EVENT_RECV)
	{
		//s_socketDataList.push_back(SocketEventData(nNetSocketId, eventId, (char*)argv));
	}
	else if (eventId == VXSOCKET_EVENT_SEND)
	{

	}
	else
	{
		s_socketDataList.push_back(SocketEventData(nNetSocketId, eventId, (char*)argv));
	}
	//ccl_socketEvent(m_pLuaState, nNetSocketId, eventId, (char*)argv);
}

void XGCCallLuaManager::recvMsg(int nNetSocketId, int msgSize,char* argv)
{
	std::lock_guard<std::mutex> lk(s_mutex);

	char* pData = new char[msgSize];
	memcpy(pData, argv, msgSize);
	s_recvMsgDataList.push_back(RecvMsgData(nNetSocketId, msgSize,(char*)pData));



	//ccl_recvMsgFromServer(m_pLuaState, nNetSocketId, msgType, msgSize, (const char*)argv);
}



void XGCCallLuaManager::downloaderOnTaskProgress(const std::string &identifier, int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpected)
{
	ccl_downloaderOnTaskProgress(m_pLuaState,identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected);
}

void XGCCallLuaManager::downloaderOnDataTaskSuccess(const std::string &identifier,  unsigned char* pData, int nSize)
{
	ccl_downloaderOnDataTaskSuccess(m_pLuaState, identifier, pData, nSize);
}

void XGCCallLuaManager::downloaderOnFileTaskSuccess(const std::string &identifier)
{
	ccl_downloaderOnFileTaskSuccess(m_pLuaState, identifier);
}

void XGCCallLuaManager::downloaderOnTaskError(const std::string &identifier, int errorCode, int errorCodeInternal, const std::string& errorStr)
{
	ccl_downloaderOnTaskError(m_pLuaState, identifier, errorCode, errorCodeInternal, errorStr);
}


void XGCCallLuaManager::systemCallLuaEvent(int nKey,const char*sJsonData)
{
	if (!m_pLuaState)
	{
		CCLOG("Lua engine not start!");
		return;
	}
	ccl_systemCallLuaEvent(m_pLuaState, nKey,sJsonData);
}
