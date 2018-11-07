local Clock = require("app.DowneyTang.Clock")
local ClockBehavior =  require("app.DowneyTang.ClockBehavior")
local Chip = require("app.DowneyTang.Chip");
local ChipBehavior =  require("app.DowneyTang.ChipBehavior")

local function main()
    local scene = cc.Scene:create()
    --【时钟模块测试】
    local newClock = Clock.create();
    newClock:bindBehavior(ClockBehavior);
    newClock.setTime = 10           --倒计时时间设置，时钟View的一个属性
    newClock:clockCount(10);        --倒计时时间，组件实现，与上面setTime的时间一致，只设置一个参数【timeCount->倒计时时间】
    newClock:clockShake(3);         --时钟摇晃，组件实现，只设置一个参数【shakeTime->闹钟开始摇晃时间】
    newClock:setPosition(100,200)
    scene:addChild(newClock)
    -- newClock.setBg = "DowneyTang/123123.png"


    --【飞筹码模块测试:创建单个筹码的View】
    local newChip = Chip.create();
    newChip:bindBehavior(ChipBehavior);
    newChip.chipValue = 2
    newChip:setPosition(100, 100)
    newChip:chipMove(cc.p(100, 100), cc.p(450, 300));       --筹码移动，组件实现,设置两个参数【1:startPos->筹码初始坐标 2:endPos->筹码终点坐标】
    scene:addChild(newChip)
    
    
    -- --【飞筹码模块测试(选用):输入筹码金额，直接创建多个筹码】
    -- local FlyChip = require("app/DowneyTang/FlyChip");
    -- local newFlyChip = FlyChip.new();
    -- newFlyChip.setChip = 2560
    -- -- newFlyChip:setPosition(100, 100)
    -- scene:addChild(newFlyChip)
    -- -- 飞筹码动画
    -- local chip = newFlyChip:getChildren()
    -- local posY = 300
    -- for i= #chip, 1, -1 do
    --     local rotate = cc.RotateBy:create(5, 360)
    --     local moveTo = cc.MoveTo:create(5, cc.p(420, posY))
    --     local mySpawn = cc.Spawn:create(rotate, moveTo)
    --     -- local spawn = mySpawn:clone()
    --     chip[i]:setPosition(100, 100)
    --     chip[i]:runAction(mySpawn)
    --     posY = posY - 20
    -- end
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main