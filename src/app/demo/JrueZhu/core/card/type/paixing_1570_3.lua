--[[--ldoc desc
@module paixing_1570_3
@author WahidZhang

Date   2018-01-09 19:16:21
Last Modified by   KevinZhang
Last Modified time 2018-03-22 12:12:22
]]
--[[同花色5张及以上牌点相连的顺子。
玩家可一次性打出最少5张的顺子；
不能主副牌连出
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
---------------------!!!!!!!!!!!!! 现在暂时只支持一个顺子序列
	local lineMap = {
		{"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"},
		{"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q"},
	}
	self.lineMap = lineMap

	self.sameCount =  1
	self.minLength =  5
	self.minNum = self.sameCount * self.minLength
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
		local curCount = 0   --当前牌在牌列表中有多少张
		local lastByte = nil  --记录下找到序列的最后一张牌

		for color = 0, 3 do
			for _, v in ipairs(map) do
				local byte = getCardByteFromAttr(v, color)
				curCount = cardStack:getNumberByByte(byte)
				if curCount == self.sameCount then
					totalCount = totalCount + curCount
					lastByte = byte
				elseif curCount == 0 then
					if totalCount > 0 then
						break
					end
				else
					break
				end
			end
			if totalCount == #cardList then
				return true, lastByte
			else
				totalCount = 0
				lastByte = nil
			end
		end
	end

	for _,map in pairs(self.lineMap) do --检查多个序列
		local code, byte = checkOneMap(map)
		if code then
			data.outCardInfo.size = self.sortRule.args
			data.outCardInfo.byteToSize = self.byteToSize
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
	if data.targetCardInfo and data.targetCardInfo.cardList then
		local targetNum = #data.targetCardInfo.cardList
		if targetNum < self.sameCount * self.minLength then
			return
		end
	end
	if #data.srcCardStack:getCardList() < self.minNum then
		return;
	end
	--统一处理返回结果
	local function dealResult(cardStack, resultList)
		--TODO：是否统一排序
		if not resultList then
			return
		end
		return {
					cardList = resultList,
					cardByte = resultList[1].byte,
					cardType = self.uniqueId,
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
				local index = (targetIndex + 1) - length/self.sameCount +1
				if index <= 0 then
					return
				end
				return index;
			else
				return
			end
		end
	end

	--从一个序列中找
	local function findFromOneMap(cardStack,map,targetCardByte,length,queue, color)
		local index = getBeginIndex(map,targetCardByte,length)
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
		local realColor = nil
		if targetCardByte then
			realColor = Card.new(targetCardByte).color --传进来牌值则只找此花色
		elseif color then
			realColor = color
		end

		local result = {}
		for color = 0, 3 do --花色遍历
			for index = beginIndex, endIndex, steep do
				local byte = getCardByteFromAttr(map[index], realColor or color)
				local cards = cardStack:getCardsByByte(byte)
				local curCount = #cards
				if curCount >= self.sameCount then
					for i = 1, self.sameCount do
						table.insert(result, insertPos, cards[i])
						insertPos = insertPos + insertPosChange
					end
					if length and #result == length then
						return dealResult(cardStack, result)
					end
				else
					if not length and #result >= self.minLength * self.sameCount then
						return dealResult(cardStack, result)
					end
					result = {}
					insertPos = 1
				end
			end
			if length and #result == length then
				return dealResult(cardStack, result)
			elseif not length and #result >= self.minLength * self.sameCount then
				return dealResult(cardStack, result)
			end
			result = {} --一种花色找完，置空
			insertPos = 1
			if realColor then
				break
			end
		end
	end

	local function findFromCardStack(tab, targetCardByte, length, queue, color)
		local beginIndex = 1
		local endIndex = #self.lineMap
		local steep = 1
		if queue ~= 0 then
			beginIndex, endIndex = endIndex, beginIndex
			steep = -1
		end
		for _, cardStack in ipairs(tab) do
			for i = beginIndex, endIndex, steep do
				local result, left = findFromOneMap(cardStack, self.lineMap[i], targetCardByte, length, queue, color)
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
	local queue = data.queue or 0
	local mainCardList, otherCardList = separateMainCards(data.ruleDao, cardList)
	local mainCardStack = new(CardStack, {cards = mainCardList})
	local otherCardStack = new(CardStack, {cards = otherCardList})

	if targetCardByte then
		local targetCard = Card.new(targetCardByte)
		if data.ruleDao:isMainCard(targetCard) then --主牌
			return findFromCardStack({mainCardStack}, targetCardByte, length, queue)
		else --副牌
			return findFromCardStack({otherCardStack}, targetCardByte, length, queue)
		end
	else
		local color = nil
		color = targetCardList and targetCardList[1].color
		if queue == 0 then
			return findFromCardStack({mainCardStack, otherCardStack}, targetCardByte, length, queue, color)
		else
			return findFromCardStack({otherCardStack, mainCardStack}, targetCardByte, length, queue, color)
		end
	end

end

return M