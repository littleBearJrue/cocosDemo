
local appPath = "app.demo.yangshuai"

print("yangshuai");
local ModuleConfig = require(appPath..".ModuleConfig");

-- local init = require(appPath..".init");
local TestViewC =  require(appPath..".testView.TestViewC")


local function main()
    local scene = cc.Scene:create()
    -- print("yangshuai package.path ",package.path );

    -- for k,v in pairs(ModuleConfig) do
    --     print("yangshuai v i",'.'..i..v.name);
    --     -- if v.name then
    --     --     local view = require(appPath..'.'..i..v.name);
    --     --     scene.addChild(view.new());
    --     --     view:move(display.center);
    --     -- end
    -- end
    


    local testC = TestViewC.new();
    testC:initView(0);
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