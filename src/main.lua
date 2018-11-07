print("first")
cc.FileUtils:getInstance():setPopupNotify(false)

local breakSocketHandle, debugXpCall = require("LuaDebugjit")("localhost",7003)
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle ,0.3,false)


print("second")

require "config"
require "cocos.init"
require "PersonalMenu"
require "Helper"

print("third")

local function initRequires()
    local global = import("app.global.init")
    
    require "updateConfig"

    require "framework.init"
    global:initData();
end

local fileUtils = cc.FileUtils:getInstance()
local function addSearchPath(resPrefix)
    local director = cc.Director:getInstance()
    local glView   = director:getOpenGLView()
    local screenSize = glView:getFrameSize()
    local searchPaths = fileUtils:getSearchPaths()
    table.insert(searchPaths, 1, resPrefix)
    table.insert(searchPaths, 1, resPrefix .. "cocosbuilderRes")
    
    -- if screenSize.height > 320 then
    --     table.insert(searchPaths, 1, resPrefix .. "hd")
    --     table.insert(searchPaths, 1, resPrefix .. "ccs-res")
    --     table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd")
    -- end

    fileUtils:setSearchPaths(searchPaths)

end

addSearchPath("res/")
addSearchPath("src/app")
addSearchPath("src/app/demo")
addSearchPath("")

CC_DISABLE_GLOBAL = true
if CC_DISABLE_GLOBAL then
    cc.disable_global()
end

local function testScene()

    -- print("sdfsafsdfasdsdfasdfdfs")
    -- print(debug.traceback())

    local scene = cc.Scene:create()
    scene:addChild(CreatePersonalMenu())

    -- local SceneTest = import("app.hall").TestScene
    -- local scene = SceneTest:create()
    -- error(1)
    if fix_restart_lua then
        -- 为了支持重启，这里不能直接使用runWithScene
        display.runScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
end




local function main()
   -- require("app.MyApp"):create():run()
   initRequires()

--    NetManager.getInstance()
    -- error(1)
   if XG_USE_TEST_SCENE then
     testScene()
   else
     LogicSys:onEvent(LogicEvent.EVENT_SCENE_ENTER,Scene.XG_SCENE_WELCOME)
   end
end


local scheduler = {}
local schedulerCount = {}
local function createErrorView(content,closeFunc)
    local label = cc.Label:createWithTTF(tostring(content),  "fonts/arial.ttf", 20,cc.size(display.width * 0.92,0),cc.TEXT_ALIGNMENT_LEFT)
    if not label then
        return
    end
    label:setColor(cc.c3b(255,0,0))
    local labelSize = label:getContentSize()
    local scrollViewContainer = display.newNode()
    scrollViewContainer:setContentSize(labelSize)
    local scrollSize = display.size
    if scrollSize.width > labelSize.width then
        scrollSize.width = labelSize.width
    end
    if scrollSize.height > labelSize.height then
        scrollSize.height = labelSize.height
    end
    local scrollView = cc.ScrollView:create(scrollSize,scrollViewContainer)
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);--方向  横－竖
    scrollView:setIgnoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(display.CENTER)
    scrollView:setPosition(display.center)
    scrollView:setDelegate()
   
    label:align(display.CENTER,labelSize.width / 2,labelSize.height / 2):addTo(scrollView)
    scrollView:setContentOffset(cc.p(0,0),true)
    scrollView:setLocalZOrder(10000000)

    local uiText = ccui.Text:create("重启", "Arial", 20)
    uiText:addTo(scrollView):align(display.LEFT_BOTTOM,0,0)
    uiText:setTouchEnabled(true)
    uiText:addClickEventListener(function(widget) 
       
        cc.Director:getInstance():restart()
        local notificationNode = display.newNode()
        notificationNode:enableNodeEvents()
        notificationNode.onExit = function ( self )
            local restartNode
            restartNode = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (  )
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(restartNode)
                if fix_restart_lua then
                    fix_restart_lua()
                end
            end,0,false)

        end
        --restart调用，下一帧才会重置（会去掉所有定时器），监听场景的回调结点.参看源码，
        cc.Director:getInstance():setNotificationNode(notificationNode)
    end)

    if true then
        local uiText = ccui.Text:create("关闭", "Arial", 20)
        uiText:addTo(scrollView):align(display.RIGHT_BOTTOM,labelSize.width,0)
        uiText:setTouchEnabled(true)
        uiText:addClickEventListener(function(widget) 
            if closeFunc then
                closeFunc()
            end
        end)
    end
    scrollView:setOpacity(100)
    return scrollView
end

local function showErrormsg(msg)
    local msg = debug.traceback(msg)
    if scheduler[msg] then
        return 
    end
    schedulerCount[msg] = 1
    if not display.getRunningScene() then
        local errorScene = cc.Scene:create()
        display.runScene(errorScene)
    end
    local function closeFunc()
        schedulerCount[msg] = nil
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduler[msg])
        scheduler[msg] = nil
        display.getRunningScene():removeChildByName(msg)
    end
    local function click()
        if schedulerCount[msg] > 1000 then
            closeFunc()
            return
        end
        schedulerCount[msg] = schedulerCount[msg] + 1
        if display.getRunningScene():getChildByName(msg) then
            return
        end
        local ret = createErrorView(msg,closeFunc)
        if ret then
            ret:addTo(display.getRunningScene()):setName(msg)
        end
        
    end
    scheduler[msg] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(click,1,false)
    click()
end

local oldTrackBackFunc = __G__TRACKBACK__
__G__TRACKBACK__ = function ( msg )
    print(msg)
    print(debug.traceback(msg))
    showErrormsg(debug.traceback(msg))
    oldTrackBackFunc(msg)
end
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
