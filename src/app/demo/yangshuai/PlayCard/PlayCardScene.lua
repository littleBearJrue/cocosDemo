--[[--ldoc desc
@module PlayCardScene
@author ShuaiYang

Date   2018-10-24 10:26:52
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:11:11
]]
local appPath = "app.demo.yangshuai"
print("yangshuai");

local PlayCardCtr =  require(appPath..".PlayCard.PlayCardCtr")


local function main()
    local scene = cc.Scene:create()

    local PlayCardCtr = PlayCardCtr.new();
    PlayCardCtr:initView();
    scene:addChild(PlayCardCtr:getView());
    PlayCardCtr:getView():move(display.center);
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main