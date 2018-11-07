--[[--ldoc desc
@module paixing_1699_1
@author WahidZhang

Date   2018-01-09 19:36:47
Last Modified by   KevinZhang
Last Modified time 2018-03-08 17:44:52
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

function M:ctor(data, ruleDao)
	self.minNum = 4
end

-- 牌型特征：牌点相同的牌，并且黑红梅方各有一张
-- 牌型：雷
-- 出处：淄博升级
function M:check(data)
	local cardList = data.outCardInfo.cardList
	if not cardList or #cardList ~= 4 then
		return false
	end
	local colors = {}
	local cardValue = cardList[1].value
	for i,card in pairs(cardList) do
		if not colors[card.color] and cardValue == card.value then
			colors[card.color] = true
		else
			return false
		end
	end
	data.outCardInfo.cardByte = cardList[1].byte
	return true
end

function M:compare(data)
	return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte]
end

function M:find(data)
	local sortData = {cardInfo = {cardList = data.srcCardStack:getCardList()},ruleDao = data.ruleDao}
    self:sort(sortData)
	local minSize = 0
	if data.targetCardInfo and data.targetCardInfo.cardByte then
		minSize = self.byteToSize[data.targetCardInfo.cardByte]
	end
	local cardList = {}
	table.copyTo(cardList, sortData.cardInfo.cardList)
	if data.queue == 1 then
		-- 如果是从小往大找，就翻个顺序，方便后面统一从前往后找
		for i=1,#cardList/2 do
			cardList[i], cardList[#cardList - i + 1] = cardList[#cardList - i + 1], cardList[i]
		end
	end
	local cardStack = new(CardStack, {cards=cardList})

	local i = 1
	local findCardList = {}
	while i <= #cardList-3 do
		local byte = cardList[i].byte
		local valueList = cardStack:getCardsByValue(cardList[i].value)
		if self.byteToSize[byte] > minSize then
			if #valueList >= 4 then
				local colors = {}
				for i,card in ipairs(valueList) do
					if not colors[card.color] then
						colors[card.color] = true
						table.insert(findCardList, card)
					end
				end
				if #findCardList == 4 then
					return {	
							cardList = findCardList,
							cardByte = findCardList[1].byte,
							cardType = self.uniqueId
							}
				else
					findCardList = {}
				end
			end
		end
		-- 不加 valueList 长度,防止有相同牌点，但是牌大小不连续的情况
		i = i + 1
	end
end

return M;
