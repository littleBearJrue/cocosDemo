--[[--ldoc desc
@module paixing_1576_3
@author LucasZhen

Date   2018-01-09 19:35:02
Last Modified by   LucasZhen
Last Modified time 2018-04-16 21:17:01
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
	牌型 n张及以上的XX/XX牌型,至少包含Y张原生的王
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
	self.orgNums = args[3]
	self.orgByteList = {Card.ByteMap:rget("大王"),Card.ByteMap:rget("小王")}
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
	table.sort( outCardList,function(a,b)
		return a.value > b.value
	end )
	if self.enableLaiZi ~= 1 then
	    --不可以使用癞子时，只需判断outCardList中的牌是否是指定牌以及包含原生牌的数量即可 
		if #outCardList ~= #data.outCardInfo.cardList then 
			return false
		end
		local orgNums = 0
		for i,card in ipairs(outCardList) do
			local normalByte = Card.getNormalByte(card)
			if not table.keyof(self.cardByteList, normalByte) then 
				return false
			end
			if table.keyof(self.orgByteList, normalByte) then 
				orgNums = orgNums+1
			end
		end
		if orgNums < self.orgNums then 
			return false
		end
	else
		--使用癞子时，需考虑到invalidCardList中的牌是否可替代指定牌
		if #outCardList + #invalidCardList ~= #data.outCardInfo.cardList then 
			return false
		end
		local orgNums = 0
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
			if table.keyof(self.orgByteList, normalByte) then 
				orgNums = orgNums+1
			end
		end
		if orgNums < self.orgNums then 
			return false
		end
		if #laiZiList ~= 0 then
			local canInsteadList = _getCanInsteadList(laiZiList,self.cardList,data.ruleDao)
			if not #canInsteadList == #laiZiList then 
				return false
			end
		end
	end	
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
	local minLength = self.nums
	local returnList = {}
	local laiZiList = CardUtils.getLaiZiList(data.ruleDao,invalidCardList) --此牌型是针对于王炸，暂时不考虑癞子牌做为原生牌去替换的情况

	--若传入同牌型的target进来，同牌型无法比较大小，直接返回false
	-- if cardByte then 
	-- 	return false
	-- end
	if self.enableLaiZi ~= 1 then
		--不带癞子的情况，直接找指定牌即可
		if #outCardList < minLength then
			return
		end
		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if table.keyof(self.cardByteList, normalByte) then 
				table.insert(returnList,card)
			end
		end
		if #returnList < minLength then
			return
		end
	else
		--带癞子的情况，需要处理癞子是否能够替代指定牌
		if #outCardList + #invalidCardList < minLength then 
			return
		end
		local orgNums = 0

		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if table.keyof(self.cardByteList, normalByte) then 
				table.insert(returnList,card)
				if table.keyof(self.orgByteList, normalByte) then 
					orgNums = orgNums+1
				end
			end
		end
		if orgNums < self.orgNums then 
			return
		end
		if #returnList>0 and #returnList < minLength then 
			local dValue = minLength-#returnList 
			local canInsteadList = _getCanInsteadList(laiZiList,self.cardList,data.ruleDao)
			if #canInsteadList < dValue then 
				return
			end
			for i = 1,#canInsteadList,1 do 
				table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,canInsteadList[i],returnList[1]))
			end
		end
	end

	if cardByte and data.targetCardInfo.cardList then 
		if #returnList <=  #data.targetCardInfo.cardList then 
			return 
		end
	end

	if #returnList ~= 0 and #returnList>= minLength then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		}
	end
end

return M;
