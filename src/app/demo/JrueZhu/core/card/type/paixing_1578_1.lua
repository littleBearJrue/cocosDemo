-- @Author: EricHuang
-- @Date:   2017-11-24 14:36:21
-- @Last Modified by   KevinZhang
-- @Last Modified time 2018-03-08 17:41:31
-- 具体牌组合的牌型
-- eg: 双红十， args = { "方块十、红桃十", "1" }

local CardBase = import("..base.CardBase")
local M = class(CardBase)

function M:ctor(data, ruleDao)
	self.m_byteNum = {};
	self.m_totalNum = 0;
	local number = tonumber(data.typeRule.args[2]);
	for i,v in ipairs(string.split(data.typeRule.args[1], '、')) do
		local byte = Card.ByteMap:getKeyByValue(v);
		self.m_byteNum[byte] = number;
		self.m_totalNum = self.m_totalNum + number;
	end
end

--[[检查是否符合牌型   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	outCardInfo	{
		cardList = {card1, card2, ...}
	}

	-- 校验牌型之后，要对原始数据outCardInfo操作，添加两个元素进去，size = self.sortRule.args,  byteToSize = self.byteToSize
	return 校验结果(true or false), cardByte用于判断大小的牌
]]
function M:check(data)
	local cardList = data.outCardInfo.cardList;
	if #cardList ~= self.m_totalNum then
		return;
	end

	local count = {};
	for i,v in ipairs(cardList) do
		local normalByte = Card.getNormalByte(v)
		if Card.isTribute(v) then normalByte = Card.getTributeOrigByte(v.byte) end 
		if not self.m_byteNum[normalByte] then
			return false;
		end
		count[normalByte] = (count[normalByte] or 0) + 1
		if count[normalByte] > self.m_byteNum[normalByte] then
			return false;
		end
	end

	data.outCardInfo.cardByte = cardList[1].byte;
	return true;
end

--[[牌型比较   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	outCardInfo	{
		cardList = {card1, card2, ...},
		cardByte = byte,
	}
	targetCardInfo	{
		cardList = {card1, card2, ...},
		cardByte = byte,
	}

	return true or false
]]
function M:compare(data)
	-- 没有相同牌型可以压，牌型的唯一组合
	return false
end

--[[查找符合牌型的手牌，以及移除掉手牌后剩下的牌   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	srcCardInfo = {
		cardList = {card1, card2, ...},
		size = {}, 		同 self.sortRule.args
		byteToSize = {},同 self.byteToSize
	},
	cardByte,	-- 从比这个牌更大的牌开始找
	length,		-- 最小长度要求

	
	return 	{
				cardList = {},
				cardByte = byte,
				cardType = self.uniqueId,
			}, 	{
					cardList = {},
					size = {},
					byteToSize = {},
				}
]]
function M:find(data)
	if data.targetCardInfo and data.targetCardInfo.cardByte then
		return
	end

	if #data.srcCardStack:getCardList() < self.m_totalNum then
		return;
	end

	local cardStack = data.srcCardStack
	local cards = {};
	local srcCardList = cardStack:getCardList()
	for byte,count in pairs(self.m_byteNum) do
		local cnt = 0
		local result = {}
		for _,card in pairs(srcCardList) do
			local normalByte = Card.getNormalByte(card)
			if Card.isTribute(card) then normalByte = Card.getTributeOrigByte(card.byte) end
			if normalByte == byte then
				cnt = cnt + 1
				if cnt <= count then
					table.insert(result, card)
				end
			end
		end
		if cnt < count then
			return
		end
		table.copyTo(cards, result)
	end

	local findCards = {
		cardList = cards,
		cardByte = cards[1].byte,
		cardType = self.uniqueId,
	};

	return findCards
end


return M