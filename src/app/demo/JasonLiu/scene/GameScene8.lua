--[[--ldoc desc
@Module GameScene8.lua
@Author JasonLiu

Date: 2018-10-24 10:51:43
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 11:48:48
]]

local BetViewCtr = require("app.demo.JasonLiu.module.bet.BetViewCtr")

local function main()
    local scene = cc.Scene:create()

    scene:addChild(BetViewCtr:create():getView():move(display.cx, display.cy))

    scene:addChild(CreateBackMenuItem())

    return scene
end

return main