--[[--ldoc desc
@module paixing_1699_2
@author WahidZhang

Date   2018-01-09 19:37:13
Last Modified by   KevinZhang
Last Modified time 2018-03-08 17:45:31
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

function M:ctor(data, ruleDao)
	self.minNum = 5
	self.offset = 1
end

-- 牌型特征：牌点相同的牌，并且黑红梅方各有至少一张，其中任意一个牌需要有两张(最少5张牌)
-- 牌型：闪
-- 出处：淄博升级
function M:check(data)
	local cardList = data.outCardInfo.cardList
	if not cardList or #cardList < 5 then
		return false
	end
	local colors = {[0] = false, [1] = false, [2] = false, [3] = false}
	local cardValue = cardList[1].value
	for i,card in pairs(cardList) do
		if cardValue ~= card.value then
			return false
		end
		if not colors[card.color] then
			colors[card.color] = true
		end
	end
	for k,v in pairs(colors) do
		if v == false then
			return false
		end
	end
	data.outCardInfo.cardByte = cardList[1].byte
	return true
end

function M:compare(data)
	if #data.outCardInfo.cardList ~= #data.targetCardInfo.cardList then
		return false
	end
	return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte]
end


function M:find(data)
	local sortData = {cardInfo = {cardList = data.srcCardStack:getCardList()},ruleDao = data.ruleDao}
    self:sort(sortData)
	local minSize = 0
	local length = data.targetCardInfo and #data.targetCardInfo.cardList or 0
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
	while i <= #cardList do
		local byte = cardList[i].byte
		local valueList = cardStack:getCardsByValue(cardList[i].value)
		if self.byteToSize[byte] > minSize then
			if #valueList >= 5 and #valueList >= length then
				local colorInfo = {cardList = {}, map = {}}
				local otherColorCard = {}
				for i,card in ipairs(valueList) do
					if not colorInfo.map[card.color] then
						colorInfo.map[card.color] = true
						table.insert(colorInfo.cardList, card)
					else
						table.insert(otherColorCard, card)
					end
				end
				if #colorInfo.cardList == 4 then
					if length == 0 then
						findCardList = valueList
					else
						findCardList = colorInfo.cardList
						-- 这里可以优化，优先不使用主花色的牌
						for i=1,length - 4 do
							table.insert(findCardList, otherColorCard[i])
						end
					end
					return {
								cardList = findCardList,
								cardByte = findCardList[1].byte,
								cardType = self.uniqueId
							}
				end
			end
		end
		i = i + 1
	end
end

return M;
