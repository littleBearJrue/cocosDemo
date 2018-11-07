--[[--ldoc desc
@Module BetView.lua
@Author JasonLiu

Date: 2018-10-24 19:13:25
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 14:41:11
]]

local BetView = class("BetView", cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

local Chip = require("app.demo.JasonLiu.widget.Chip2")
local Table = require("app.demo.JasonLiu.widget.Table")
local Clock = require("app.demo.JasonLiu.widget.Clock")

BehaviorExtend(BetView);

function BetView:ctor(data)
    self:initData(data)
    self:initView()
end

function BetView:initData(data)
    self._data = {
        selectValue = 1,
        chipData = data.chipData or {},
        betEnabled = false,
    }
    self.chipViews = {}
    self.betTipss = {}
    self.smallChipData = {}
end

--[[
    @function initView      初始化View
]] 
function BetView:initView()
    self:addTable()
    self:addChips()
    self:addBetTipss()
    self:addClock()
end

--[[
    @function addTable      添加桌子
]] 
function BetView:addTable()
    local tableOffSetX, tableOffSetY = 0, 20
    self.table = Table:create():move(tableOffSetX, tableOffSetY)
    self.table:addClickListener(function (no)
        if self._data.betEnabled then
            -- 添加一个小筹码
            self:addSmallChip(no, tableOffSetX, tableOffSetY)
            -- 更新下注提示
            self:updataBetTips(no)
        end
    end)
    self:addChild(self.table)
end

--[[
    @function addChips      添加筹码
]] 
function BetView:addChips()
    for i, data in ipairs(self._data.chipData) do
        self.chipViews[i] = Chip:create(0, data.color, data.value)
        local marginSize = 12
        local chipWidth = self.chipViews[i]:getContentSize().width
        self.chipViews[i]:move(-((chipWidth *  #self._data.chipData + marginSize * (#self._data.chipData - 1)) / 2) + (chipWidth + marginSize) * (i - 1) + chipWidth / 2, -(self.table:getContentSize().height / 2 + marginSize))
        self.chipViews[i]:addClickListener(function ()
            self:updataChipsState(i)
        end)

        self:addChild(self.chipViews[i])
    end
    
    self:updataChipsState(self._data.selectValue)
end

--[[
    @function addBetTipss      添加下注提示
]] 
function BetView:addBetTipss()
    for i, v in ipairs(self.table.areas) do
        self.betTipss[i] = cc.Node:create():setLocalZOrder(999999):setVisible(false)
        self.betTipss[i]:move(cc.p(v:getPosition()).x + v:getContentSize().width / 2, cc.p(v:getPosition()).y - v:getContentSize().height / 2 + 20)
        cc.Sprite:create("Images/koprokdice/dice_room_self_bet_money_bg.png"):setContentSize(cc.size(20, 8)):setName("bg"):addTo(self.betTipss[i])
        cc.Label:createWithTTF("0K", "fonts/HKYuanMini.ttf", 7, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER):setName("label"):setColor(cc.c3b(255,140,0)):addTo(self.betTipss[i])
        self:addChild(self.betTipss[i])
    end
end

--[[
    @function addSmallChip      添加一个小筹码
]] 
function BetView:addSmallChip(index, offSetX, offSetY)
    local chip = Chip:create(1, self.chipViews[self._data.selectValue]._data.color):move(self.chipViews[self._data.selectValue]:getPosition())
    local rx, ry = self.table:getRandomAreaPos(index, chip:getContentSize().width / 2)
    local point = cc.p(self.table.areas[index]:getPosition())
    chip:runAction(cc.MoveTo:create(self.table:getAreaMoveTime(index), cc.p(point.x + rx + offSetX, point.y - ry + offSetY)))
    table.insert(self.smallChipData, {chip = chip, areaNo = index})
    self:addChild(chip)
end

--[[
    @function addClock      添加时钟
]] 
function BetView:addClock()
    self.clock = Clock:create():move(0, 88)
    self.clock:setScale(self.table:getContentSize().width * 0.2 / self.clock:getContentSize().width)
    self.clock:setVisible(false)
    self:addChild(self.clock)
end

--[[
    @function updataChipsState      更新筹码选中状态
]] 
function BetView:updataChipsState(index)
    self._data.selectValue = index
    for i, v in ipairs(self.chipViews) do
        if i ~= index then
            v:setLight(false)
        else
            v:setLight(true)
        end
    end
end

--[[
    @function updataBetTips      更新下注提示
]] 
function BetView:updataBetTips(index)
    self.betTipss[index]:setVisible(true)
    local label = self.betTipss[index]:getChildByName("label")
    local chipValue = self.chipViews[self._data.selectValue]._data.value
    local oldValue = label:getString()
    local sum = tonumber(string.sub(oldValue, 1, string.len(oldValue) - 1)) + tonumber(string.sub(chipValue, 1, string.len(chipValue) - 1))
    label:setString(sum .. string.sub(oldValue, string.len(oldValue), string.len(oldValue)))
end

--[[
    @function startCountdown      开始倒计时
]] 
function BetView:startCountdown(time, callback)
    self.clock:setVisible(true)
    self.clock:countdown(function ()
        self.clock:setVisible(false)
        callback()
    end, time, true)
end

--[[
    @function setBetEnabled      设置是否能够下注
]] 
function BetView:setBetEnabled(enabled)
    self._data.betEnabled = enabled
end

--[[
    @function updateWinningState   更新中奖状态
    @param #data table          中奖数据
]] 
function BetView:updateWinningState(data)
    self.table:updateTableWinningArea(data)
end

--[[
    @function clearSmallChip   清除小筹码
]] 
function BetView:clearSmallChip()
    for i, v in ipairs(self.smallChipData) do
        self:removeChild(v.chip)
    end
    self.smallChipData = {}
end

--[[
    @function resetBetTipss   重置下注提示
]] 
function BetView:resetBetTipss()
    for i, v in pairs(self.betTipss) do
        v:getChildByName("label"):setString("0K")
        v:setVisible(false)
    end
end

return BetView;