--[[--ldoc desc
@module paixing_1574_6
@author WahidZhang

Date   2018-04-18 18:27:40
Last Modified by   CelineJiang
Last Modified time 2018-08-06 15:32:20
]]
local TongZhang = import("..base.TongZhang");
local M = class(TongZhang);

M.description = [[
功能描述说明：
	牌型：一个参数的同张牌型，根据参数决定是几同张
	特征：牌点相同的N张牌，区分花色,花色指黑红梅方
]]
function M:ctor(data,ruleDao)
	local args = table.copyTab(data.typeRule.args);
	args[2] = args[1];
	self.args = args;
	TongZhang.init(self,args);
end

function M:check(data)
	local cardList = data.outCardInfo.cardList
	if #cardList == self.args[1] then
		-- if cardList[1].color == cardList[2].color and cardList[2].color == cardList[3].color then
		-- 	return TongZhang.check(self, data)
		-- end
		local color = cardList[1].color
		local isSameColor = true
		for i = 2, self.args[1] do
			if cardList[i].color ~= color then
				isSameColor = false
				break 
			end
		end
		if isSameColor then
			return TongZhang.check(self,data)
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