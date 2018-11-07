--[[--ldoc desc
@Module GameScene6.lua
@Author JasonLiu

Date: 2018-10-19 14:25:09
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 12:25:10
]]

local Clock = require("app.demo.JasonLiu.widget.Clock")

local function createButton()
    local button = ccui.Button:create("Images/btn-play-normal.png", "Images/btn-play-selected.png", "Images/btn-play-selected.png", 0):move(display.cx, display.cy + 100)
    
    return button
end

local function createClock()
    local clock = Clock:create():move(display.cx, display.cy)

    -- clock:update({count = 30, imgPath = "Images/clock/clock_anim_1_1.png"})
    -- clock:setCount(6)
    -- clock:setImgPath("Images/clock/clock_anim_1_2.png")
    -- clock._count = 20
    -- clock._imgPath = "Images/clock/clock_anim_2_1.png"

    return clock
end

local function main()
    local scene = cc.Scene:create()

    local clock = createClock()
    clock:countdown(function ()
        print("countdown is completed")
    end, 10, true)
    
    local clockAnimComponent = cc.ComponentLua:create("app/demo/JasonLiu/component/ClockAnimComponent.lua");
    clock:addComponent(clockAnimComponent);
    
    
    local button = createButton()
    --按钮的回调函数
    button:addTouchEventListener(function(sender, eventType)
        if (0 == eventType)  then
            print("pressed")
            clock:countdown(function ()
                print("countdown is completed")
            end, 8, true)
        end
    end)

    scene:addChild(clock) 
    scene:addChild(button)
    scene:addChild(CreateBackMenuItem())
    
    return scene
end

return main