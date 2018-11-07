/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"

#include "reader/lua-bindings/creator_reader_bindings.hpp"
#include "pbc/pbc-lua.h"
#include "XGLuaBindings.h"
#include "VxNetManager.h"
#include "XGCCallLuaManager.h"
#include "VxResourceManager.h"
#include "XGDBFrameAnimation.h"

#include "sqlite3/lsqlite3.h"


// #define USE_AUDIO_ENGINE 1
// #define USE_SIMPLE_AUDIO_ENGINE 1

#if USE_AUDIO_ENGINE && USE_SIMPLE_AUDIO_ENGINE
#error "Don't use AudioEngine and SimpleAudioEngine at the same time. Please just select one in your game!"
#endif

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#elif USE_SIMPLE_AUDIO_ENGINE
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;
#endif

USING_NS_CC;
using namespace std;

static bool firstRunLuaScript = true;
static string defaultResRootPath;
static vector<string> defaultResearchPaths;

static void resetWin32DefaulRootPath();
static bool startLua();
static int fix_restart_lua(lua_State * l);



AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
    AudioEngine::end();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8, 0 };

    GLView::setGLContextAttrs(glContextAttrs);
}



static int readProtobufFile(lua_State *L)

{

	const char *buff = luaL_checkstring(L, -1);

	Data data = CCFileUtils::getInstance()->getDataFromFile(buff);

	lua_pushlstring(L, (const char*)data.getBytes(), data.getSize());

	return 1; /* number of results */

}

static int register_xg(lua_State* tolua_S)
{
	tolua_open(tolua_S);

	tolua_module(tolua_S, "xg", 0);
	tolua_beginmodule(tolua_S, "xg");


	tolua_endmodule(tolua_S);
	return 1;
}


// if you want to use the package manager to install more packages, 
// don't modify or remove this function
static int register_all_packages()
{
	lua_State *L = LuaEngine::getInstance()->getLuaStack()->getLuaState();

	luaopen_protobuf_c(L);
	luaopen_projectx_c(L);
	lua_getglobal(L, "_G");
	if (lua_istable(L, -1))//stack:...,_G,
	{
		register_creator_reader_module(L);
		register_xg(L);

	}
	lua_pop(L, 1);

	lua_module_register(L);
	lua_register(L, "readProtobufFile", readProtobufFile);

	lua_register(L, "fix_restart_lua", fix_restart_lua);

	luaopen_lsqlite3(L);

	return 0; //flag for packages manager
}



bool AppDelegate::applicationDidFinishLaunching()
{
	return startLua();
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::pauseAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::resumeAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif
}


static void resetWin32DefaulRootPath() {
	if (firstRunLuaScript) {
		string defaultSearchPath = FileUtils::getInstance()->getDefaultResourceRootPath();
		const auto& pathVecs = FileUtils::getInstance()->getSearchPaths();
		if (defaultSearchPath.find("simulator/win32/") == string::npos) {
			for (const auto& content : pathVecs)
			{
				;
				if (content.find("simulator/win32/") != string::npos) {
					string newContent(content + "../../");
					FileUtils::getInstance()->setDefaultResourceRootPath(newContent);
					break;
				}
			}
		}
		string defaultSearchPath2 = FileUtils::getInstance()->getDefaultResourceRootPath();
		if (defaultSearchPath2.empty()) {
			for (const auto& content : pathVecs)
			{
				if (content.find("frameworks/runtime-src/proj.win32/") != string::npos) {
					string newContent(content + "../../../../");
					FileUtils::getInstance()->setDefaultResourceRootPath(newContent);
					break;
				}
			}
		}
		firstRunLuaScript = false;
		//static string defaultResPath;
		//static vector<string> defaultResearchPath;
		defaultResRootPath = string(FileUtils::getInstance()->getDefaultResourceRootPath());
		defaultResearchPaths.assign(pathVecs.begin(),pathVecs.end());
	}else {
		string newResRootPath(defaultResRootPath);
		vector<string> newResearchPaths(defaultResearchPaths);
		FileUtils::getInstance()->setSearchPaths(newResearchPaths);
		FileUtils::getInstance()->setDefaultResourceRootPath(newResRootPath);
	}

	printf("default res root path %s\n", FileUtils::getInstance()->getDefaultResourceRootPath().c_str());
	for (const auto& content : FileUtils::getInstance()->getSearchPaths())
	{
		printf("default search path %s\n", content.c_str());
	}
}


static bool startLua() {
	VxNetManager::getInstance();
	// set default FPS
	Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

	// register lua module
	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
	lua_State* L = engine->getLuaStack()->getLuaState();
	lua_module_register(L);

	XGCCallLuaManager::getInstance()->setLuaState(L);

	register_all_packages();

	LuaStack* stack = engine->getLuaStack();
	stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

	//register custom function
	//LuaStack* stack = engine->getLuaStack();
	//register_custom_function(stack->getLuaState());

#if CC_64BITS
	FileUtils::getInstance()->addSearchPath("src/64bit");
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	resetWin32DefaulRootPath();
#endif

	FileUtils::getInstance()->addSearchPath("src");
	FileUtils::getInstance()->addSearchPath("res");
	XGDBFrameAnimationManager::getInstance()->init();
	if (engine->executeScriptFile("main.lua"))
	{
		return false;
	}

	return true;
}


static int fix_restart_lua(lua_State * l) {
	std::string key = "restart";
	printf("111111111111111111111111111111111111111111111\n");

	
	//CCDirector::getInstance()->getScheduler()->schedule([](float delta) {//必须延迟执行，否则会报错
	//	printf("222222222222222222222222222222222222222\n");
	//	ScriptEngineManager::getInstance()->removeScriptEngine();//把原来的luaEngine销毁
	//	ScriptHandlerMgr::destroyInstance();//把原理注册的函数ID清空
	//	VxNetManager::release();
	//	XGCCallLuaManager::release();
	//	startLua();//重新创建luaEngine
	//	printf("333333333333333333333333333333\n");
	//}, CCDirector::getInstance()->getRunningScene(), 0.f, 0, 0.f, false, key);
	//这里只能使用动作，不能使用定时器，因为CCDirector::getInstance()->getRunningScene() 已经为nil了，不能注册定时器

	auto newScene = Scene::create();
	auto newNode = Node::create();
	newScene->addChild(newNode);
	CCDirector::getInstance()->runWithScene(newScene);
	newNode->runAction(Sequence::create(CallFunc::create([&]() {
		printf("222222222222222222222222222222222222222\n");
		ScriptEngineManager::getInstance()->removeScriptEngine();//把原来的luaEngine销毁
		ScriptHandlerMgr::destroyInstance();//把原理注册的函数ID清空
		VxNetManager::release();
		XGCCallLuaManager::release();
		startLua();//重新创建luaEngine
		printf("333333333333333333333333333333\n");
	}), nullptr));
	printf("444444444444444444444444444444444444444444444444444444\n");
	return 1;
}