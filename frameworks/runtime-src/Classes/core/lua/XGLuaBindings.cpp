#include "XGLuaBindings.h"
#include "cocos2d.h"
#include "VxNetManager.h"
#include "VxResourceManager.h"
#include "base/ccUtils.h"
#include "VxConvert.h"
#include "VxNativeUtils.h"

#include "dragonbones/cocos2dx/CCFactory.h"
#include "spine/spine-cocos2dx.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"

#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define luaL_newlib(L ,reg) luaL_register(L,"projectx",reg)

	//c call lua functions
	void ccl_socketEvent(lua_State *L, int nNetSocketId,int eventId, const char * pStr)
	{		
		CCLOG("ccl_socketEvent");
		lua_getglobal(L, "NativeCall");

		if (lua_istable(L, -1))
		{
		}
		lua_getfield(L, -1, "ccl_socketEvent");


		
		lua_pushinteger(L, nNetSocketId);

		lua_pushinteger(L, eventId);

		lua_pushstring(L, pStr);

		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -5);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -5;
        }

		int ret = lua_pcall(L, 3, 1, traceCallback);

		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}
	}



	void ccl_recvMsgFromServer(lua_State *L, int nNetSocketId,  int msgSize,const char * pStr)
	{
		CCLOG("lcc_recvMsgFromServer");
		lua_getglobal(L, "NativeCall");

		if (lua_istable(L, -1))
		{
		}
		lua_getfield(L, -1, "ccl_recvMsgFromServer");



		lua_pushinteger(L, nNetSocketId);

		
		lua_pushinteger(L, msgSize);

		lua_pushlstring(L, pStr, msgSize);
		//lua_pushlightuserdata(L, (void*)pStr);

		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -5);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -5;
        }
		int ret = lua_pcall(L, 3, 1, traceCallback);

		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}
	}



	void c_call_lua_pbc_data(lua_State *L, const char     * pStr)
	{
		CCLOG("c_call_lua_pbc_data");
		lua_getglobal(L, "cc");

		if (lua_istable(L, -1) )
		{

		}

		lua_getfield(L, -1, "exports");
		lua_getfield(L, -1, "c_call_lua_pbc_data");

		//lua_pushstring(L, "exports");
		//ȡ��-2λ�õ�table��Ȼ���ջ��Ԫ�ص�����ȡ��table[name]��ֵ��ѹ��ջ
		//lua_gettable(L, -2);

		//lua_pushstring(L, "c_call_lua_pbc_data");
		//ȡ��-2λ�õ�table��Ȼ���ջ��Ԫ�ص�����ȡ��table[name]��ֵ��ѹ��ջ
		//lua_gettable(L, -2);


		//�Ѳ��� 2 �� C �ŵ���ջ
		lua_pushstring(L, pStr);

		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -3);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -3;
        }
		int ret = lua_pcall(L, 1, 1, traceCallback);

		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}
	}




	void ccl_downloaderOnTaskProgress(lua_State *L, const std::string &identifier, int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpected)
	{
		lua_getglobal(L, "NativeCall");
		lua_getfield(L, -1, "ccl_downloaderOnTaskProgress");

		lua_pushstring(L, identifier.c_str());

		lua_pushinteger(L, bytesReceived);
		lua_pushinteger(L, totalBytesReceived);
		lua_pushinteger(L, totalBytesExpected);
		
		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -6);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -6;
        }

		int ret = lua_pcall(L, 4, 1, traceCallback);

		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}
	}

	void ccl_downloaderOnDataTaskSuccess(lua_State *L, const std::string &identifier, unsigned char* pData, int nSize)
	{
		CCLOG("ccl_downloaderOnDataTaskSuccess");
		lua_getglobal(L, "NativeCall");
		lua_getfield(L, -1, "ccl_downloaderOnDataTaskSuccess");

		lua_pushstring(L, identifier.c_str());

		lua_pushlightuserdata(L, (void*)pData);
		lua_pushinteger(L, nSize);
		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -5);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -5;
        }

		int ret = lua_pcall(L, 3, 1, traceCallback);
		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}
	}

	void ccl_downloaderOnFileTaskSuccess(lua_State *L, const std::string &identifier)
	{
		
		CCLOG("ccl_downloaderOnFileTaskSuccess");
		lua_getglobal(L, "NativeCall");
		lua_getfield(L, -1, "ccl_downloaderOnFileTaskSuccess");

		lua_pushstring(L, identifier.c_str());

		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -3);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -3;
        }

		int ret = lua_pcall(L, 1, 1, traceCallback);
		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}

	}

	void ccl_downloaderOnTaskError(lua_State *L, const std::string &identifier, int errorCode, int errorCodeInternal, const std::string& errorStr)
	{
		
		CCLOG("ccl_downloaderOnTaskError");
		lua_getglobal(L, "NativeCall");
		lua_getfield(L, -1, "ccl_downloaderOnTaskError");

		lua_pushstring(L, identifier.c_str());
		lua_pushinteger(L, errorCode);
		lua_pushinteger(L, errorCodeInternal);
		lua_pushstring(L, errorStr.c_str());
		int traceCallback = 0;
        lua_getglobal(L, "__G__TRACKBACK__");                       
        if (!lua_isfunction(L, -1))
        {
            lua_pop(L, 1);                                          
        }else{
            lua_insert(L, -6);                         /* L: ... G func arg1 arg2 ... */
        	traceCallback = -6;
        }
		int ret = lua_pcall(L, 4, 1, traceCallback);
		if (ret) {
			if (traceCallback == 0)
            {
                CCLOG("[LUA ERROR] %s", lua_tostring(L, - 1));        /* L: ... error */
                lua_pop(L, 1); // remove error message from stack
            }
            else                                                            /* L: ... G error */
            {
                lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
            }
            lua_settop(L,2);
		}
	}



	void ccl_systemCallLuaEvent(lua_State* L, int nKey, const char* sJsonData)
	{


		CCLOG("ccl_systemCallLuaEvent");
		lua_getglobal(L, "NativeCall");

		if (lua_istable(L, -1))
		{
		}
		lua_getfield(L, -1, "ccl_systemCallLuaEvent");



		lua_pushinteger(L, nKey);

		lua_pushstring(L, sJsonData);


		int traceCallback = 0;
		lua_getglobal(L, "__G__TRACKBACK__");
		if (!lua_isfunction(L, -1))
		{
			lua_pop(L, 1);
		}
		else {
			lua_insert(L, -4);                         /* L: ... G func arg1 arg2 ... */
			traceCallback = -4;
		}
		int ret = lua_pcall(L, 2, 1, traceCallback);

		if (ret) {
			if (traceCallback == 0)
			{
				CCLOG("[LUA ERROR] %s", lua_tostring(L, -1));        /* L: ... error */
				lua_pop(L, 1); // remove error message from stack
			}
			else                                                            /* L: ... G error */
			{
				lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
			}
			lua_settop(L, 2);
		}
	}

	
	int lcc_sendMsgToServer(lua_State *L)
	{
		int nNetSocketId = -1;
		int nMsgType = 0;
		const char* pMsgData = "";
		int nMsgSize = 0;

		bool bRet = false;

		do
		{
			if (lua_isnumber(L, 1))
			{
				nNetSocketId = lua_tointeger(L, 1);
			}

			//if (lua_isnumber(L, 2))
			//{
				//nMsgType = lua_tointeger(L, 2);
		//	}

			if (lua_isstring(L, 2))
			{
				pMsgData = lua_tostring(L, 2);
			}

			if (lua_isnumber(L, 3))
			{
				nMsgSize = lua_tointeger(L, 3);
			}

			bRet = true;
		} while (0);

		if (bRet)
		{
			VxNetManager::getInstance()->sendMsgToServer(nNetSocketId, pMsgData, nMsgSize);

			printf("lcc_connectToServer %d,%d \n", nNetSocketId);
		}

		return 1;
	}


	int lcc_connectToServer(lua_State *L)
	{
		//const char     * pStrName = "";
		int nNetSocketId = 0;
		const char     * pStrIp = "";
		short port = 0;
		bool bRet = false;
		do
		{
			if (lua_isnumber(L, 1))
			{
				nNetSocketId = lua_tointeger(L, 1);
			}
			else{break;}

			if (lua_isstring(L, 2))
			{
				pStrIp = lua_tostring(L, 2);
			}
			else{break;}

			if (lua_isnumber(L, 3))
			{
				port = lua_tointeger(L, 3);
			}
			else{break;}
			bRet = true;
		} while (0);

		if (bRet)
		{
			VxNetManager::getInstance()->connectToServer(nNetSocketId, pStrIp, port);
			printf("lcc_connectToServer %d,%s,%d \n", nNetSocketId, pStrIp, port);
		}

		return 1;
	}

	int lcc_disconnectToServer(lua_State *L)
	{
		//const char     * pStrName = "";
		int nNetSocketId = 0;

		bool bRet = false;
		do
		{
			if (lua_isnumber(L, 1))
			{
				nNetSocketId = lua_tointeger(L, 1);
			}
			else { break; }

			
			bRet = true;
		} while (0);

		if (bRet)
		{
			VxNetManager::getInstance()->disconnectToServer(nNetSocketId);
			printf("lcc_disconnectToServer %d \n", nNetSocketId);
		}

		return 1;
	}
	
	int lcc_download(lua_State *L)
	{
		std::string pUrl = "";
		std::string pIdentifier = "";
		int bIsUpdateZipFile = 0;
		bool bRet = false;

		do
		{

			if (lua_isstring(L, 1))
			{
				pUrl = lua_tostring(L, 1);
			}

			if (lua_isstring(L, 2))
			{
				pIdentifier = lua_tostring(L, 2);
			}

			if (lua_isnumber(L, 3))
			{
				bIsUpdateZipFile = lua_tointeger(L, 3);
			}

			bRet = true;
		} while (0);
		if (bRet)
		{
			VxResourceManager::getInstance()->download(pUrl, pIdentifier, bIsUpdateZipFile);
			printf("lcc_download %s\n", pUrl.c_str());
		}
		return 1;
	}

	int lcc_getMD5Hash(lua_State *L)
	{
		std::string pData = "";
		bool bRet = false;

		do
		{
			if (lua_isstring(L, 1))
			{
				pData = lua_tostring(L, 1);
			}

			bRet = true;
		} while (0);
		if (bRet)
		{
			Data sData;
			sData.copy((const unsigned char*)pData.c_str(), pData.length());
			std::string sHash = utils::getDataMD5Hash(sData);
			//char temp[32] = { 0 };

			lua_pushstring(L, sHash.c_str());
			printf("lcc_getMD5Hash %s %s\n", pData.c_str(), sHash.c_str());
		}
		return 1;
	}




	int lcc_setGLProgramState(lua_State *L)
	{
		void* pNode = nullptr;

		int nShaderID  = 0;
		
		bool bRet = false;

		do{

			if (lua_isuserdata(L, 1)){
				pNode = lua_touserdata(L, 1);
			}
			else { break; }

			
			if (lua_isnumber(L, 2)){
				nShaderID = lua_tointeger(L, 2);
			}
			else { break; }

			bRet = true;
		} while (0);
		if (bRet){
			
			//((Node*)pNode)->setGLProgramState(XGShaderCache::getInstance()->getGLProgramState(nShaderID));
			printf("lcc_setGLProgramState %d\n", nShaderID);
		}

		return 1;
	}


	
	static int toInteger64String(lua_State* L)
	{
		int argc = lua_gettop(L);

		if (argc == 1)
		{
			int64_t tmpdata = 0;
			int type = lua_type(L, 1);
			if (type == LUA_TSTRING) {
				size_t len = 0;
				const char * number = lua_tolstring(L, 1, &len);
				if (len != 8) {
					return luaL_error(L, "Need an 8 length string for int64");
				}
				tmpdata = *(int64_t*)number;
			}
			else if(LUA_TNUMBER == type) {
				tmpdata = (int64_t)lua_tonumber(L, 1);
			}
			else
			{
				return luaL_error(L, "Need an 8 length string or number for int64");
			}

			std::string sTemp = VxConvert::integer64ToString(tmpdata);
			//return new_Integer64(L, tmpdata);
			lua_pushstring(L, sTemp.c_str());
		}
		return 1;
	}



	static int lcc_replacementParts(lua_State* L )
	{
		std::string pSlot = "";
		std::string pAttachName = "";
		int bIsUpdateZipFile = 0;
		bool bRet = false;
		spine::SkeletonAnimation* pAni = nullptr;

		do
		{
			pAni =(spine::SkeletonAnimation*) lua_touserdata(L, 1);

			if (lua_isstring(L, 2))
			{
				pSlot = lua_tostring(L, 2);
			}

			if (lua_isstring(L, 3))
			{
				pAttachName = lua_tostring(L, 3);
			}

			pAni->setAttachment(pSlot, pAttachName);

			bRet = true;
		} while (0);
		
		return 1;

		//pAni->setAttachment()

		/*
		if (skinName.empty())
		{
			return false;
		}

		spSkin *skin = spSkeletonData_findSkin(_skeleton->data, skinName.c_str());
		if (!skin) return false;

		if (_skeleton->skin)
		{
			const _Entry *entry = reinterpret_cast<_spSkin *>(_skeleton->skin)->entries;
			while (entry)
			{
				spSlot *slot = _skeleton->slots[entry->slotIndex];
				if (strcmp(slot->data->name, attachmentName.c_str()) == 0)
				{
					spAttachment *attachment = spSkin_getAttachment(skin, entry->slotIndex, entry->name);
					if (attachment) spSlot_setAttachment(slot, attachment);
					return true;
				}
				entry = entry->next;
			}
		}
		else
		{
			for (int i = 0; i < _skeleton->slotsCount; ++i)
			{
				spSlot* slot = _skeleton->slots[i];

				if (strcmp(slot->data->name, slotName.c_str()) == 0)
				{
					spAttachment* attachment = spSkin_getAttachment(skin, i, attachmentName.c_str());
					if (attachment) spSlot_setAttachment(slot, attachment);
					return true;
				}
			}
		}
		*/
		return false;
	}

#include "XGFrameAnimation.h"
	static int lcc_playFrameAni(lua_State* L)
	{

		cocos2d::Node *pParent;

		int argc = lua_gettop(L);
		bool bLoop = false;

		if (lua_isuserdata(L, 1)) {

			pParent = (Node*)tolua_tousertype(L, 1, 0);
		}

		float x = lua_tonumber(L, 2);
		float y = lua_tonumber(L, 3);
		int  nId = lua_tointeger(L, 4);
		

		if (argc == 5)
		{
			 bLoop = lua_toboolean(L, 5);
		}

		
		cocos2d::Node* arg0;// pParent = dynamic_cast<cocos2d::Node*>(t);
		//luaval_to_object<cocos2d::Node>(L, 2, "cc.Node", &arg0, "XGPolygonCollider:create");


		

		
		const Point pos(x, y);
		auto sprite = XGFrameAnimation::playFrameAnimation(pParent, pos, nId, bLoop);

		int ID = (int)sprite->_ID;
		int* luaID = &sprite->_luaID;
		toluafix_pushusertype_ccobject(L, ID, luaID, (void*)sprite, "cc.Sprite");
		return 1;
	}
	


	
	static int lcc_callSystemEvent(lua_State* L)
	{


		int argc = lua_gettop(L);

		int nKey = lua_tointeger(L, 1);
		const char* pMsgData  = lua_tostring(L, 2);

		VxNativeUtils::callSystemEvent(nKey, pMsgData);

		return 1;
	}


	

	static int lcc_test(lua_State* L)
	{
		
		return 1;
	}

	


	int luaopen_projectx_c(lua_State *L)
	{
		luaL_Reg reg[] = {
		{ "lcc_sendMsgToServer" , lcc_sendMsgToServer },

		{ "lcc_connectToServer" , lcc_connectToServer },
		{ "lcc_disconnectToServer" , lcc_disconnectToServer },
		
		{ "lcc_download" , lcc_download },
		{ "lcc_getMD5Hash" , lcc_getMD5Hash },
		{ "lcc_setGLProgramState" , lcc_setGLProgramState },
		{ "lcc_toInteger64String" , toInteger64String },
		{ "lcc_test" , lcc_test },
		{ "lcc_replacementParts" , lcc_replacementParts },
		{ "lcc_playFrameAni" , lcc_playFrameAni },
		{ "lcc_callSystemEvent" , lcc_callSystemEvent },
		
		
		{ NULL,NULL },
		};

		//luaL_checkversion(L);
		luaL_newlib(L, reg);

		return 1;
	}



#ifdef __cplusplus
}
#endif


