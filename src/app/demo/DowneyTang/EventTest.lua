local function test1()
    local scene = cc.Layer:create()
    local Label1 = cc.Label:createWithSystemFont("Touch Test", "Arial", 35)
    Label1:addTo(scene)
    Label1:setTextColor(cc.c4b(128, 128, 128, 255))
    Label1:setPosition(500,300) 
    local function eventCustomListener1(event)
        local str = "Custom event 1 received, "..event._usedata.." times"
        Label1:setString(str)
    end

    local listener1 = cc.EventListenerCustom:create("game_custom_event1",eventCustomListener1)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)
    local count1 = 1
    local function sendCallback1(tag, sender)
        count1 = count1 + 1
        
        local event = cc.EventCustom:new("game_custom_event1")
        event._usedata = string.format("%d",count1)
        eventDispatcher:dispatchEvent(event)
    end
    
    local sendItem1 = cc.MenuItemFont:create("创建闹钟")
    -- local sendItem1 = cc.LayerColor:create(cc.c3b(255,127,0))
    sendItem1:registerScriptTapHandler(sendCallback1)
    local  menu = cc.Menu:create(sendItem1)
    menu:setPosition(cc.p(500,100))
    scene:addChild(menu)
    return scene
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(test1())
    -- scene:addChild(CreateBackMenuItem())
    return scene
end

return main