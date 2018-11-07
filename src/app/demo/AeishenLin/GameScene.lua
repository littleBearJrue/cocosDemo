require "VisibleRect"
local highScore 
--设置背景
local function createBG()
    local bg = cc.LayerColor:create(cc.c4b(0, 128, 128, 255));   
    return bg
end

--添加玩家
local function addPlayer()
    local player = cc.Sprite:create("Images/grossini.png");
    --player:setTag(1);
    local visibleSize = cc.Director:getInstance():getVisibleSize();
    local origin = cc.Director:getInstance():getVisibleOrigin();
    player:setPosition(origin.x + visibleSize.width/2, origin.y + player:getContentSize().height/2);
    local playerComponent = cc.ComponentLua:create("app/demo/AeishenLin/NodeScript/player.lua");
    player:addComponent(playerComponent);
    return player
end

--添加控制器
local function addControl()
    local ControlComponent = cc.ComponentLua:create("app/demo/AeishenLin/GameControl.lua");   
    ControlComponent:setName("ControlComponent");  
    return  ControlComponent                          
end

--添加菜单
local function addeEndMenu()
    local ImageBtn=cc.MenuItemImage:create("Images/btn-play-selected.png","Images/btn-play-normal.png")
    local function imageBtnCB(sender) 
        cc.Director:getInstance():replaceScene(GameSceneMain())
    end
    ImageBtn:registerScriptTapHandler(imageBtnCB)
    local mn = cc.Menu:create(ImageBtn)         
    mn:alignItemsVertically() --居中排列
    return mn
end


--数据处理
local function scoreSet(Current_Score)
    local resultLabel = nil;
    local hightScore = cc.UserDefault:getInstance():getIntegerForKey("hightScore")
    if Current_Score > hightScore then
        cc.UserDefault:getInstance():setIntegerForKey("hightScore", Current_Score)
        cc.UserDefault:getInstance():flush()
        resultLabel = cc.LabelBMFont:create("  Celebration...".."\n".."you made the hightScore:"..Current_Score, "fonts/bitmapFontTest.fnt")
    else
        resultLabel = cc.LabelBMFont:create("  GAME OVER".."\n".."you Score is:"..Current_Score, "fonts/bitmapFontTest2.fnt")
    end
    return resultLabel
end

local function createGameLayer()
    local layer = createBG()
    layer:addComponent(addControl());                                
    layer:addChild(addPlayer());

    local function setResult(event) 
        if tolua.isnull(layer) then
           return 
        end
        layer:removeAllChildren()
        local Current_Score = event.result
        local result1 = scoreSet(Current_Score)
        layer:addChild(result1) 
        result1:setPosition(cc.p(250,220))
        layer:removeComponent("ControlComponent")
        layer:addChild(addeEndMenu())
        layer:addChild(CreateBackMenuItem())
        -- layer:removeChildByTag(1)
        -- layer:removeChildByTag(2)
        -- layer:removeChildByTag(3)
    end

    local listener = cc.EventListenerCustom:create("game over",setResult) 
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

    return layer
end


function GameSceneMain()
    local scene = cc.Scene:create()
    scene:addChild(createGameLayer())
    return scene
end



