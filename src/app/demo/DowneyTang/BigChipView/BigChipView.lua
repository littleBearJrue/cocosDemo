local BigChipView = class("BigChipView", function()
	local chipBg = ccui.ImageView:create()
    return chipBg 
end)

--大筹码坐标配置
local posConfig = {
    cc.p(-400,10),
    cc.p(-200,10),
    cc.p(0,10),
    cc.p(200,10),
}

function BigChipView:init()
    --创建大筹码的光圈
    local chipLight = ccui.ImageView:create("DowneyTang/koprokdice/chip_btn_light.png")
    chipLight:setScale(1.4)
    chipLight:setPosition(posConfig[1])
    -- chipLight:setVisible(false)
    self:addChild(chipLight,1)--node:addChild(childNode, 0, 123) 第二个参数Z轴绘制顺序值较大的覆盖值较小的，第三个参数是标签

    --创建大筹码
    for i = 1, 4 do
        local btn = ccui.ImageView:create(string.format("DowneyTang/koprokdice/chip_btn%d.png", i))
        btn:setTouchEnabled(true)
        btn:setTag(i)
        btn:setPosition(posConfig[i])
        self:addChild(btn,0)
        btn:addTouchEventListener(function(touch,eventType)
            chipLight:setPosition(posConfig[i])
            local event = cc.EventCustom:new("setChipValue_event")
            event._usedata = btn:getTag()
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(event) 
        end) 
        
        --添加大筹码的面值显示
        local chipValue = ccui.ImageView:create(string.format("DowneyTang/chipNum/chipValue_%d.png", i))
        chipValue:setPosition(posConfig[i])
        if i>2 then
            chipValue:setScale(0.5)
        else
            chipValue:setScale(0.3)
        end
        self:addChild(chipValue,1)
    end
end

function BigChipView:ctor()
    self:init()
end

return BigChipView;