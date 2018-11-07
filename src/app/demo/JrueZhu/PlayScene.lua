--[[
 -- @Author: Jrue 
 -- @Date: 2018-10-18 10:34:42 
 -- @Last Modified by:   Jrue 
 -- @Last Modified time: 2018-10-18 10:34:42 
 --]]

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

local jumpHeightlimit = 300;
local jumpLeft = false;
local jumpRight = false;
local xSpeed = 0; 
local player = nil;

local function keyboardPressed(keyCode, event)
    if keyCode == 26 then
        print("left!!!")
        jumpLeft = true;
    elseif keyCode == 27 then
        print("right!!!")
        jumpRight = true;
    end
end

local function keyboardReleased(keyCode, event)
    if keyCode == 26 then
        print("left!!!")
        jumpLeft = false;
    elseif keyCode == 27 then
        print("right!!!")
        jumpRight = false;
    end
end

local function SceneUpdate(dt)
    print("dt ---->", dt)
    local x, y = player:getPosition();
    print("x and y ----->", x, y)
    if jumpLeft then
        local curX = x - 10;
        if x - 10 < display.left then
            curX = 0;
        end 
        player:setPosition(curX, y);
        print("after x and y ----> ", x + xSpeed, y);
    elseif jumpRight then
        print("display_right -------->", display.right)
        local curX = x + 10;
        local playerWidth = player:getContentSize().width;
        print("playerWidth ----->", playerWidth)
        if x + 10 + playerWidth >= display.right then
            curX = display.right - playerWidth;
        end
        player:setPosition(curX, y);
        print("after x and y ----> ", x + xSpeed, y);
    end
end

local function createBackground()
    local visiblieSize = cc.Director:getInstance():getVisibleSize()
    local background_wall = cc.Sprite:create("Images/JrueZhu/play_background.jpg");
    local spriteContentSize = background_wall:getTextureRect()
    background_wall:setPosition(visiblieSize.width/2, visiblieSize.height/2)
    background_wall:setScaleX(visiblieSize.width/spriteContentSize.width)
    background_wall:setScaleY(visiblieSize.height/spriteContentSize.height)
    return background_wall;
end

local function createGround()
    local visiblieSize = cc.Director:getInstance():getVisibleSize()
    local ground_image = cc.Sprite:create("Images/JrueZhu/ground.png");
    local spriteContentSize = ground_image:getTextureRect()
    ground_image:setPosition(visiblieSize.width/2, 0)
    ground_image:setScaleX(visiblieSize.width/spriteContentSize.width)
    return ground_image;
end

local function main()
    local scene = cc.Scene:create();

    
    scene:scheduleUpdateWithPriorityLua(SceneUpdate, 0);


    scene:addChild(createBackground());

    scene:addChild(createGround());

    local function setPlayerJumpAction()
        local jumpDuration = 0.5;
        local jumpHeight = 20;
        local jumpUp = cc.EaseIn:create(cc.MoveBy:create(jumpDuration, cc.p(0, jumpHeightlimit)), 0.5);
        local jumpDown = cc.EaseOut:create(cc.MoveBy:create(jumpDuration, cc.p(0, -jumpHeightlimit)), 0.5);
        return cc.RepeatForever:create(cc.Sequence:create(jumpUp, jumpDown));
    end

    player = cc.Sprite:create("Images/JrueZhu/PurpleMonster.png");
    player:setPosition(display.cx, display.cy - 100)
    player:setAnchorPoint(0, 0)
   
    local playerAction = setPlayerJumpAction();
    player:runAction(playerAction);

    local listener = cc.EventListenerKeyboard:create();
    listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED);
    listener:registerScriptHandler(keyboardReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local dispacher = cc.Director:getInstance():getEventDispatcher();
    dispacher:addEventListenerWithSceneGraphPriority(listener, scene);

    scene:addChild(player)

    scene:addChild(CreateBackMenuItem())

    return scene;
end


return main;