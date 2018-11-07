local ZTAG_GAME_ISO = 1000
local ZTAG_GAME_UI = 2000

local function onTouchEvent(eventType, x, y)
    print(eventType,x,y)
    -- if eventType == "began" then
    --     prev.x = x
    --     prev.y = y
    --     return true
    -- elseif  eventType == "moved" then
    --     local node  = layer:getChildByTag(kTagTileMap)
    --     local newX  = node:getPositionX()
    --     local newY  = node:getPositionY()
    --     local diffX = x - prev.x
    --     local diffY = y - prev.y

    --     node:setPosition( cc.p.__add(cc.p(newX, newY), cc.p(diffX, diffY)) )
    --     prev.x = x
    --     prev.y = y
    -- end
end

local function createTouchLayers(scene)
    local layer1 = display.newLayer()
    local layer2 = display.newLayer()
    layer1:setTouchEnabled(true)
    layer1:registerScriptTouchHandler(onTouchEvent)
    scene:addChild(layer1,ZTAG_GAME_ISO,ZTAG_GAME_ISO)
    scene:addChild(layer2,ZTAG_GAME_UI,ZTAG_GAME_UI)
end


local function main()
    local scene = cc.Scene:create()

    -- local function onTouchBegan(touch, event)
    --     -- CCTOUCHBEGAN event must return true
    --     return true
    -- end

    -- local function onTouchEnded(touch,event)
    --     local pos = touch:getLocation()
    --     local target = event:getCurrentTarget()
    --     print(tolua.type(target))
    -- end

    -- local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    -- listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    -- local eventDispatcher = scene:getEventDispatcher()
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listener,scene)

    createTouchLayers(scene)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main