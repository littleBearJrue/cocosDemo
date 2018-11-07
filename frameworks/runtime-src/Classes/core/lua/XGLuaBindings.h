#ifndef __XG_LUA_BINDINGS_H__
#define __XG_LUA_BINDINGS_H__
#if defined(_USRDLL)    

#define LUA_EXTENSIONS_DLL     __declspec(dllexport)    

#else         /* use a DLL library */    

#define LUA_EXTENSIONS_DLL    

#endif    



#if __cplusplus    

extern "C" {

#endif    
#include "lauxlib.h"  



	int LUA_EXTENSIONS_DLL luaopen_projectx_c(lua_State *L);

	//void ccl_socket_callback_event(int eventId, void*data);

#if __cplusplus    

}

#endif




#endif  // __XG_PROJECTX_LUA_H__

