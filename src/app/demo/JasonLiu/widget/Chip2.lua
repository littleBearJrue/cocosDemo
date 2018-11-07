--[[--ldoc desc
@Module Chip.lua
@Author JasonLiu

Date: 2018-10-24 14:25:57
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 11:52:07
]]

local Chip = class("Chip", cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

BehaviorExtend(Chip);

function Chip:ctor(type, color, value, fontSize)
    self:initView(type, color, value, fontSize)
end

--[[
    @function initView      初始化View
    @param #type int        筹码的类型 大：0 小 1
    @param #color int       筹码的颜色 
    @param #value string    筹码的值
    @param #fontSize int    筹码的字体大小
]] 
function Chip:initView(type, color, value, fontSize)
    self._data = {
        type = type or 0,
        color = color or 1,
        value = value or "5K",
        fontSize = fontSize or 10
    }
    if self._data.type == 0 then
        self:addBigChip(self._data.color, self._data.value, self._data.fontSize)
    else
        self:addSmallChip(self._data.color)
    end
end

--[[
    @function addSmallChip   添加一个小筹码
    @param #color int        筹码的颜色 
]] 
function Chip:addSmallChip(color)
    local chipTexture = cc.SpriteBatchNode:create("Images/koprokdice/koprok_chip_pin.png"):getTexture()
    self.chipView = cc.Sprite:createWithTexture(chipTexture, cc.rect(5 + (4 - color) * (33 + 9), 5, 33, 33)):setContentSize(cc.size(10,10))
    
    self:addChild(self.chipView)
end

--[[
    @function addSmallChip   添加一个大筹码
    @param #color int        筹码的颜色 
    @param #value string     筹码的值
    @param #fontSize int     筹码的字体大小
]] 
function Chip:addBigChip(color, value, fontSize)
    self.chipLight = cc.Sprite:create("Images/koprokdice/chip_btn_light.png"):setContentSize(cc.size(50, 50)):setVisible(false)
    self.chipView = ccui.ImageView:create("Images/koprokdice/chip_btn" .. color .. ".png"):ignoreContentAdaptWithSize(false):setContentSize(cc.size(40, 40)):move(0.5, -1)
    self.chipNum = cc.Label:createWithTTF(value, "fonts/Marker Felt.ttf", fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER):move(0, -1)

    self.chipView:setTouchEnabled(true)
        :addTouchEventListener(function(sender, eventType)
            if eventType == 0 then
                self:setScale(0.9)
            elseif eventType == 2 then
                self:setScale(1)
                self:setLight(true)
                if self.clickListener then
                    self.clickListener()
                end
            elseif eventType == 3 then
                self:setScale(1)
            end
        end)
    
    self:addChild(self.chipLight)
    self:addChild(self.chipView)
    self:addChild(self.chipNum)
end

--[[
    @function getContentSize   获取内容大小
    @return size_table#size_table ret (return value: size_table)
]] 
function Chip:getContentSize()
    return self.chipView:getContentSize()
end

--[[
    @function setLight   设置是否点亮
]] 
function Chip:setLight(visible)
    if self.chipLight then
        self.chipLight:setVisible(visible)
    end
end

--[[
    @function addClickListener   添加点击事件
    @param #callback function       回调方法
]] 
function Chip:addClickListener(callback)
    self.clickListener = callback
end

return Chip