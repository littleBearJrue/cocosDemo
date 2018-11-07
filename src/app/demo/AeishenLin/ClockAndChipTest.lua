--[[--ldoc desc
@Module ClockAndChipTest.lua
@Author AeishenLin

Date: 2018-10-25 18:05:57
Last Modified by: AeishenLin
Last Modified time: 2018-10-26 11:43:25
]]

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local visibleSize= director:getVisibleSize()

--创建下注背景视图
local function createBetView()
    local betNode = require("app/demo/AeishenLin/Bet/BetView")
    local bet = betNode.new()
    bet:setPosition(cc.p(200,200))
    bet:setScale(0.5,0.5)
    return bet
end

--创建筹码按钮视图
local function createChipBtnView()
    local chipBtnNode = require("app/demo/AeishenLin/Bet/ChipBtnView")
    local chipBtn = chipBtnNode.new()
    --chipBtn:setPosition(cc.p(200,50))
    chipBtn:setPosition(cc.p(0,-300))
    --chipBtn:setScale(0.5,0.5)
    return chipBtn
end
 
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


--[[
@function: createChip 创建飞筹码
@param: value         筹码值
@return: chip        
]]
local function createChip(value)
    if value then
        local chipNode = require("app/demo/AeishenLin/Chip/Chip")
        local chip = chipNode.new()
        chip.money = value
        chip:setPosition(cc.p(origin.x + visibleSize.width / 2,  - 100))
        return chip
    end
end


local function main()
    director:setDisplayStats(false);
    local scene = cc.Scene:create()

    local betView = createBetView()
    scene:addChild(betView)

    local chipView = createChipBtnView()
    betView:addChild(chipView)
    

    local value = 1       --初始化筹码按键为第一个筹码按键
    local num = nil       --初始化下注触摸区域编号为空

    chipView:updateData(function (data)
        value = data                                    --筹码按钮侦听事件接受选中哪个筹码按键并返回该按键的编号
    end)
   
    betView:updateData(function (data)
        num = data                                       --下注触摸区域侦听事件接受选中哪个区域并返回该区域的编号
        if num then
            local chip = createChip(value)               
            local endX, endY = betView:getRandomPos(num,chip)  --设置筹码在选中区域随机位置，该位置为betView上的坐标，即节点坐标
            local target = betView:getChildByTag(num)          --通过编号获得选中区域
            betView:updateSectionValue(target,value)           --记录该区域上对应值的筹码的个数
            local worldPos = target:convertToWorldSpace({x = endX, y = endY});   --将筹码在选中区域随机位置转换为世界坐标
            scene:addChild(chip)                                    --先将筹码添加到场景作为其子物体

            local actionMoveDone = cc.CallFunc:create(function ()   --筹码运动结束后的回调函数
                local chipCount = target:getChildrenCount()         --获取该区域上的筹码数量
                --chip:retain()    
                chip:removeFromParent()                             --筹码脱离场景         
                target:addChild(chip)                               --筹码作为该区域的新的子物体
                chip:setTag(chipCount + 1)                          --给每个区域新加的筹码设置编号
                chip:setPosition(cc.p(endX,endY))                         --筹码设置位置为选中区域随机位置
                chip:setScale(0.4,0.4)
                print("当前区域编号："..num..";  ".."当前区域筹码数量："..#target:getChildren())
            end)

            local actionMove = cc.MoveTo:create(0.4,cc.p(worldPos.x,worldPos.y))  --筹码飞到对应世界坐标位置
            chip:runAction(cc.Sequence:create(actionMove, actionMoveDone))
        end
    end)
    

    ---创建一个收钱的
    local sprite= ccui.ImageView:create("Images/AeishenLin/chip/chip_btn_light.png")
    scene:addChild(sprite)
    sprite:setPosition(cc.p(origin.x + 2 * visibleSize.width / 3, origin.y + visibleSize.height - 100))

    ---文字
    local label = cc.Label:create()
    scene:addChild(label)
    label:setPosition(cc.p(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 -140))


    ---假装获取游戏结果
    local function setResult(event) 
        print(event.result)
        local target = betView:getChildByTag(event.result)   --获取中奖区域
        label:setString("中奖号码："..event.result.."\n".."中奖明细: 100k:"..target.value[1].."个；500K:"..target.value[2].."个；1M:"..target.value[3].."个；5M:"..target.value[4])
        betView:resetSectionValue(target)   -- target.value = {0,0,0,0}
        if target:getChildrenCount() > 0 then                 
            local chipCount = target:getChildrenCount()      --获取中奖区域上的筹码数量
            for i = 1, chipCount do
                local childChip = target:getChildByTag(i)    --获取中奖区域上每个筹码
                -- local p = sprite:getPosition()
                -- dump(p)
                local xp = math.random( origin.x + 2 * visibleSize.width / 3 - 12, origin.x + 2 * visibleSize.width / 3 + 12 )
                local yp = math.random( origin.y + visibleSize.height - 112, origin.y + visibleSize.height - 88 )
                local nodePos = target:convertToNodeSpace({x = xp , y = yp})
                local actionMoveDone = cc.CallFunc:create(function ()
                    -- childChip:retain()
                    childChip:removeFromParent()  
                    scene:addChild(childChip)
                    childChip:setPosition(cc.p(xp,yp))
                    childChip:setScale(0.2,0.2)              
                end)
                local actionMove = cc.MoveTo:create(0.4,cc.p(nodePos.x,nodePos.y))
                childChip:runAction(cc.Sequence:create(actionMove, actionMoveDone))
                --local worldPos = target:convertToWorldSpace(p)
            end
        end
    end
    local listener = cc.EventListenerCustom:create("game over",setResult) 
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

    ---计时测试按钮
    local ImageBtn=ccui.Button:create("Images/btn-play-normal.png","Images/btn-play-selected.png")
    scene:addChild(ImageBtn)
    ImageBtn:setPosition(cc.p(origin.x + 3 * visibleSize.width / 4, origin.y + visibleSize.height / 2 - 50))
    function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            local clock1 = createClock()
            clock1.timeText = 6
            scene:addChild(clock1)
        end
    end
    ImageBtn:addTouchEventListener(touchEvent)

    --local clock = createClock()
    -- local chip = createChip()
    --scene:addChild(clock)
    -- scene:addChild(chip)
    -- local meun = createMu(scene)
    -- scene:addChild(meun)
    return scene
end 

return main


