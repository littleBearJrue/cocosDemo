#ifndef __XG_CCALLLUAMANAGER_H__
#define __XG_CCALLLUAMANAGER_H__
#include "cocos2d.h"

#include "XGMacros.h"
//#include "cocos2d.h"

#if __cplusplus    

extern "C" {

#endif    
#include "lauxlib.h"  

#if __cplusplus    

 }

#endif  

class XGCCallLuaManager : public  cocos2d::Ref
{
public:
	XGCCallLuaManager();
	~XGCCallLuaManager();
	XG_SINGLET_WITH_INIT_DECLARE(XGCCallLuaManager);

	void setLuaState(lua_State *L);
	void loop(float dt);
public:
	void socketEvent(int nNetSocketId, int eventId, void* argv);
	void recvMsg(int nNetSocketId , int msgSize, char* argv);


	void downloaderOnTaskProgress(const std::string &identifier, int64_t bytesReceived,int64_t totalBytesReceived,int64_t totalBytesExpected);
	void downloaderOnDataTaskSuccess(const std::string &identifier, unsigned char*, int nSize);
	void downloaderOnFileTaskSuccess(const std::string &identifier);
	void downloaderOnTaskError(const std::string &identifier, int errorCode,int errorCodeInternal,const std::string& errorStr);

	void systemCallLuaEvent(int nKey, const char*sJsonData);

	lua_State *m_pLuaState;
};





#endif  // __XG_PROJECTX_LUA_H__

