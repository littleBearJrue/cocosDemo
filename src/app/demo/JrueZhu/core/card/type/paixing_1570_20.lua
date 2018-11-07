--[[--ldoc desc
@module LineBase
@author KevinZhang

Date   2018-05-16 18:03:15
Last Modified by   EricHuang
Last Modified time 2018-08-08 11:47:11
]]-- @Author: EricHuang
-- @Date:   2017-11-27 12:17:26
-- @Last Modified by   LucasZhen
-- @Last Modified time 2018-05-04 17:22:11

--[[
sameCount=同牌的张数，
minLength=相邻牌的最短数量,
lineArgs=可连接的牌序列，多个序列用/分割，A-2-3-4-5-6-7-8/10-J-Q-K-A
]]

local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local M = class(LineBase)

function M:ctor(data)
    local typeArgs = data.typeRule.args
    local args = {}
    args.sameCount = 1
    args.minLength = typeArgs[1]
    args.lineArgs = typeArgs[2]
    LineBase.init(self,args)
end


--找到value在序列中的位置
local function getLineMapIndex(lineMap,value,minLength)
    for i, v in ipairs(lineMap) do
        if v.curValue == value and i >= minLength then 
            return i
        end
    end
end

local function compareValueIndex(lineMap, targetCardByte, length, minLength)
    local targetCard = Card.new(targetCardByte)
    local findIndex = nil
    for i,cardMap in ipairs(lineMap) do
        local cardValue = Card.ValueMap:getKeyByValue(cardMap.curValue)
        if cardValue == targetCard.value and i >= minLength then  
            if lineMap[i] then
                findIndex  =  i;
                break
            end
        end
    end

    if findIndex then
        if findIndex <= length then
            return 1
        else
            return findIndex
        end
    end
    return
end

---找到序列value等于targetCardByte的起始下标
local function getBeginIndex(self, lineMap,targetCardByte,length, minLength)
    local length = length and length or self.minLength * self.sameCount
    if not targetCardByte then 
        return 1
    else
        local card = Card.new(targetCardByte)
        local targetIndex = getLineMapIndex(lineMap,Card.ValueMap:get(card.value),self.minLength)
        if targetIndex and targetIndex <= #lineMap then
            return (targetIndex + 1) - length/self.sameCount;--targetCardByte的起始下标
        else
            return compareValueIndex(lineMap, targetCardByte, length, minLength)
        end
    end
end

--统一处理返回结果
local function dealResult(self, resultList)
    if not resultList then 
        return
    end
    
    return {
        cardList = resultList,
        cardByte = resultList[1].byte,
        cardType = self.uniqueId,
    }
end

local function checkOneMap(params) ----检查一个序列里是否有满足的
    local self       = params.obj;
    local outCardInfo = params.outCardInfo;
    local cardList   = params.cardList;
    local map        = params.map;

    local cardStack = new(CardStack, {cards = cardList})

    local totalCount = 0 ---记录已使用的牌数
    local curCount = 0   --当前牌在牌列表中有多少张
    local lastCard = nil  --记录下找到序列的最后一张牌
    for _, v in ipairs(map) do 
        curCount = cardStack:getNumberByValue(Card.ValueMap:rget(v.curValue))
        if curCount == self.sameCount then 
            totalCount = totalCount + curCount
            lastCard =  cardStack:getCardsByValue(Card.ValueMap:rget(v.curValue))[1]
        elseif curCount > 0 then
            return false
        elseif curCount == 0 then 
            if totalCount > 0 then 
                break
            end
        end
    end
    if totalCount == #cardList then 
        outCardInfo.cardByte = lastCard.byte;
        outCardInfo.groupLenght = totalCount / self.sameCount
        return true;
    else    
        return false
    end
end

function M:check(data)
    if not(#data.outCardInfo.cardList == self.minNum) then
        return false
    end
    local cardList, otherList = self:getValidCard(data.outCardInfo.cardList)

    if self.enableLaiZi == 0 and #cardList ~= #data.outCardInfo.cardList then
        return false
    end

    if #cardList + #otherList ~= self.sameCount * self.minLength then 
        return false 
    end

    for _, map in ipairs(self.lineMap) do  ---可循环匹配多个顺子序列
        local params = {
            obj = self,
            outCardInfo = data.outCardInfo,
            cardList = cardList,
            otherList = otherList,
            map = map,
        }
        local checkFunc = checkOneMap
        local result = checkFunc(params);
        if result then
            return result
        end
    end
    return false
end


--可能存在多个可用的顺子序列，一次查找一个序列
-- map 序列表
-- targetCardByte  要压的牌值，为空则不需要压
-- length 牌的总长度
-- queue 1从小开始找，默认从大开始 
local function findFromOneMap(self, map, targetCardByte, length, queue, minLength, cardStack)
    local index = getBeginIndex(self, map, targetCardByte, length, minLength)
    if not index then 
        return
    end

    index = index<=0 and 1 or index;
    local low = queue == 1 and index or #map;
    local up = queue == 1 and #map or index;
    local step = queue == 1 and 1 or -1;

    local insertPosChange = queue == 1 and 0 or 1;
    local insertPos = 1;

    local resultList = {}
    for i=low, up, step do 
        local curValue = map[i].curValue
        local curCount = cardStack:getNumberByValue(Card.ValueMap:rget(curValue))
        if curCount >= self.sameCount then 
            local cards = cardStack:getCardsByValue(Card.ValueMap:rget(curValue))
            
            if targetCardByte and queue == 1 and #resultList == minLength - 1 then
                table.sort(cards, function(a, b)
                    cardA = a.byte
                    cardB = b.byte
                    return a < b
                end )
                for j=1, curCount do --找到的牌数量满足要求
                    if self.byteToSize[cards[j].byte] > self.byteToSize[targetCardByte] then
                        table.insert(resultList, insertPos, cards[j])
                        cardStack:removeCard(cards[j]);
                        insertPos = insertPos + insertPosChange
                        break
                    end
                end
            elseif targetCardByte and queue == 0 and #resultList == 0 then
                table.sort(cards, function(a, b)
                    cardA = a.byte
                    cardB = b.byte
                    return a > b
                end )
                for j=1, curCount do --找到的牌数量满足要求
                    if self.byteToSize[cards[j].byte] > self.byteToSize[targetCardByte] then
                        table.insert(resultList, insertPos, cards[j])
                        cardStack:removeCard(cards[j]);
                        insertPos = insertPos + insertPosChange
                        break
                    end
                end
            elseif length and length ~= minLength then
                return
            elseif queue == 1 then 
                table.sort(cards, function(a, b)
                    cardA = a.byte
                    cardB = b.byte
                    return a < b
                end )
                for j=1, self.sameCount do --找到的牌数量满足要求
                    table.insert(resultList, insertPos, cards[j])
                    cardStack:removeCard(cards[j]);
                    insertPos = insertPos + insertPosChange
                end
            elseif queue == 0 then
                table.sort(cards, function(a, b)
                    cardA = a.byte
                    cardB = b.byte
                    return a > b
                end )
                for j=1, self.sameCount do --找到的牌数量满足要求
                    table.insert(resultList, insertPos, cards[j])
                    cardStack:removeCard(cards[j]);
                    insertPos = insertPos + insertPosChange
                end
            end
            if #resultList == self.minLength*self.sameCount then
                return dealResult(self, resultList);
            end

        else --如果查找序列发生中断，先判断是否已经满足查找条件，满足则返回结果
            if not length and #resultList >= self.minLength*self.sameCount then
                return dealResult(self, resultList);
            end
            cardStack:addCards(resultList)
            resultList = {}
            insertPos = 1
        end
    end
    --已查找到序列终点，判断是否满足条件
    if length and #resultList == length then 
        return dealResult(self, resultList);
    elseif not length and #resultList >= self.minLength * self.sameCount then
        return dealResult(self, resultList);
    end
    if #resultList > 0 then
        cardStack:addCards(resultList)
        resultList = {}
        insertPos = 1
    end
end

function M:find(data)
    local cardStack = data.srcCardStack:clone();
    -- local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or self.minNum
    local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList
    local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte or nil
    local lineMapStart = 1
    local lineMapEnd = #self.lineMap
    local step = 1
    if data.queue == 0 then
        lineMapStart, lineMapEnd = lineMapEnd, lineMapStart
        step = -1
    end

    for i=lineMapStart, lineMapEnd, step do
        local map = self.lineMap[i];
        local result = nil;
        result = findFromOneMap(self, map, cardByte, length, data.queue, self.minLength, cardStack);
        if result then 
            return result, cardStack:getCardList();
        end
    end
end

M.bindingData = {
    set = {},
    get = {},
}

return M;