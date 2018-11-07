
#include "IosLuaCallManager.h"
#include "IosLuaCallManager.h"
#include "VxNativeUtils.h"

#import "AppController.h"
#import <GameKit/GameKit.h>
#import <Social/Social.h>
#include <sys/types.h>
#include <sys/sysctl.h>

static IosLuaCallManager* s_pInstance = nullptr;

IosLuaCallManager* IosLuaCallManager::getInstance()
{
    if (!s_pInstance){
        s_pInstance = new IosLuaCallManager();
    }
    return s_pInstance;
}


IosLuaCallManager::IosLuaCallManager()
{
    
}

IosLuaCallManager::~IosLuaCallManager(){}

void IosLuaCallManager::init()
{
    
}

void IosLuaCallManager::callEvent(int nKey,const char* pData)
{
    systemCallLua(nKey,pData);
}

void IosLuaCallManager::systemCallLua(int nKey,const char* pData)
{
    VxNativeUtils::systemCallLuaEvent(nKey, pData);
}
