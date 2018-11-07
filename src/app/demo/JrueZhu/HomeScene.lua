--[[--ldoc desc
@Module HomeScene.lua
@Author JrueZhu

Date: 2018-10-18 18:17:51
Last Modified by   JrueZhu
Last Modified time 2018-11-01 20:46:02
]]

local appPath = "app.demo.JrueZhu"
local HomeScene = class("HomeScene", cc.load("mvc").ViewBase)
local ClockCountDown = require(appPath .. ".widget.ClockCountDown")

local function createBackground()
    local visiblieSize = cc.Director:getInstance():getVisibleSize()
    local background1 = cc.Sprite:create("Images/JrueZhu/background.png");
    local spriteContentSize = background1:getTextureRect()
    background1:setPosition(visiblieSize.width/2, visiblieSize.height/2)
    background1:setScaleX(visiblieSize.width/spriteContentSize.width)
    background1:setScaleY(visiblieSize.height/spriteContentSize.height)


    local background2 = cc.Sprite:create("Images/JrueZhu/background.png");
    local spriteContentSize = background2:getTextureRect()
    background2:setPosition(visiblieSize.width/2, background1:getContentSize().height - 2)
    background2:setScaleX(visiblieSize.width/spriteContentSize.width)
    background2:setScaleY(visiblieSize.height/spriteContentSize.height)

    -- 背景滚动
    local function backgroundMove()
        background1:setPositionY(background1:getPositionY()-2)
        background2:setPositionY(background1:getPositionY() + background1:getContentSize().height - 2)
        if background2:getPositionY() == 0 then
            background1:setPositionY(0)
        end
    end
    
    local backgroundEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(backgroundMove, 0.01, false) 

    return background1, background2, backgroundEntry; 
end

-- FIXME:
local function createTitle()
   --  local title = cc.Label:createWithSystemFont("跳怪消星", "Arial", 30);
    local title = cc.Label:create();
    title:setString("跳怪消星");
    title:move(display.cx, display.cy + 50);
 


    return title;
end

local function createPlayBtn(backgroundEntry)
    local button = ccui.Button:create("Images/JrueZhu/btn_play.png", "", "", 0);
    button:move(display.cx, display.cy - 100)
    button:addTouchEventListener(function(sender, eventType)        
        if (ccui.TouchEventType.began == eventType)  then            
            print("pressed")
            local playScene = require("PlayScene.lua")
            -- local playScene = self:getApp():getSceneWithName("PlayScene");
            print("playScene------>", playScene)
            local transition = cc.TransitionTurnOffTiles:create( 0.5, playScene)
            cc.Director:getInstance():replaceScene(transition);
            -- 同时取消滚动
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(backgroundEntry)
        elseif (ccui.TouchEventType.moved == eventType)  then              
            print("move")        
        elseif  (ccui.TouchEventType.ended == eventType) then            
            print("up")        
        elseif  (ccui.TouchEventType.canceled == eventType) then            
            print("cancel")       
        end    
    end)
    return button;
end

local function createCard()
    local frameCache = cc.SpriteFrameCache:getInstance();
    frameCache:addSpriteFrames("Images/JrueZhu/CardResource/cards.plist") 
    local bg = cc.Sprite:createWithSpriteFrameName("bg.png");
    local bgHeight = bg:getContentSize().height;
    local bgWidth = bg:getContentSize().width;
    local valueImage = cc.Sprite:createWithSpriteFrameName("black_1.png");
    print("valueImage------>", valueImage)
    valueImage:setAnchorPoint(0, 1);
    valueImage:setPosition(10, bgHeight - 10);
    local valueImageWith = valueImage:getContentSize().width;
    local valueImageHeight = valueImage:getContentSize().height;
    bg:addChild(valueImage);
    local smallTypeImage = cc.Sprite:createWithSpriteFrameName("color_2_small.png");
    smallTypeImage:setAnchorPoint(0, 1);
    smallTypeImage:setPosition(10, bgHeight - valueImageHeight - 15);
    bg:addChild(smallTypeImage);
    local typeImage = cc.Sprite:createWithSpriteFrameName("color_2.png");
    typeImage:setAnchorPoint(0.5, 0.5);
    typeImage:setPosition(bgWidth/2, bgHeight/2);
    bg:addChild(typeImage);

    return bg;
end

local function main()
    -- 创建主场景
    local scene = cc.Scene:create()
    
    -- add moveable background
    -- local background1, background2, backgroundEntry = createBackground();
    -- scene:addChild(background1);
    -- scene:addChild(background2);

    -- -- add play label
    -- scene:addChild(createTitle());
    -- -- add play button    
    -- scene:addChild(createPlayBtn(backgroundEntry));
    
   -- scene:addChild(createCard())
   local clock = ClockCountDown:create({timer = 60}):move(display.center);
   clock.timer = 10;
   clock:setTimeEndListener(function()
       dump("timeout!!!!")
   end)
   scene:addChild(clock);

    return scene;
end


return main;
