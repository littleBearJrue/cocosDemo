--[[--ldoc desc
@module paixing_1567_2
@author WahidZhang

Date   2018-01-09 19:34:39
Last Modified by   KevinZhang
Last Modified time 2018-03-22 16:10:50
]]

-- local CardBase = import("..base.CardBase")
local TongZhang = import("..base.TongZhang")
local M = class(TongZhang)

-- 牌型：对子(同花色)
-- 特征：牌点相同，并且花色相同的两张牌

function M:ctor(data,ruleDao)
	local args = {2,2}
	TongZhang.init(self,args)
end

function M:check(data)
	local cardList = data.outCardInfo.cardList
	if #cardList == 2 then
		if cardList[1].color == cardList[2].color then
			return TongZhang.check(self, data)
		end
	end
	return false
end

function M:compare(...)
	return TongZhang.compare(self, ...)
end

function M:find(data)
	local sortData = {cardInfo = {}, ruleDao = data.ruleDao}
	sortData.cardInfo.cardList = data.srcCardStack:getCardList()
	self:sort(sortData)
	local copyCardList = {}
	table.copyTo(copyCardList, sortData.cardInfo.cardList)
	data.queue = data.queue or 0
	if data.queue == 0 then
		for i=1,#copyCardList/2 do
			copyCardList[i], copyCardList[#copyCardList - i + 1] = copyCardList[#copyCardList - i + 1], copyCardList[i]
		end
	end
	-- Log.v(copyCardList, #copyCardList)
	local cardList = {}
	local _cardList = {}
	while true and #copyCardList > 0 do
		cardList = {}
		local color = copyCardList[#copyCardList].color
		for i = #copyCardList, 1, -1 do
			local card = copyCardList[i]
			if card.color == color then
				table.insert(cardList, card)
				table.remove(copyCardList, i)
			else
				break
			end
		end
		local findData = {}
		for k,info in pairs(data) do
			findData[k] = info
		end
		findData.srcCardStack = new(CardStack, {cards = cardList})
		local result, otherData = TongZhang.find(self, findData)
		if result then
			return result
		else
			table.copyTo(_cardList, cardList)
			if #copyCardList == 0 then
				return
			end
		end
	end
end

return M;	