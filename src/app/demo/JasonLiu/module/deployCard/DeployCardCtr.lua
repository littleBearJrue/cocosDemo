--[[--ldoc desc
@Module DeployCardCtr.lua
@Author JasonLiu

Date: 2018-10-30 10:54:57
Last Modified by: JasonLiu
Last Modified time: 2018-10-31 16:07:23
]]

local DeployCardCtr = class("DeployCardCtr", cc.load("boyaa").mvc.BoyaaCtr);
local DeployCardView = require("app.demo.JasonLiu.module.deployCard.DeployCardView")
local PaiXingUtils = require("app.demo.JasonLiu.utils.PaiXingUtils")

function DeployCardCtr:ctor()
    self:initDate()
    self:initView()
end

--[[
    @function initDate      初始化数据
]] 
function DeployCardCtr:initDate()
    self.data = {
        card = {{0x2a,0x2b,0x1}, {0x06,0x06,0x06,0x29,0x35}, {9,0xa,0xb,0xc,0xd}}
    }
end

--[[
    @function initView      初始化View
]] 
function DeployCardCtr:initView()
	local DeployCardView = DeployCardView:create(self.data);
    DeployCardView:bindCtr(self);

    self:checkPaiXing()
end

--[[
    @function updateCardsData      更新牌的数据
]] 
function DeployCardCtr:updateCardsData()
    local changeFlags = {}
    for i, item in ipairs(self:getView():getCardsByteData()) do
        for j, v in ipairs(item) do
            if self.data.card[i][j] ~= v then
                changeFlags[i] = true
            end
        end
    end
    self.data.card = self:getView():getCardsByteData()

    self:checkPaiXing(changeFlags)
end

--[[
    @function checkPaiXing      检查牌型
]] 
function DeployCardCtr:checkPaiXing(changeFlags)
    --检查牌型
    local checkFlags = {}
    for i, v in ipairs(self.data.card) do
        local cards = {}
        for i, v in ipairs(v) do
            table.insert(cards, v)
        end
        local paixing, cards, weight = PaiXingUtils.check(cards)
        table.insert(checkFlags, weight)

        self:getView():updatePaiXing(i, paixing, cards)
        if weight >= 5 and changeFlags and changeFlags[i] then
            self:getView():runCardsShineAction(i, cards)
        end
    end
    --检查牌型顺序
    for i, v in ipairs(checkFlags) do
        local flag = false
        if i < #checkFlags then
            if v <= checkFlags[i + 1] then
                flag = true
            end
        else
            if v >= checkFlags[i - 1] then
                flag = true
            end
        end

        self:getView():updateCheck(i, flag)
    end
end

return DeployCardCtr;