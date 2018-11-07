local accLeft = false;
local accRight = false;
local accTop = false;
local accButtom = false;
local accFire = false;
local xSpeed = 100;

local function getPlayerAnim(num, len)
    local animation = cc.Animation:create()
    for i = 1, len do
        local name = "Images/JasonLiu/".. num .."-".. i .. ".png"
        animation:addSpriteFrameWithFile(name)
    end
    -- should last 2.8 seconds. And there are 14 frames.
    animation:setDelayPerUnit(len * 0.1 / len)
    animation:setRestoreOriginalFrame(true)

    local action = cc.Animate:create(animation)

    return cc.RepeatForever:create(cc.Sequence:create(action, action:reverse()))
end

local function getRunAction()
    return getPlayerAnim(54068, 8)
end

local function getStandAction()
    return getPlayerAnim(54066, 4)
end

local function getFireAction()
    return getPlayerAnim(54071, 6)
end

local function createPlayer()
    local sprite = cc.Sprite:create("Images/JasonLiu/54066-1.png")
    sprite:setName("player1")
    sprite:setAnchorPoint(0.5, 0)
    sprite:setPosition(cc.p(display.cx - 100, display.cy))

    sprite:runAction(getStandAction())

    sprite:scheduleUpdateWithPriorityLua(function(dt)
        if not accFire then
            local bx,by = sprite:getPosition()
            if accLeft then
                sprite:setFlippedX(true)
                sprite:setPosition(bx - xSpeed * dt, by)
            elseif accRight then
                sprite:setFlippedX(false)
                sprite:setPosition(bx + xSpeed * dt, by)
            elseif accTop then 
                sprite:setPosition(bx, by + xSpeed * dt)
            elseif accButtom then
                sprite:setPosition(bx, by - xSpeed * dt)
            end
        end
    end, 0)


    -- 按键事件
    local function keyboardReleased(keyCode, event)
        if keyCode == 26 then  
            accLeft = false;
        elseif keyCode == 27 then  
            accRight = false;
        elseif keyCode == 28 then  
            accTop = false;
        elseif keyCode == 29 then  
            accButtom = false;
        elseif keyCode == 124 then
            accFire = false;
        end  

        if not accFire then
            sprite:stopAllActions()
            if not accLeft and not accRight and not accTop and not accButtom then
                sprite:runAction(getStandAction())
            else
                sprite:runAction(getRunAction())
            end
        end
    end
    local function keyboardPressed(keyCode, event)  
        if keyCode == 26 then  
            accLeft = true;
        elseif keyCode == 27 then  
            accRight = true;
        elseif keyCode == 28 then  
            accTop = true;
        elseif keyCode == 29 then  
            accButtom = true;
        elseif keyCode == 124 then
            accFire = true;
        end  

        if accFire then
            sprite:stopAllActions()
            sprite:runAction(getFireAction())
        elseif accLeft or accRight or accTop or accButtom then
            sprite:stopAllActions()
            sprite:runAction(getRunAction())
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(keyboardReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = sprite:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, sprite)

    local box = cc.PhysicsBody:createEdgeBox(cc.size(sprite:getContentSize().width * 2, sprite:getContentSize().height))
    box:setDynamic(true)
    box:setCategoryBitmask(1)  
    box:setContactTestBitmask(1)  
    box:setCollisionBitmask(2)
    sprite:setPhysicsBody(box)

    return sprite
end

local function createPlayer2()
    local sprite = cc.Sprite:create("Images/JasonLiu/54042-1.png")
    sprite:setName("player2")
    sprite:setPosition(cc.p(display.cx + 100, display.cy))
    sprite:setFlippedX(true)
    sprite:runAction(getPlayerAnim(54042, 4))

    -- sprite:setPhysicsBody(cc.PhysicsBody:createEdgeBox(cc.size(sprite:getContentSize().width, sprite:getContentSize().height)))
    local box = cc.PhysicsBody:createEdgeBox(cc.size(sprite:getContentSize().width, sprite:getContentSize().height))
    box:setDynamic(true)
    box:setCategoryBitmask(1)  
    box:setContactTestBitmask(1)  
    box:setCollisionBitmask(2)
    sprite:setPhysicsBody(box)

    return sprite
end

local function createPlayer2Tips()
    local label = cc.Label:createWithSystemFont("", "Arial", 12):move(display.cx + 100, display.cy + 50)

    return label
end

local function createTips()
    local label = cc.Label:createWithSystemFont(" ↑↓ ← →  A", "Arial", 8):move(30, 45)

    return label
end

local function main()
    -- local scene = cc.Scene:create()
    local scene = cc.Scene:createWithPhysics()
    -- 调整物理世界重力
    scene:getPhysicsWorld():setGravity(cc.p(0, 0));
    -- 设置Debug模式
    scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    
    scene:addChild(createPlayer2())
    scene:addChild(createPlayer())
    scene:addChild(createTips())
    local player2Tips = createPlayer2Tips()
    scene:addChild(player2Tips)
    scene:addChild(CreateBackMenuItem())


    local conListener = cc.EventListenerPhysicsContact:create()
    conListener:registerScriptHandler(function(contact)  
        local node1 = contact:getShapeA():getBody():getNode()  
        local node2 = contact:getShapeB():getBody():getNode()
        if not node1 or not node2 then return end 
        if node1:getName() ~= node2:getName() and accFire then
            player2Tips:setString("大哥，别打我")
            performWithDelay(player2Tips, function()  
                player2Tips:setString("")
            end, 2)  
        end
        return true  
    end, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(conListener, scene)

    return scene
end

return main