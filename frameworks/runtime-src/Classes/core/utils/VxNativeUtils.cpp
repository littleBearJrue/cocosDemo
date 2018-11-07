#include "VxNativeUtils.h" 
#include "XGCCallLuaManager.h"

#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <unistd.h>
#elif CC_PLATFORM_IOS == CC_TARGET_PLATFORM
#include "IosLuaCallManager.h"
#endif

std::string  VxNativeUtils::callAndroidString(const char* pClass, const char* pMethod, const char* pType)
{
	std::string sRet = "";
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
	JniMethodInfo methodInfo;
	if (JniHelper::getStaticMethodInfo(methodInfo, pClass, pMethod, pType))
	{
		jstring result = (jstring)methodInfo.env->CallStaticObjectMethod(methodInfo.classID, methodInfo.methodID);
		sRet = methodInfo.env->GetStringUTFChars(result, 0);
		methodInfo.env->DeleteLocalRef(result);
		methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}
	CCLOG("callAndroidString %s", sRet.c_str());
#else
#endif
	return sRet;
}


int  VxNativeUtils::callAndroidInteger(const char* pClass, const char* pMethod, const char* pType)
{
	int nRet = 1;
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
	JniMethodInfo methodInfo;
	if (JniHelper::getStaticMethodInfo(methodInfo, pClass, pMethod, pType))
	{
		nRet = (int)methodInfo.env->CallStaticObjectMethod(methodInfo.classID, methodInfo.methodID);
		methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}
	CCLOG("callAndroidInterger %d", nRet);
#endif
	return nRet;
}

void VxNativeUtils::callSystemEvent(int nKey, const char* sJsonData)
{
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM

	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo, "com/boyaa/entity/luaManager/LuaCallManager", "callEvent", "(ILjava/lang/String;)V"))
	{
		
		jstring stringArg2 = minfo.env->NewStringUTF(sJsonData);
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, nKey, stringArg2);
		minfo.env->DeleteLocalRef(stringArg2);
		minfo.env->DeleteLocalRef(minfo.classID);
	}
#elif CC_PLATFORM_IOS == CC_TARGET_PLATFORM
    
    IosLuaCallManager::getInstance()->callEvent(nKey, sJsonData);

#endif
}

void VxNativeUtils::systemCallLuaEvent(int nKey, const char* sJsonData)
{
	XGCCallLuaManager::getInstance()->systemCallLuaEvent(nKey, sJsonData);
}



#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
extern "C"
{
	void  Java_com_boyaa_entity_luaManager_LuaCallManager_systemCallLuaEvent(JNIEnv*  env, jobject thiz, jint nKey, jstring sJsonData)
	{
		/*Get the native string from javaString*/
		const char *nativeString = (env)->GetStringUTFChars(sJsonData, 0);


		VxNativeUtils::systemCallLuaEvent(nKey, nativeString);
		

		/*DON'T FORGET THIS LINE!!!*/
		(env)->ReleaseStringUTFChars(sJsonData, nativeString);

	}



}
#endif
