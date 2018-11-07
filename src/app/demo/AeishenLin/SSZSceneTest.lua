
local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local visibleSize= director:getVisibleSize()
local SSZView = import(".SSZ.SSZView")
local SSZCtr =  require(".SSZ.SSZCtr")



local function main()
    -- 创建主场景
    local scene = cc.Scene:create()
    local sszCtr = SSZCtr.new();
    sszCtr:initView(0);
    --sszCtr:getView():setPosition(cc.p(origin.x + visibleSize.width / 2,origin.x + visibleSize.height / 2 + 20))
    scene:addChild(sszCtr:getView());
    return scene;
end


return main;