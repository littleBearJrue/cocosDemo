--[[--ldoc desc
@module ObserverScene
@author ShuaiYang

Date   2018-10-23 10:01:54
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:07:44
]]
local appPath = "app.demo.yangshuai"

-- local init = require(appPath..".init");
local TestView =  require(appPath..".testView.TestView")
local TestViewC =  require(appPath..".testView.TestViewC")

local function main()
    local scene = cc.Scene:create()


    print("yangshuai 2222")
   

    local testC = TestViewC.new();
    testC:initView(2);
    scene:addChild(testC:getView());
    scene:addChild(CreateBackMenuItem())
    return scene
end


return main