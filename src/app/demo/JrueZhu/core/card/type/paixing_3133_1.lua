--[[--ldoc desc
@module paixing_3133_1
@author CelineJiang

Date   2018-08-02 11:48:34
]]
local LineBase = import("..base.LineBase")
local M = class(LineBase);

M.description = [[
2个及以上N张同花色同点数的牌： 
1、级别牌打3时，连牌顺序【3-4-5-6-7-8-9-10-J-Q-K-A-2-3】, 
2、否则，连牌顺序【3-4-5-6-7-8-9-10-J-Q-K-A-2】，级别牌不能连 
3、连牌顺序只能单向连牌，不能循环连牌，同牌点的牌不能用2次 
4、大王+小王是独立的连对 
注：主、副不能相连；花色相同指：主副花色一样，主花色中常主（包含级别牌）要分黑红梅方
]]

function M:ctor(data, ruleDao)
	self.minLength = self.args[1]
	self.sameCount = self.args[2]
	self.ruleDao = ruleDao
	self.lineMaps = {}
	self.lineMaps[self.args[3]] = g_ParseUtils.parseLineMap(self.args[4])
	self.otherLineMap = g_ParseUtils.parseLineMap(self.args[5])
	setmetatable(self.lineMaps, {__index = function(t,k)
		return self.otherLineMap
	end})
	self:init()
end	

function M:init()
	self:updateLineMap()
	LineBase.init(self,{minLength = self.minLength, sameCount = self.sameCount})
end

---根据级别牌不同，及时更新连牌顺序
function M:updateLineMap()
	local mainValue = self.ruleDao:getMainValue()
	self.lineMap = self.lineMaps[mainValue]
end

function M:check(data)
	self:updateLineMap()
	local cardList = data.outCardInfo.cardList
	local cardStack = new(CardStack, {cards = cardList})

	----大小王单独连
	local kingCount1 = cardStack:getNumberByValue(Card.ValueMap:getKeyByValue("大王"));
	local kingCount2 = cardStack:getNumberByValue(Card.ValueMap:getKeyByValue("小王"));
	if kingCount1 ~= 0 or kingCount2 ~= 0 then
		---存在大王小王的情况
		if kingCount2 == self.sameCount and kingCount1 == self.sameCount and #cardList == 2*self.sameCount then
			return true
		else
			return false
		end
	end

	--是否是同花色，主副不能连
	local colorCards = CardUtils.getCardsByColor(cardList,cardList[1].color)
	local mainCards = CardUtils.getMainCards(self.ruleDao, cardList)
	if #colorCards ~= #cardList then
		return false
	end

	if #mainCards ~= #cardList and #mainCards ~= 0  then
		return false
	end
	----其他情况可以调LineBase通过牌点判断
	return LineBase.check(self,data)
end


function M:compare(data)
	self:updateLineMap()
	local outCardList= data.outCardInfo.cardList
	local targetCardList = data.targetCardInfo.cardList

	local function isKingLine(cardList)
		for _, card in ipairs(cardList) do
			if card.byte == Card.ByteMap:getKeyByValue("大王") or card.byte == Card.ByteMap:getKeyByValue("小王") then
				return true
			end
		end
		return false
	end
	local function isMainLine( cardList)
		if CardUtils.isMainCard(self.ruleDao, cardList[1]) then
			return true
		end
		return false
	end 

	if #outCardList ~= #targetCardList then
		return false
	end

	-------王拖拉机和主牌拖拉机涉及到了花色的需要另外判断
	if isKingLine(targetCardList) then
		---目标牌型为王连对
		return false
	end

	if isKingLine(outCardList) then
		return true
	end

	if isMainLine( targetCardList) and not isMainLine(outCardList) then
		--副贴主
		return false
	end

	if not isMainLine(targetCardList) and isMainLine(outCardList) then
		--主压副
		return true
	end

	if isMainLine( targetCardList) and isMainLine(outCardList) and self.ruleDao:getMainColor() > 0 then
		if Card.new(data.targetCardInfo.cardByte).value == Card.new(data.outCardInfo.cardByte).value then
			---同为主牌，但是有主副之分，比如级别牌为3，常主为2的时候，主花色的2233大于副花色的2233
			if targetCardList[1].color == self.ruleDao:getMainColor() and outCardList[1].color ~= self.ruleDao:getMainColor() then
				return false
			end
			if targetCardList[1].color ~= self.ruleDao:getMainColor() and outCardList[1].color == self.ruleDao:getMainColor() then
				return true
			end
		end
	end
	return LineBase.compare(self,data)
end


function M:find(data)
	self:updateLineMap()
	local queue = data.queue or 0
	local result = nil

	local function parseResult(cardList)
		if cardList then
			local result = {}
			result.cardList = cardList
			result.cardByte = cardList[#cardList].byte
			result.cardType = self.uniqueId
			return result
		end
	end 
	---同牌点不同花色之前的压制
	local function getCardsWithSameCardValue(data)
		local mainCards = CardUtils.getMainCards(self.ruleDao, data.srcCardStack:getCardList())
		local colorCards = clone(CardUtils.getCardsByColor(mainCards, self.ruleDao:getMainColor()))
		local targetCardList = data.targetCardInfo.cardList

		local result = {}
		for _, targetCrd in ipairs(targetCardList) do
			for index, colorCard in ipairs(colorCards) do
				if colorCard.value == targetCrd.value then
					result[#result + 1] = colorCard
					table.remove(colorCards,index)
				end
			end
		end
		local sortData = {cardInfo = {}, ruleDao = self.ruleDao}
		sortData.cardInfo.cardList = result
		self:sort(sortData)
		if #result == #targetCardList then
			return parseResult(result)
		end
	end 

	---根据在特定花色的牌中找牌
	local function getCardsByColor(srcCardList,color)
		local srcCardList2 = {}
		if color == data.ruleDao:getMainColor() then
			local colorCards = CardUtils.getCardsByColor2(data.ruleDao, srcCardList, color)
			for i = 0, 3 do
				local colorCards2 = CardUtils.getCardsByColor(colorCards, i)
				if #colorCards2 > 0 then
					table.insert(srcCardList2, colorCards2)
				end
			end
		else
			local colorCards = CardUtils.getCardsByColor(srcCardList, color)
			table.insert(srcCardList2, colorCards)
		end
		for _, colorCards in pairs(srcCardList2) do		
			local sortData = {cardInfo = {}, ruleDao = self.ruleDao}
			sortData.cardInfo.cardList = colorCards
			self:sort(sortData)
			local findInfo = {
				ruleDao = self.ruleDao, 
				srcCardStack = new(CardStack,{cards = colorCards}), 
				targetCardInfo = data.targetCardInfo,
				queue = data.queue
			}
			local result, otherData = LineBase.find(self, findInfo)
			if result then
				return result
			end
		end
	end

	------找大小王单独连的拖拉机，目标牌型存在应该要考虑目标牌型的长度
	local function findKingLine(data)
		local cardStack = data.srcCardStack
		local kingCount1 = cardStack:getNumberByValue(Card.ValueMap:getKeyByValue("大王"));
		local kingCount2 = cardStack:getNumberByValue(Card.ValueMap:getKeyByValue("小王"));
		local isFind = false
		if kingCount1 == self.sameCount and kingCount2 == self.sameCount then
			if data.targetCardInfo then
				if #data.targetCardInfo.cardList/self.sameCount == 2 then
					isFind = true
				end
			else
				isFind = true
			end
		end
		if isFind then
			local result = cardStack:getCardsByValue(Card.ValueMap:getKeyByValue("小王"));
			result = table.merge2(result, cardStack:getCardsByValue(Card.ValueMap:getKeyByValue("大王")))
			return parseResult(result)
		end
	end

	-----找主牌牌型的拖拉机
	local function findMainCards(data,color)
		local mainCards = CardUtils.getMainCards(self.ruleDao, data.srcCardStack:getCardList())
		if color == self.ruleDao:getMainColor() then
			---目标牌型是主花色的拖拉机		
			return getCardsByColor(mainCards, color)
		else
			---目标牌型是主牌拖拉机,但不是主花色(常主与级别牌的组合)
			return getCardsWithSameCardValue(data) or getCardsByColor(mainCards, self.ruleDao:getMainColor())
		end						
	end 
--------------没有目标牌型的找牌------------
    local function getFindCards(data)
	    local sortData = {cardInfo = {}, ruleDao = self.ruleDao}
		sortData.cardInfo.cardList = data.srcCardStack:getCardList()
		self:sort(sortData)
		local copyCardList = {}
		table.copyTo(copyCardList, sortData.cardInfo.cardList)
		data.queue = data.queue or 0
		local cardList = {}
		local _cardList = {}
		while true and #copyCardList > 0 do
			cardList = {}
			local color = copyCardList[1].color
			local isMainCard = CardUtils.isMainCard(self.ruleDao, copyCardList[1])
			for i = 1, #copyCardList do
				local card = copyCardList[i]
				if card.color == color and CardUtils.isMainCard(self.ruleDao, card) == isMainCard then
					table.insert(cardList, card)
				end
			end
			copyCardList = CardUtils.removeCards(copyCardList, cardList)
			local findData = {}
			for k,info in pairs(data) do
				findData[k] = info
			end
			
			findData.srcCardStack = new(CardStack, {cards = cardList})
			local result, otherData = LineBase.find(self, findData)
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
    
------开始找牌,3种情况:1、存在目标牌型且为主牌 2、存在目标牌型且为副牌 3、不存在目标牌型
	if data.targetCardInfo and data.targetCardInfo.cardList then
		----存在目标牌型的时候
		local cardList = data.targetCardInfo.cardList
		local isMain = CardUtils.isMainCard(self.ruleDao, cardList[1])
		if isMain then 
			---目标牌型是同花色主牌
			if queue == 0 then
				---从大到小找牌
				return findKingLine(data) or findMainCards(data,cardList[1].color)
			else
				---从小到大
				return findMainCards(data,cardList[1].color) or findKingLine(data)
			end
		else
			---同花色副牌
			local mainCards = CardUtils.getMainCards(self.ruleDao, data.srcCardStack:getCardList())
			local findData = {
				ruleDao = self.ruleDao,
				srcCardStack = new(CardStack, {cards = mainCards}),
				queue = data.queue,
				targetCardInfo = {
				cardList = cardList
				}
			}
			if queue == 0 then
				return getCardsByColor(data.srcCardStack:getCardList(), cardList[1].color) or findKingLine(data) or LineBase.find(self,findData)
			else
				return getCardsByColor(data.srcCardStack:getCardList(), cardList[1].color) or LineBase.find(self,findData) or findKingLine(data)
			end
		end
	else
		if queue == 0 then
			return findKingLine(data) or getFindCards(data)
		else
			return getFindCards(data) or findKingLine(data)
		end
	end
end
return M