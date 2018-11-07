--[[--ldoc desc
@module paixing_1569_2
@author WahidZhang

Date   2018-01-09 19:35:02
Last Modified by   WahidZhang
Last Modified time 2018-07-03 17:54:14
]]
 --[[
 paixing_1569_2:
 	paixing_1569_2: 2对及以上两张点数+花色相同的牌
1、相连的对子，牌点必需相邻，主、副不能相连 
2、对大王+对小王是独立的连对 
注：这里的花色相同，指黑红梅方其中任意一色完全相同
 paidiandaxiao_1579_2: 同牌型的牌点大小：AA22<2233<…

 	牌型：连对(升级类)
 	特征：牌点相邻的两组牌，每组都由两张相同牌点和相同花色的牌组成
 	例如：(33 44)、(77 88)、(小王小王 大王大王)
 	范围：A-2-3-...-J-Q-K-小王-大王
 ]]
local CardBase = import("..base.CardBase")
local M = class(CardBase)

function M:ctor(data, ruleDao)
	self:init(data)
end

function M:init(data)

	local function  dealLineArgStr(str)
		if not str then
			return
		end
		local lineMap = {}
		local strArr = string.split(str,"/")
		for _, str1 in ipairs(strArr) do
			local temp = {}
			local wangTemp = {}
			local arr = string.split(str1, ">")
			for i=1, #arr do
				if arr[i] == "大王" or arr[i] == "小王" then
					table.insert(wangTemp, 1, arr[i])
				else
					table.insert(temp, 1, arr[i])
				end
			end
			table.insert(lineMap, 1, wangTemp)
			table.insert(lineMap, 1, temp)
		end
		
		return lineMap
	end

	local lineMap = {
		{"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"},
		{"小王", "大王"},
	}
	self.lineArgs = self.sortRule and self.sortRule[1].args[1]
	self.lineMap = dealLineArgStr(self.lineArgs) or lineMap
	self.sameCount =  2
	self.minLength =  2
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
local function separateMainCards(ruleDao,cardList)
	local mainCards = {}
	local otherCards = {}
	for _, card in pairs(cardList) do
		if ruleDao:isMainCard(card) then
			table.insert(mainCards, card)
		else
			table.insert(otherCards, card)
		end
	end
	return mainCards, otherCards
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
					if totalCount == #cardList then
						return true, lastByte
					end
					totalCount = 0
					lastByte = nil
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
	local tagetCardByte = data.targetCardInfo.cardByte
	return self.byteToSize[outCardByte] > self.byteToSize[tagetCardByte]
end


function M:find(data)
	if data.targetCardInfo then
		local targetCardNum = #data.targetCardInfo.cardList
		if targetCardNum < self.sameCount * self.minLength then
			return
		end
		local __groupNum = targetCardNum/self.sameCount
		if __groupNum ~= math.floor(__groupNum) then
			return
		end
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
		for i, v in ipairs(lineMap) do
			if v == value then
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
				return (targetIndex + 1) - length/self.sameCount +1
			else
				return
			end
		end
	end

	--找大王小王连对
	local function findFromKingMap(cardStack, targetCardByte, length)
		if targetCardByte and targetCardByte == Card.ByteMap:rget("大王") then
			return
		end
		if length and length ~= 4 then
			return
		end
		local redKings = cardStack:getCardsByByte(Card.ByteMap:getKeyByValue("大王"))
		local blackKings = cardStack:getCardsByByte(Card.ByteMap:getKeyByValue("小王"))
		if #redKings >= self.sameCount and #blackKings >= self.sameCount then
			local result = {}
			for i = 1, self.sameCount do
				table.insert(result, redKings[i])
			end
			for i = 1, self.sameCount do
				table.insert(result, blackKings[i])
			end
			return dealResult(cardStack, result)
		end
	end

	--从一个序列中找
	local function findFromOneMap(cardStack,map,targetCardByte,length,queue)
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
			realColor = Card.new(targetCardByte).color
		end

		local result = {}
		for color = 0, 3 do --花色遍历
			for index = beginIndex, endIndex, steep do
				local byte = getCardByteFromAttr(map[index],  realColor or color)
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
				if index == endIndex then
					if not length and #result >= self.minLength * self.sameCount then
						return dealResult(cardStack, result)
					end
					result = {}
					insertPos = 1
				end
			end
			if realColor then --如果传进来花色则只执行一次
				break
			end
			result = {}
			insertPos = 1
		end
	end

   --==========================================================

	local cardList = data.srcCardStack:getCardList()
	local targetCardByte = nil
	if data.targetCardInfo and data.targetCardInfo.cardByte then
		targetCardByte = data.targetCardInfo.cardByte
	end
	local length = data.targetCardInfo and #data.targetCardInfo.cardList
	local queue = data.queue or 0
	local mainCardList, otherCardList = separateMainCards(data.ruleDao, cardList)
	local mainCardStack = new(CardStack, {cards = mainCardList})
	local otherCardStack = new(CardStack, {cards = otherCardList})

	if targetCardByte then
		local targetCard = Card.new(targetCardByte)
		if data.ruleDao:isMainCard(targetCard) then --主牌
			if queue == 0 then --从大开始找，则先找大小王，再找普通序列
				local result, left = findFromKingMap(mainCardStack, targetCardByte, length) --先找大王小王连对
				if result then
					return result, left
				end
				local result, left = findFromOneMap(mainCardStack, self.lineMap[1], targetCardByte, length, queue)
				if result then
					return result, left
				end
			else --从小开始找，则先找普通序列，再找大小王
				local result, left = findFromOneMap(mainCardStack, self.lineMap[1], targetCardByte, length, queue)
				if result then
					return result, left
				end
				local result, left = findFromKingMap(mainCardStack, targetCardByte, length) --先找大王小王连对
				if result then
					return result, left
				end
			end
		else --副牌
			local result, left = findFromOneMap(otherCardStack, self.lineMap[1], targetCardByte, length, queue)
			if result then
				return result, left
			end
		end
	else
		if queue == 0 then
			local result, left
			result, left = findFromKingMap(mainCardStack, targetCardByte, length) --先找大王小王连对
			if result then
				return result, left
			end
			result, left = findFromOneMap(mainCardStack, self.lineMap[1], targetCardByte, length, queue)
			if result then
				return result, left
			end
			result, left = findFromOneMap(otherCardStack, self.lineMap[1], targetCardByte, length, queue)
			if result then
				return result, left
			end
		else
			local result, left
			result, left = findFromOneMap(otherCardStack, self.lineMap[1], targetCardByte, length, queue)
			if result then
				return result, left
			end
			result, left = findFromOneMap(mainCardStack, self.lineMap[1], targetCardByte, length, queue)
			if result then
				return result, left
			end
			result, left = findFromKingMap(mainCardStack, targetCardByte, length) --先找大王小王连对
			if result then
				return result, left
			end
		end
	end
end

function M:test()
	self.sortRule = {
                        [1] = {
                                ["args"] =
                                {
                                        [1] = '大王>小王/K>Q>J>10>9>8>7>6>5>4>3>2>A',
                                },
                        },
                }

	self:init()
	Log.e(self.lineMap)
	local bytes = {0x2,0x2,0x3,0x3,0x5}
	local cardList = CardUtils.getCardsFromBytes(bytes)
	local outCardInfo = {
		cardList = cardList,
	}
	Log.e(self:check({outCardInfo = outCardInfo}))


	local bytes = {0x3,0x3,0x4,0x4,0x5,0x5,0x4e,0x4f,0x4f,0x4e,}
	local cardList = CardUtils.getCardsFromBytes(bytes)
	local srcCardStack = new(CardStack, {cards = cardList})
	Log.e(self:find({srcCardStack = srcCardStack, queue = 1, }))
end

return M