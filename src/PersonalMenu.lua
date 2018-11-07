require "VisibleRect"
require "testResource"
require "Helper"
-- require "lfs"
local fileUtils = cc.FileUtils:getInstance()

local LINE_SPACE = 40

local CurPos = {x = 0, y = 0}
local BeginPos = {x = 0, y = 0}
local s = cc.Director:getInstance():getWinSize()

local CCMenu
local personalMenu
local backMenu

local _personalDirs = {
    "jasonhuang",
    "KevinZhang",
    "AeishenLin",
    "EdmanWang",
    "JasonLiu",
    "JoeyChen",
    "JrueZhu",
    "SilvaZhang",
    "YiangYang",
    "DowneyTang",
    "yangshuai"
}

local DIRS_COUNT = table.getn(_personalDirs)
local DEMO_COUNT

-- create scene
local function CreateTestScene(nIdx)
    local dirName = _personalDirs[nIdx]
    if not fileUtils:isDirectoryExist(dirName) then
        error(dirName..' 目录不存在')
    end
    local list = require("app.demo."..dirName..".init").showList
    -- dump(list)
    -- local fullPath = fileUtils:fullPathForFilename(dirName)
    -- print(fullPath)
    -- cc.Director:getInstance():purgeCachedData()
    -- local scene = _personalDirs[nIdx].create_func()
    local scene = cc.Scene:create()
    return scene
end

-- 创建个人demo目录
local function CreatePersonalDemoDir(nIdx)
    local dirName = _personalDirs[nIdx]
    if not fileUtils:isDirectoryExist(dirName) then
        error(dirName..' 目录不存在')
    end
    local dirs = require("app.demo."..dirName..".init")
    local list = dirs.showList

    local testSceneCallback = function(tag)
        -- print(tag)
        local Idx = tag - 100000
        print(list[Idx])
        local demoName = list[Idx]
        local demoScene = dirs[demoName]()
        if demoScene then
            cc.Director:getInstance():pushScene(demoScene)
        end
    end

    local mmenu = CCMenu:getChildByName("mainmenu")
    mmenu:setVisible(false)
    backMenu:setVisible(true)
    if not personalMenu then
        personalMenu = cc.Menu:create()
        personalMenu:setName("personalmenu")
        CCMenu:addChild(personalMenu)
    else
        personalMenu:setVisible(true)
        personalMenu:removeAllChildren()
    end
    personalMenu:setPosition(0, 0)
    local count = table.getn(list)
    DEMO_COUNT = count
    if count > 0 then
        personalMenu:setContentSize(cc.size(s.width, (count + 1) * (LINE_SPACE)))
        for index, obj in pairs(list) do
            local testLabel = cc.Label:createWithTTF(obj, s_arialPath, 24)
            testLabel:setAnchorPoint(cc.p(0.5, 0.5))
            local testMenuItem = cc.MenuItemLabel:create(testLabel)
    
            testMenuItem:registerScriptTapHandler(testSceneCallback)
            testMenuItem:setPosition(cc.p(s.width / 2, (s.height - (index) * LINE_SPACE)))
            personalMenu:addChild(testMenuItem, index + 100000, index + 100000)
        end
    end   
end

-- create menu
function CreatePersonalMenu()
    local menuLayer = cc.Layer:create()
    CCMenu = menuLayer

    local function closeCallback()
        cc.Director:getInstance():endToLua()
    end

    local function backCallback()
        local mmenu = CCMenu:getChildByName("mainmenu")
        mmenu:setVisible(true)
        personalMenu:setVisible(false)
        backMenu:setVisible(false)       
    end

    local function menuCallback(tag)
        print(tag)
        local Idx = tag - 10000
        CreatePersonalDemoDir(Idx)
        -- if testScene then
        --     cc.Director:getInstance():replaceScene(testScene)
        -- end
    end

    -- add close menu
    
    local CloseItem = cc.MenuItemImage:create(s_pPathClose, s_pPathClose)
    CloseItem:registerScriptTapHandler(closeCallback)
    CloseItem:setAnchorPoint(1, 1)
    CloseItem:setPosition(VisibleRect:rightTop())

    local CloseMenu = cc.Menu:create()
    CloseMenu:setPosition(0, 0)
    CloseMenu:addChild(CloseItem)
    menuLayer:addChild(CloseMenu)

    local backItem = cc.MenuItemImage:create(s_pPathB1,s_pPathB1)
    backItem:registerScriptTapHandler(backCallback)
    backItem:setAnchorPoint(1, 0)
    backItem:setPosition(VisibleRect:rightBottom())
    backMenu = cc.Menu:create()
    backMenu:setPosition(0, 0)
    backMenu:addChild(backItem)
    menuLayer:addChild(backMenu)
    backMenu:setVisible(false)


    -- add menu items for tests
    local MainMenu = cc.Menu:create()
    for index, obj in pairs(_personalDirs) do
        local testLabel = cc.Label:createWithTTF(obj, s_arialPath, 24)
        testLabel:setAnchorPoint(cc.p(0.5, 0.5))
        local testMenuItem = cc.MenuItemLabel:create(testLabel)

        testMenuItem:registerScriptTapHandler(menuCallback)
        testMenuItem:setPosition(cc.p(s.width / 2, (s.height - (index) * LINE_SPACE)))
        MainMenu:addChild(testMenuItem, index + 10000, index + 10000)
    end

    MainMenu:setContentSize(cc.size(s.width, (DIRS_COUNT + 1) * (LINE_SPACE)))
    
    MainMenu:setPosition(CurPos.x, CurPos.y)
    MainMenu:setName("mainmenu")
    menuLayer:addChild(MainMenu)

    -- local layer11 = cc.LayerColor:create(cc.c4b(255, 0, 0, 50), s.width, (DIRS_COUNT + 1) * (LINE_SPACE))
    -- layer11:setPosition(CurPos.x, CurPos.y)
    -- menuLayer:addChild(layer11)

    -- handling touch events
    local function onTouchBegan(touch, event)
        print('onTouchBegan')
        BeginPos = touch:getLocation()
        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        local nMoveY = location.y - BeginPos.y
        local isPersonalDir = false
        local curMenu = MainMenu
        if MainMenu:isVisible() == false then
            curMenu = personalMenu
            isPersonalDir = true
            if personalMenu:getContentSize().height <= s.height then
                return
            end
        else
            DEMO_COUNT = nil
        end
        local curPosx, curPosy = curMenu:getPosition()
        local nextPosy = curPosy + nMoveY
        local winSize = cc.Director:getInstance():getWinSize()
        -- print("next_pos_y "..nextPosy)
        if nextPosy < 0 then
            curMenu:setPosition(0, 0)
            return
        end

        local cc_count = DIRS_COUNT
        if isPersonalDir and DEMO_COUNT then
            cc_count = DEMO_COUNT
        end
        if nextPosy > ((cc_count + 1) * LINE_SPACE - winSize.height) then
            curMenu:setPosition(0, ((cc_count + 1) * LINE_SPACE - winSize.height))
            return
        end

        curMenu:setPosition(curPosx, nextPosy)
        BeginPos = {x = location.x, y = location.y}
        CurPos = {x = curPosx, y = nextPosy}
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    if MainMenu:getContentSize().height > s.height then
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    end
    local eventDispatcher = menuLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, menuLayer)

    return menuLayer
end
