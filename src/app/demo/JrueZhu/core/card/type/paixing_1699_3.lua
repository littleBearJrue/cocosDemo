--[[--ldoc desc
@module paixing_1699_3
@author WahidZhang

Date   2018-01-09 19:37:47
Last Modified by   KevinZhang
Last Modified time 2018-05-03 20:18:56
]]
--[[
下雪：5张及以上牌点相连的顺子+至少1张顺子用牌同牌点同花色的牌。
不能所有牌都是对子；
主/副牌不能混在一起
]]
local CardBase = import("..base.CardBase")
local M = class(CardBase)

function M:ctor(data, ruleDao)
	self:init()
end

function M:init()

	local function  dealLineArgStr(str)
		if not str then 
			return
		end
		local lineMap = {}
		local strArr = string.split(str,"/")
		for _, str1 in ipairs(strArr) do 
			local temp = {}
			local arr = string.split(str1, ">") 
			for i=1, #arr do 
				table.insert(temp, 1, arr[i])
			end
			table.insert(lineMap, 1, temp)
		end
		return lineMap
	end

	local lineMap = {
		{"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"},
		{"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q"},
	}
	self.lineMap = lineMap

	self.sameCount =  1 
	self.minLength =  5 
	self.minNum = 6
	self.offset = self.sameCount
end

--转换成对应的牌值
local function getCardByteFromAttr(valueStr, color)
	local byte
	if string.find(valueStr, "%a") == 1 or string.find(valueStr, "%d") == 1 then 
		byte = CardUtils.getCardByteFromAttr(Card.ValueMap:getKeyByValue(valueStr), color)
	else
		byte = Card.ByteMap:getKeyByValue(valueStr)
	end
	return byte
end

--分离主副牌
local function separateMainCards(ruleDao, cardList)
	local mainCards = {}
	local otherCards = {}
	for _, card in pairs(cardList) do 
		if ruleDao:isMainCard(card) then 
			table.insert(mainCards, card)
		else
			table.insert(otherCards, card)
		end
	end
	-- Log.e(mainCards, otherCards)
	return mainCards, otherCards
	-- return cardList, cardList
end 

function M:check(data)
	local cardList = data.outCardInfo.cardList
	local cardStack = new(CardStack, {cards = cardList})
	if #cardList < self.sameCount * self.minLength then 
		return false 
	end
	local mainCards = separateMainCards(data.ruleDao, cardList)
	if #mainCards ~= 0 and #mainCards ~= #cardList then 
		return false
	end

	local function checkOneMap(map) ----检查一个序列里是否有满足的
		local totalCount = 0 ---记录已使用的牌数
		local leftCount = 0 ---记录多出来的牌数
		local curCount = 0   --当前牌在牌列表中有多少张
		local lastByte = nil  --记录下找到序列的最后一张牌

		for color = 0, 3 do 
			for _, v in ipairs(map) do 
				local byte = getCardByteFromAttr(v, color)
				curCount = cardStack:getNumberByByte(byte)
				if curCount >= self.sameCount then 
					totalCount = totalCount + curCount
					leftCount = leftCount + (curCount - self.sameCount)
					lastByte = byte
				elseif curCount == 0 then
					local lineCount = totalCount - leftCount;
					if totalCount == #cardList and leftCount ~= 0 and totalCount ~= leftCount * 2 and lineCount >= self.minLength then 
						data.outCardInfo.lineCount = totalCount - leftCount
						return true, lastByte
					end 
					totalCount = 0
					leftCount = 0
					lastByte = nil
				else 
					break
				end
			end
			local lineCount = totalCount - leftCount;
			if totalCount == #cardList and leftCount ~= 0 and totalCount ~= leftCount * 2 and lineCount >= self.minLength then 
				data.outCardInfo.lineCount = totalCount - leftCount --记录顺子的长度
				return true, lastByte
			else
				totalCount = 0
				leftCount = 0
				lastByte = nil
			end
		end
	end

	for _,map in pairs(self.lineMap) do 
		local code, byte = checkOneMap(map)
		if code then
			data.outCardInfo.cardByte = byte
			return code
		end
	end	
end

function M:compare(data)
	local outCardList = data.outCardInfo.cardList
	local targetCardList = data.targetCardInfo.cardList
	if #outCardList ~= #targetCardList then 
		return false
	end
	local outCardByte = data.outCardInfo.cardByte
	local targetCardByte = data.targetCardInfo.cardByte
	return self.byteToSize[outCardByte] > self.byteToSize[targetCardByte]
end

function M:find(data)
	local srcCardNum = #data.srcCardStack:getCardList()
	if srcCardNum < self.sameCount * self.minLength + 1 then
		return
	end
	if data.targetCardInfo then
		local targetNum = #data.targetCardInfo.cardList
		

		if srcCardNum < targetNum then
			return
		end
	end

	--统一处理返回结果
	local function dealResult(cardStack, resultList, lineCount)
		--TODO：是否统一排序
		if not resultList then 
			return
		end
		return
			{
				cardList = resultList,
				cardByte = resultList[1].byte,
				cardType = self.uniqueId,
				lineCount = lineCount,
			}
	end

	--找到value在序列中的位置
	local function getLineMapIndex(lineMap,value)
		for i = #lineMap, 1, -1 do 
			if lineMap[i] == value then 
				return i
			end
		end
	end

	---找到序列大于targetCardByte的起始下标
	local function getBeginIndex(lineMap,targetCardByte,length)
		local length = length and length or self.minLength * self.sameCount
		if not targetCardByte then 
			return 1
		else
			local card = Card.new(targetCardByte)
			local targetIndex = getLineMapIndex(lineMap,Card.ValueMap:get(card.value))
			if targetIndex and targetIndex < #lineMap then
				local result = (targetIndex + 1) - length/self.sameCount +1
				if result > 0 then
					return result
				else
					return
				end
			else
				return
			end
		end
	end

	--从一个序列中找, 没有传进来目标牌时
	local function findFromOneMapWithoutTargetCard(cardStack,map,targetCardByte,lineCount,queue,color)
		local index = getBeginIndex(map,targetCardByte)
		if not index then 
			return
		end
		local beginIndex = nil
		local endIndex = nil
		local steep = nil
		local insertPos = 1
		local insertPosChange = 1
		if queue == 1 then --从小到大,从左往右
			beginIndex = index
			endIndex = #map
			steep = 1
			insertPosChange = 0
		else 		--从大到小
			beginIndex = #map
			endIndex = index
			steep = -1
		end

		local result = {}
		local startColor = color and color or 0
		local endColor = color and color or 3
		for color = startColor, endColor do --花色遍历
			local lastAddCard = nil
			local redundant = 0 -- 顺子中多出来的牌数
			local totalCount = 0
			local findLineCount = 0
			for index = beginIndex, endIndex, steep do 
				local byte = getCardByteFromAttr(map[index], color)
				local cards = cardStack:getCardsByByte(byte)
				local curCount = #cards 
				if curCount >= self.sameCount then 
					if not lineCount or findLineCount < lineCount then
						for i = 1, self.sameCount do
							totalCount = totalCount + 1
							table.insert(result, insertPos, cards[i])
							insertPos = insertPos + insertPosChange
							findLineCount = findLineCount + 1
						end
						if curCount > self.sameCount then 
							totalCount = totalCount + 1
							redundant = redundant + 1
							lastAddCard = cards[1]
							table.insert(result, insertPos, cards[1])
							insertPos = insertPos + insertPosChange
						end
					else
						break
					end
				else
					if totalCount > self.sameCount * self.minLength and redundant > 0 then  
						break
					end
					result = {}
					insertPos = 1
					totalCount = 0
					redundant = 0
					lastAddCard = nil
				end
			end

			if totalCount - redundant >= self.minLength * self.sameCount  and redundant > 0 then 
				if #result == redundant * 2 then 
					for i, card in ipairs(result) do 
						local normalByte = Card.getNormalByte(card)
						if normalByte == Card.getNormalByte(lastAddCard) then 
							table.remove(result, i)
							break
						end
					end
				end 
				return dealResult(cardStack, result,totalCount - redundant)
			end
			result = {}
			insertPos = 1
			totalCount = 0
			redundant = 0
			lastAddCard = nil
		end
	end

	local function findFromOneMapWithTargetCard(cardStack, map, targetCardByte, length, queue, lineCount, color)
		local index = getBeginIndex(map,targetCardByte,lineCount)
		if not index then 
			return
		end
		local beginIndex = nil
		local endIndex = nil
		local steep = nil
		local insertPos = 1
		local insertPosChange = 1
		if queue == 1 then --从小到大,从左往右
			beginIndex = index
			endIndex = #map
			steep = 1
			insertPosChange = 0
		else 		--从大到小
			beginIndex = #map
			endIndex = index
			steep = -1
		end

		local totalCount = 0
		local realColor = nil
		if targetCardByte then 
			realColor = Card.new(targetCardByte).color
		elseif color then
			realColor = color
		end
		local result = {}
		for index = beginIndex, endIndex, steep do 
			local byte = getCardByteFromAttr(map[index], realColor)
			local cards = cardStack:getCardsByByte(byte)

			local curCount = #cards 
			if curCount >= self.sameCount then 
				for i = 1, self.sameCount do
					totalCount = totalCount + 1
					table.insert(result, insertPos, cards[i])
					insertPos = insertPos + insertPosChange
				end

				if #result > lineCount then
					if insertPos == 1 then
						table.remove(result)
					else
						table.remove(result, 1)
					end
					insertPos = insertPos - insertPosChange
					totalCount = totalCount - 1
				end
			end
			if totalCount == lineCount then 
				local duiZiNum = length - lineCount
				local addCards = {}
				for i = #result, 1, -1 do 
					local normalByte = Card.getNormalByte(result[i])
					local cards = cardStack:getCardsByByte(normalByte)
					if #cards > 1 then 
						table.insert(addCards, cards[1])
					end
					if #addCards == duiZiNum then 
						break
					end
				end 
				if #addCards == duiZiNum then
					local t = table.merge2(result, addCards)
					return dealResult(cardStack, t, lineCount)
				end
			end
			if curCount < self.sameCount then
				insertPos = 1
				totalCount = 0
				result = {}
			end
		end
		if totalCount >= lineCount then
			local duiZiNum = length - lineCount
			local addCards = {}
			for i = #result, 1, -1 do 
				local normalByte = Card.getNormalByte(result[i])
				local cards = cardStack:getCardsByByte(normalByte)
				if #cards > 1 then 
					table.insert(addCards, cards[1])
				end
				if #addCards == duiZiNum then 
					break
				end
			end 
			if #addCards == duiZiNum then
				local t = table.merge2(result, addCards)
				return dealResult(cardStack, t,lineCount)
			end
		end	
	end

	local function findFromCardStack(tab, targetCardByte, length, queue, lineCount, color)
		local beginIndex = 1
		local endIndex = #self.lineMap
		local steep = 1
		if queue == 1 then --从小到大
			beginIndex, endIndex = endIndex, beginIndex
			steep = -1
		end
		for _, cardStack in ipairs(tab) do 
			for i = beginIndex, endIndex, steep do 
				local result, left 
				if not targetCardByte and not length then
					result, left = findFromOneMapWithoutTargetCard(cardStack, self.lineMap[i], targetCardByte, lineCount, queue, color)
				else
					result, left = findFromOneMapWithTargetCard(cardStack, self.lineMap[i], targetCardByte, length, queue, lineCount, color)
				end
				if result then 
					return result, left
				end
			end
		end
	end
--==========================================
	local cardList = data.srcCardStack:getCardList()
	local targetCardInfo = data.targetCardInfo
	local targetCardByte = targetCardInfo and targetCardInfo.cardByte
	local targetCardList = targetCardInfo and targetCardInfo.cardList
	local length = targetCardList and #targetCardList
	local lineCount = targetCardInfo and targetCardInfo.lineCount

	if lineCount == nil and targetCardInfo then
		if self:check({ruleDao = data.ruleDao, outCardInfo = targetCardInfo}) then
			lineCount = targetCardInfo.lineCount
			Log.i("lineCount", lineCount, targetCardByte)
		else
			lineCount = self.minLength
		end
	end
	local queue = data.queue or 0

	local mainCardList, otherCardList = separateMainCards(data.ruleDao, cardList)
	local mainCardStack = new(CardStack, {cards = mainCardList})
	local otherCardStack = new(CardStack, {cards = otherCardList})

	if targetCardByte then
		local targetCard = Card.new(targetCardByte)
		if data.ruleDao:isMainCard(targetCard) then --主牌
			return findFromCardStack({mainCardStack}, targetCardByte, length, queue, lineCount)
		else --副牌
			return findFromCardStack({otherCardStack}, targetCardByte, length, queue, lineCount)
		end  
	else
		local color = nil
		color = targetCardList and CardUtils.getCardLogicColor(self.ruleDao, targetCardList[1])
		if queue == 0 then
			return findFromCardStack({mainCardStack, otherCardStack}, targetCardByte, length, queue, lineCount, color)					
		else
			return findFromCardStack({otherCardStack, mainCardStack}, targetCardByte, length, queue, lineCount, color)
		end
	end
end

return M;