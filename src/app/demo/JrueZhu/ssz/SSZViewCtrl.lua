--[[--ldoc desc
@module SSZViewCtrl
@author JrueZhu

Date   2018-10-31 09:32:19
Last Modified by   JrueZhu
Last Modified time 2018-10-31 13:01:46
]]


local appPath = "app.demo.JrueZhu"
local SSZViewCtrl = class("SSZViewCtrl",cc.load("boyaa").mvc.BoyaaCtr);
local SSZView = require(appPath..".ssz.SSZView");

local Bit = require("app.demo.JrueZhu.Bit");


local CARD_NUM = 13;

function SSZViewCtrl:ctor( ... )
	-- self:registerEventListener();

	local sszView = SSZView:create();
	sszView:bindCtr(self);
	-- 初始化数据
	self:initConfig();
end

function SSZViewCtrl:initConfig()
	-- 记录牌的数据表
	self.cardList = {};
	-- 点击选中的牌
	self.selectedCard = nil;
	-- 每行有效的数据表
	self.validCardList = {}
end

local function getRandomCardType() 
  return math.random(0, 3);
end

local function getRandomCardValue(existType)
    if existType >= 0 and existType < 4 then
        return math.random(1, 13);
    end
    return math.random(1, 2);
end

local function getRandomCardByte()
    local cardType = getRandomCardType();
    local cardValue = getRandomCardValue(cardType);
    return Bit:toByte(cardType, cardValue);
end

function SSZViewCtrl:createRandomCards()
	for i = 1, CARD_NUM do
		local cardByte = getRandomCardByte();
		table.insert(self.cardList, cardByte);
	end
	self:getView():createCards(self.cardList);
end

return SSZViewCtrl;