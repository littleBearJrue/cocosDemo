--[[--ldoc desc
@Module GameScene9.lua
@Author JasonLiu

Date: 2018-10-30 09:57:42
Last Modified by: JasonLiu
Last Modified time: 2018-10-30 14:26:40
]]
local DeployCardCtr = require("app.demo.JasonLiu.module.deployCard.DeployCardCtr")

local function main()
    local scene = cc.Scene:create()
    
    scene:addChild(DeployCardCtr:create():getView():move(display.cx, display.cy):setScale(0.6))
    
    scene:addChild(CreateBackMenuItem())

    return scene
end

return main