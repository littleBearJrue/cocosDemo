--[[--ldoc desc
@module paixing_1569_10
@author WahidZhang

Date   2018-01-09 19:35:02
Last Modified by   LisaChen
Last Modified time 2018-07-19 17:27:05
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
			local arr = string.split(str1, "-")
			for i=1, #arr do
				table.insert(temp, 1, arr[i])
			end
			table.insert(lineMap, 1, temp)
		end
		
		return lineMap
	end

	local lineMap = {
		{"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"},
		{"小王", "大王"},
	}
	self.lineArgs = data.sortRule and data.typeRule.args[2]
	self.lineMap = table.insert(dealLineArgStr(self.lineArgs), {"小王", "大王"}) or lineMap
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
	-- local mainCards = separateMainCards(data.ruleDao, cardList)
	-- if #mainCards ~= 0 and #mainCards ~= #cardList then
	-- 	return false
	-- end

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
			-- Log.v(data, "check_findData")
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
	Log.i("outCardByte"..outCardByte, "tagetCardByte"..tagetCardByte, "self.byteToSize[outCardByte]"..self.byteToSize[outCardByte], "self.byteToSize[tagetCardByte]"..self.byteToSize[tagetCardByte])
	return self.byteToSize[outCardByte] > self.byteToSize[tagetCardByte]
end

function M:find(data)
    data.queue = data.queue or 0
    local validCardList, invalidCardList = self:getValidCard(data.srcCardStack:getCardList());
    local cardStack = data.srcCardStack

    -- 分四种情况处理，1）有压牌要求，从大到小找牌，2）有压牌要求，从小到大找牌，3）无压牌要求，从大到小找牌，4）无压牌要求，从小到大找牌

    --统一处理返回结果
    local function dealResult(resultList)
        --TODO：是否统一排序
        if not resultList then
            return
        end

        local firstColor = resultList[1].color
        for _,card in ipairs(resultList) do
            if card.color ~= firstColor then
                return false;      
            end
        end


        --  修改由targetInfo 引起的BUG  
        if  #resultList < self.minNum then
            return
        end
        return
            {
                cardList = resultList,
                cardByte = resultList[1].byte,
                cardType = self.uniqueId,
            }
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
            return dealResult(result)
        end
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
                return (targetIndex - length/self.sameCount + 1) + 1 --  (targetIndex - length/self.sameCount + 1)：targetCards中最小牌的targetIndex
            else
                return
            end
        end
    end

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
        else        --从大到小
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
                        return dealResult(result)
                    end
                else
                    if not length and #result >= self.minLength * self.sameCount then
                        return dealResult(result)
                    end
                    result = {}
                    insertPos = 1
                end
                if index == endIndex then
                    if not length and #result >= self.minLength * self.sameCount then
                        return dealResult(result)
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

    local length  = (data.targetCardInfo and data.targetCardInfo.cardList) and #data.targetCardInfo.cardList or nil
    local targetCardByte = data.targetCardInfo and data.targetCardInfo.cardByte
    if targetCardByte then
        --有需要压过的牌点大小
        local size = self.byteToSize[targetCardByte];
        if size < self.sizeToByte.minSize or size > self.sizeToByte.maxSize then
            return;
        end
    end
    if data.queue == 0 then
        -- 从大到小找牌
        local result, left = findFromKingMap(cardStack, targetCardByte, length) --先找大王小王连对
        if result then
            return result, left
        end
        local result, left = findFromOneMap(cardStack, self.lineMap[1], targetCardByte, length, data.queue)
        if result then
            return result, left
        end
    else
        -- 从小到大找牌
        local result, left = findFromOneMap(cardStack, self.lineMap[1], targetCardByte, length, data.queue)
        if result then
            return result, left
        end
        local result, left = findFromKingMap(cardStack, targetCardByte, length) --先找大王小王连对
        if result then
            return result, left
        end
    end
end

return M