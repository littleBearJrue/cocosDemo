--[[--ldoc desc
@module SSZViewScene
@author JrueZhu

Date   2018-10-31 10:13:45
Last Modified by   JrueZhu
Last Modified time 2018-10-31 20:19:27
]]

local appPath = "app.demo.JrueZhu"
local SSZViewCtrl = require(appPath..".ssz.SSZViewCtrl");

local function main()
    -- 创建主场景
    local scene = cc.Scene:create()
    
    local sszViewCtrl = SSZViewCtrl:create();
    sszViewCtrl:createRandomCards();
    local sszView = sszViewCtrl:getView();
    scene:addChild(sszView)
    scene:addChild(CreateBackMenuItem())
    return scene;
end


return main;