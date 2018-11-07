local appPath = "app.demo.AeishenLin.Bet"
local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local visibleSize= director:getVisibleSize()
local TestView =  require(appPath..".BetView")
local TestViewC =  require(appPath..".BetCtr")


--创建时钟
local function createClock()
    local clockNode = require("app/demo/AeishenLin/Clock/Clock")
    local clock = clockNode.new()
    clock.timeText = 6
    clock:setPosition(cc.p(origin.x + 3 * visibleSize.width / 4, origin.y + visibleSize.height / 2 ))
    clock:setTag(1)
    local Component = cc.ComponentLua:create("app/demo/AeishenLin/Clock/ClockCompent.lua");
    Component:setName("Component");  
    clock:addComponent(Component);
    return clock
end


local function main()
    local scene = cc.Scene:create();
    local bg = ccui.ImageView:create("Images/AeishenLin/chip/bg.png")
    scene:addChild(bg)
    bg:setPosition(cc.p(origin.x + visibleSize.width / 2,origin.x + visibleSize.height / 2 ))
    
    local testC = TestViewC.new();
    testC:initView(0);
    testC:getView():setPosition(cc.p(origin.x + visibleSize.width / 2,origin.x + visibleSize.height / 2 + 20))
    scene:addChild(testC:getView());
    



    
    -- ---计时测试按钮
    -- local ImageBtn=ccui.Button:create("Images/btn-play-normal.png","Images/btn-play-selected.png")
    -- scene:addChild(ImageBtn)
    -- ImageBtn:setPosition(cc.p(origin.x + 3 * visibleSize.width / 4, origin.y + visibleSize.height / 2 - 50))
    -- local function touchEvent(sender,eventType)
    --     if eventType == ccui.TouchEventType.began then

    --     local data = {}
    --     data.winSection = {1,2}
    --     dump(data.winSection)
    --     testC:sendEvenWithData(data)
    --     end
    -- end
    -- ImageBtn:addTouchEventListener(touchEvent)




    return scene
end

return main