--[[--ldoc desc
@Module GameScene7.lua
@Author JasonLiu

Date: 2018-10-22 11:51:20
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 12:25:28
]]

local Chip = require("app.demo.JasonLiu.widget.Chip")

local function createButton()
    local button = ccui.Button:create("Images/btn-play-normal.png", "Images/btn-play-selected.png", "Images/btn-play-selected.png", 0):move(display.cx + 180, display.cy + 100)
    
    return button
end

local function main()
    local scene = cc.Scene:create()

    local chips = {}
    for i = 1, 8 do
        chips[i] = Chip:create(i):move(display.cx - 50 * 4 + 25 + 50 * (i - 1), display.cy - 100)
    
        scene:addChild(chips[i])
    end

    local button = createButton()
    button:addTouchEventListener(function(sender, eventType)
        if (0 == eventType)  then
            local index = math.random(8)
            local rx, ry = math.random(-20, 20), math.random(-20, 20)
            local chip = Chip:create(index, 1):move(chips[index]:getPosition())
            chip:runAction(cc.MoveTo:create(0.6, cc.p(display.cx + rx, display.cy + 100 + ry)))
            scene:addChild(chip)
        end
    end)
    scene:addChild(button)
    scene:addChild(CreateBackMenuItem())

    return scene
end

return main