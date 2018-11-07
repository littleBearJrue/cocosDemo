



local function main()
    local scene = cc.Scene:create()

    local sp = ccui.Button:create("yiang/caishen.png","yiang/caishen.png","yiang/caishen.png")
    :move(display.cx, display.cy)
    :setContentSize(cc.p(300,300))
    scene:addChild(sp)
    scene:addChild(CreateBackMenuItem())

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        dump(touch, "touch == ")
        dump(event, "event == ")
        local location = touch:getLocation()
        
        sp:runAction(cc.MoveTo:create(1, cc.p(location.x, location.y)))
        local posX, posY = sp:getPosition()

        local o = location.x - posX
        local a = location.y - posY
        local at = math.atan(o / a) / math.pi * 180.0

        if a < 0 then
            if o < 0 then
                at = 180 + math.abs(at)
            else
                at = 180 - math.abs(at)
            end
        end
        sp:runAction(cc.RotateTo:create(1, at))
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)


    return scene
end

return main