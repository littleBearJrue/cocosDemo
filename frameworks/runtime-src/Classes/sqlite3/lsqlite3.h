#ifndef lsqlite3_h
#define lsqlite3_h

#include "base/ccConfig.h"
#ifdef __cplusplus

extern "C" {
#endif
#include "tolua++.h"

    int luaopen_lsqlite3(lua_State* L);   //lsqlite3.c 中的C函数，这里注册C函数
    
#ifdef __cplusplus
}
#endif
#endif /* lsqlite3_h */