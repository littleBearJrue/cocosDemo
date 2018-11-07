#ifndef __XG_IOS_LUA_CALL_MANAGER_H__
#define __XG_IOS_LUA_CALL_MANAGER_H__



class IosLuaCallManager
{
public:
    static IosLuaCallManager* getInstance();
    IosLuaCallManager();
    virtual ~IosLuaCallManager();
   virtual void init();
    virtual void callEvent(int nKey,const char* pData);
    void systemCallLua(int nKey,const char* pData);
};

#endif
