--[[--ldoc desc
@module paixing_1576_4
@author LucasZhen

Date   2018-01-09 19:35:02
Last Modified by   LucasZhen
Last Modified time 2018-05-25 15:17:30
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
	n 张 YY牌 牌只能填大王或者小王  填大王/小王表示大王小王都可，只要满足数量即可
	特殊说明：如果配了可以使用癞子，不可以全部使用癞子牌，必须要有一张原生牌
]]

function M:ctor(data,ruleDao)
	local args = data.typeRule.args
	self.nums = args[1]
	local str = args[2]
	local cardNameList = string.split(str,'/')
	self.cardByteList = {}
	self.cardList = {}
	for i,v in ipairs(cardNameList) do
		self.cardByteList[i] = Card.ByteMap:rget(v)
		self.cardList[i] = Card.new(Card.ByteMap:rget(v))
	end
	-- self.orgNums = args[3]
	-- self.orgByteList = {Card.ByteMap:rget("大王"),Card.ByteMap:rget("小王")}
end

local function _getCanInsteadList(laiZiList,cardList,ruleDao)
	local canInsteadList = {}
	if #laiZiList > 0 then
		--去判断癞子牌是否可替代指定牌
		for _,laiZiCard in ipairs(laiZiList) do 
			for _,card in ipairs(cardList) do 
				if CardUtils.isTargetLaizi(ruleDao,laiZiCard,card) then
					table.insert(canInsteadList,laiZiCard) 
					break
				end
			end
		end
	end
	return canInsteadList

end


function M:check(data)
	local outCardList,invalidCardList = self:getValidCard(data.outCardInfo.cardList)
	--将outCardList降序排序
	-- table.sort( outCardList,function(a,b)
	-- 	return a.value > b.value
	-- end )

	--如果没有一张原生牌，则直接返回
	if #outCardList == 0 then 
		return false
	end


	if self.enableLaiZi ~= 1 then
		if #invalidCardList > 0 then 
			return false
		end
	    --不可以使用癞子时，只需判断outCardList中的牌是否是指定牌即可 
		if #outCardList ~= self.nums then 
			return false
		end
		-- local orgNums = 0
		for i,card in ipairs(outCardList) do
			local normalByte = Card.getNormalByte(card)
			if not table.keyof(self.cardByteList, normalByte) then 
				return false
			end
		end
	else
		--使用癞子时，需考虑到invalidCardList中的牌是否可替代指定牌
		if #outCardList + #invalidCardList < self.nums then 
			return false
		end

		local laiZiList = {}
		for i,card in ipairs(invalidCardList) do 
			if not CardUtils.isLaizi(data.ruleDao,card) then 
				return false
			else 
				table.insert(laiZiList,card)
			end
		end
		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if not table.keyof(self.cardByteList, normalByte) then 
				return false
			end
		end

		if #laiZiList ~= 0 then
			local canInsteadList = _getCanInsteadList(laiZiList,self.cardList,data.ruleDao)
			if not #canInsteadList == #laiZiList then 
				return false
			end
		end
	end
	data.outCardInfo.size = self.sortRule.args
	data.outCardInfo.byteToSize = self.byteToSize	
	data.outCardInfo.cardByte = outCardList[1].byte;
	return true;
end

function M:compare(data)
	--同牌型无需比较
end

function M:find(data)
	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	local invalidCardStack = new(CardStack,{cards = invalidCardList})
	local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local targetLength = self.nums
	local returnList = {}
	local laiZiList = CardUtils.getLaiZiList(data.ruleDao,invalidCardList) --此牌型是针对于王炸，暂时不考虑癞子牌做为原生牌去替换的情况


	--如果没有一张原生牌，则直接返回
	if #outCardList == 0 then 
		return false
	end

	if self.enableLaiZi ~= 1 then
		--不带癞子的情况，直接找指定牌即可
		if #outCardList < targetLength then
			return
		end
		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if table.keyof(self.cardByteList, normalByte) then 
				table.insert(returnList,card)
				if #returnList == targetLength then 
					break
				end 
			end
		end
		if #returnList ~= targetLength then
			return
		end
	else
		--带癞子的情况，需要处理癞子是否能够替代指定牌
		if #outCardList + #invalidCardList < targetLength then 
			return
		end

		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if table.keyof(self.cardByteList, normalByte) then 
				table.insert(returnList,card)
				if #returnList == targetLength then 
					break
				end
			end
		end

		if #returnList>0 and #returnList < targetLength then 
			local dValue = targetLength-#returnList 
			local canInsteadList = _getCanInsteadList(laiZiList,self.cardList,data.ruleDao)
			if #canInsteadList < dValue then 
				return
			end
			for i = 1,#canInsteadList,1 do 
				table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,canInsteadList[i],returnList[1]))
				if #returnList == targetLength then 
					break
				end
			end
		end
	end

	if cardByte and data.targetCardInfo.cardList then 
		if #returnList <=  #data.targetCardInfo.cardList then 
			return 
		end
	end

	if #returnList ~= 0 and #returnList>= targetLength then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		}
	end
end

return M;
