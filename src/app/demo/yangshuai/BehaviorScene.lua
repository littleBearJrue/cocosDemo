--[[--ldoc desc
@module BehaviorScene
@author ShuaiYang

Date   2018-10-22 16:30:31
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:08:14
]]

local appPath = "app.demo.yangshuai"

-- local init = require(appPath..".init");
local TestView =  require(appPath..".testView.TestView")
local TestViewC =  require(appPath..".testView.TestViewC")

local function main()
    local scene = cc.Scene:create()


    print("yangshuai 2222")
   

    local testC = TestViewC.new();
    testC:initView(1);
    scene:addChild(testC:getView());
    scene:addChild(CreateBackMenuItem())
    return scene
end


-- local function test1()
--     local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal, 0)
--     :move(display.cx, display.cy)
--     btn:setAnchorPoint(cc.p(0.5, 0.5))
--     return btn
-- end

-- local function main()
--     local scene = cc.Scene:create()
--     scene:addChild(test1())
--     scene:addChild(CreateBackMenuItem())
--     return scene
-- end

return main