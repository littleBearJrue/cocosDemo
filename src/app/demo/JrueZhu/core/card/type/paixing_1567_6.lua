-- @Author: JanzenWang
-- @Date:   2018-08-17 16:23:18
-- @Last Modified by:   JanzenWang
-- @Last Modified time: 2018-08-23 15:39:09
local TongZhang = import("..base.TongZhang")
local CardBase = import("..base.CardBase")
local M = class(TongZhang)

-- 牌型：对子
-- 特征：牌点相同的两张牌，不区分花色

function M:ctor(data,ruleDao)
	TongZhang.init(self,{2,2})
	local args = data.typeRule.args
	self.maxPokerValue = Card.ValueMap:rget(tostring(args[2]))
end


function M:compare(data)
	self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
	self:sort({cardInfo = data.targetCardInfo, ruleDao = data.ruleDao})
	local outCardList = data.outCardInfo.cardList
	local targetCardList = data.targetCardInfo.cardList

	if #outCardList == #targetCardList then 

		if self.byteToSize[data.outCardInfo.cardByte] - self.byteToSize[data.targetCardInfo.cardByte] == 1 then
			return true
		end
		local card1Value = Card.getCardAttrFromByte(data.outCardInfo.cardByte)
		local card2Value = Card.getCardAttrFromByte(data.targetCardInfo.cardByte)
		if card1Value == self.maxPokerValue and  card2Value ~= self.maxPokerValue then
			return true
		end
	end
	return false
end



function M:find(data)
	--查找原牌
	local args = self._args
	local laiziList = {}
	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	local queue = data.queue and data.queue or 0
	local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local outCardStack = new(CardStack,{cards = outCardList})
	local invalidCardStack = new(CardStack,{cards = invalidCardList})
	local targetLength = length or args[1]
	local returnList = {}
	local map = outCardStack:getValueMap()

	local temp = clone(map)
	local newMap = {}
	for i,cards in pairs(temp) do 
		if type(i) == "number" then 
			table.sort(cards,function (a,b)
				return self.byteToSize[a.byte] > self.byteToSize[b.byte]
			end)
			table.insert(newMap,cards)
		end
	end
	
	table.sort(newMap,function (a,b)
		return self.byteToSize[a[1].byte] < self.byteToSize[b[1].byte] 
	end)
	map = newMap


	--对map中的元素排序，优先使用非癞子牌
	if self.enableLaiZi == 1 then 
		for i,item in pairs(map) do 
			for _,card in ipairs(item) do 
				table.sort(item,function (a,b)
					return a.flag < b.flag
				end)
			end
		end
	end
	
	local laiziList = CardUtils.getLaiZiList(data.ruleDao,invalidCardList) --只可做癞子牌的癞子
	local exLaiZiList = CardUtils.getLaiZiList(data.ruleDao,outCardList) 	--可以做原生牌或者癞子牌的癞子
	if self.enableLaiZi ~= 1 then 
		if length then
			if length < args[1] or length > args[2] then
				-- Log.v("TongZhang args[1]", args[1], "args[2]", args[2], "length", length)
				return
			end 
		end

		if length and #outCardList < length then
			return 
		end

		if #outCardList < args[1] then
			return 
		end
	end

	local max = -1
	for i,v in pairs(map) do 
		if i>=max then 
			max = i
		end
	end
	local endi = queue == 0 and 1 or max
	local step = queue == 0 and -1 or 1

	--不用癞子的牌型直接走这里
	if self.enableLaiZi ~=1 then 
		for i = queue == 0 and max or 1,endi,step do
			if map[i] and #map[i]~=0 then
				local isBigger = false
				if cardByte then
					local targetByte = cardByte
					local tryByte = map[i][1].byte

					if self.byteToSize[tryByte] - self.byteToSize[targetByte] == 1 then
						isBigger =  true
					end
					local card1Value = Card.getCardAttrFromByte(tryByte)
					local card2Value = Card.getCardAttrFromByte(targetByte)
					if card1Value == self.maxPokerValue and  card2Value ~= self.maxPokerValue then
						isBigger = true
					end
				else
					isBigger = true
				end
				if #map[i] >= targetLength and isBigger then
					for j = 1,targetLength,1 do 
					    table.insert(returnList,map[i][j])
					end
					break
				end
			end
		end
	end

	--再去找补癞子的牌型
	if #returnList ==0 and self.enableLaiZi == 1 then
		for i = queue == 0 and max or 1,endi,step do
			if map[i] and #map[i]~=0 then
				local isBigger = false
				if cardByte then
					local targetByte = cardByte
					local tryByte = map[i][1].byte
					if self.byteToSize[tryByte] - self.byteToSize[targetByte] == 1 then
						isBigger =  true
					end
					local card1Value = Card.getCardAttrFromByte(tryByte)
					local card2Value = Card.getCardAttrFromByte(targetByte)
					if card1Value == self.maxPokerValue and  card2Value ~= self.maxPokerValue then
						isBigger = true
					end
				else
					isBigger = true
				end
				if #map[i] >= targetLength and isBigger then 
					for j = 1,targetLength,1 do 
					    table.insert(returnList,map[i][j])
					end
					break
				elseif #map[i] + #laiziList >= targetLength and isBigger  then
					if CardUtils.isTargetLaizi(data.ruleDao,laiziList[1],map[i][1]) then 
						local dValue = targetLength - #map[i]
						for j = 1,#map[i] do 
							table.insert(returnList,map[i][j])
						end
						for j =1,dValue do 
							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],map[i][1]))
						end
						break
					end
				elseif (#map[i] + #laiziList + #exLaiZiList)>= targetLength and isBigger then
					if (not table.keyof(exLaiZiList,map[i][1])) or #exLaiZiList ~= #map[i]  then  ---确保该组的癞子牌没有重复使用
						local tmpExLaiZiList = {}
   						table.copyTo(tmpExLaiZiList, exLaiZiList)
						for j = #tmpExLaiZiList,1,-1 do 
							if tmpExLaiZiList[j] == map[i][1] then 
								table.remove(tmpExLaiZiList,j)
							end
						end
						local isCanInstead = false
						if laiziList[1] then 
							isCanInstead = CardUtils.isTargetLaizi(data.ruleDao,laiziList[1],map[i][1]) 
						end
						if tmpExLaiZiList[1] then 
							isCanInstead = CardUtils.isTargetLaizi(data.ruleDao,tmpExLaiZiList[1],map[i][1]) 
						end
						if isCanInstead then 
							local dValue = targetLength - #map[i] -#laiziList
							--插入原生组的牌
							for j = 1,#map[i] do 
								table.insert(returnList,map[i][j])
							end
							--插入只能当癞子组的牌
							for j,card in ipairs(laiziList) do 
								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,card,map[i][1]))
							end

							--插入即可当癞子也可当原生牌的牌
							for j = 1,dValue do
								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,tmpExLaiZiList[j],map[i][1]))
							end
							break
						end
					end
				end
			end
		end
	end

	if #returnList ~= 0 and #returnList == args[1] then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		} 

	end
end



return M;