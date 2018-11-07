
local function createMenu()
    --Toggle
    local ret = cc.Layer:create()
    cc.MenuItemFont:setFontName( "Marker Felt" )
    cc.MenuItemFont:setFontSize(34)
    local function menuCallback(tag, sender)
        dump({tag = tag, selected = sender:getSelectedIndex()}, "ssssssssssssssss")
    end
    local  item1 = cc.MenuItemToggle:create(cc.MenuItemFont:create( "On" ))
    item1:registerScriptTapHandler(menuCallback)
    item1:addSubItem(cc.MenuItemFont:create( "Off"))

    local item2 = cc.MenuItemToggle:create(cc.MenuItemFont:create( "On" ))
    item2:registerScriptTapHandler(menuCallback)
    item2:addSubItem(cc.MenuItemFont:create( "Off"))

    local item3 = cc.MenuItemToggle:create(cc.MenuItemFont:create( "High" ))
    item3:registerScriptTapHandler(menuCallback)
    item3:addSubItem(cc.MenuItemFont:create( "Low" ))

    local item4 = cc.MenuItemToggle:create(cc.MenuItemFont:create( "Off"),
                                        cc.MenuItemFont:create( "33%" ),
                                        cc.MenuItemFont:create( "66%" ),
                                        cc.MenuItemFont:create( "100%"))
    item4:registerScriptTapHandler(menuCallback)

    -- you can change the one of the items by doing this
    item4:setSelectedIndex( 2 )

    local menu = cc.Menu:create()
    menu:addChild(item1)
    menu:addChild(item2)
    menu:addChild(item3)
    menu:addChild(item4)

    menu:alignItemsInColumns(4)
    ret:addChild(menu)

    local s = cc.Director:getInstance():getWinSize()
    menu:setPosition(cc.p(s.width/2, s.height/2))

    return ret
end

local function createCheckBox()
    --CheckBox
    local checkBox = ccui.CheckBox:create("Images/btn-play-normal.png","Images/btn-play-selected.png")
    checkBox:move(display.cx, display.cy + 100)
    checkBox:addEventListener(function(sender, eventType)
            dump(eventType, "sssssssssssss")
        end)
    return checkBox
end

local function main()
    local scene = cc.Scene:create()

    scene:addChild(createMenu())
    scene:addChild(createCheckBox())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main