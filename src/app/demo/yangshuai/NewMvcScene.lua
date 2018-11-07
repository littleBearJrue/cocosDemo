--[[--ldoc desc
@module NewMvcScene
@author ShuaiYang

Date   2018-10-30 15:45:34
Last Modified by   ShuaiYang
Last Modified time 2018-11-01 15:12:33
]]

local appPath = "app.demo.yangshuai"

-- local init = require(appPath..".init");
local TestView =  require(appPath..".mvpTest.TestView")
local TestViewP =  require(appPath..".mvpTest.TestViewP")

local function main()
    local scene = cc.Scene:create()


    print("yangshuai NewMvcScene")
   

    local testC = TestViewP.new();
    testC:initView(2);
    scene:addChild(testC:getView());
    scene:addChild(CreateBackMenuItem())
    return scene
end


return main