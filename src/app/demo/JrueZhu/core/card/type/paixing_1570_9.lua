--[[--ldoc desc
@module paixing_1570_9
@author name

Date   2018-02-27 18:05:16
Last Modified by   KevinZhang
Last Modified time 2018-08-21 21:02:02
]]

local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
    牌型：同花顺
    特征：只能是5张相连的单牌，相同花色
    例如：3 4 5 6 7
    范围：3-4-5-...-Q-K-A
]]

function M:ctor(data)
    local typeArgs = data.typeRule.args
    local args = {}
    args.sameCount = 1
    args.minLength = tonumber(typeArgs[1])
    args.lineArgs = typeArgs[2]
    LineBase.init(self, args)
end

--找到value在序列中的位置
local function getLineMapIndex(lineMap,value,minLength)
    for i, v in ipairs(lineMap) do
        if v.curValue == value and i >= minLength then 
            -- Log.i("function getLineMapIndex",v.curValue , i)
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
            findIndex  =  i;
            break
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

---找到序列大于targetCardByte的起始下标
local function getBeginIndex(self, lineMap,targetCardByte,length, minLength)
    local length = length and length or self.minLength * self.sameCount
    if not targetCardByte then 
        return 1
    else
        local card = Card.new(targetCardByte)
        local targetIndex = getLineMapIndex(lineMap,Card.ValueMap:get(card.value),self.minLength)
        if targetIndex and targetIndex <= #lineMap then
            return (targetIndex + 1) - length/self.sameCount;
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
            local curCard = cardStack:getCardsByValue(Card.ValueMap:rget(v.curValue))[1]
            if lastCard then  --记录上一张的牌
                if curCard.color ~= lastCard.color then  --对比上一张和下一张花色是否相同
                    return false;
                end
            end
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

---是否是相同花色
local function isSameColor( resultList )
    local isSame= true;
    for k,v in ipairs(resultList) do
        local color = v.color;
        local nextCardIndex = k + 1 >= #resultList and #resultList or k + 1;
        local nextColor = resultList[nextCardIndex].color;
        if color ~= nextColor then
            isSame = false;
        end
    end
    return isSame
end


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

    local i = low
    while i ~= up do

        for color=0,3 do
        end
        i = i + step
    end
    for _i=low, up, step do
        for color=0,3 do
            local resultList = {}
            for i=_i, up, step do 
                local curValue = map[i].curValue
                local curCount = cardStack:getNumberByByte(Card.getCardByteFromAttr(Card.ValueMap:rget(curValue), color))  --得到每个牌值的手牌数量
                if curCount >= self.sameCount then 
                    local cards = cardStack:getCardsByByte(Card.getCardByteFromAttr(Card.ValueMap:rget(curValue), color))
                    for j=1, self.sameCount do --找到的牌数量满足要求
                        table.insert(resultList, insertPos, cards[j])
                        cardStack:removeCard(cards[j]);
                        insertPos = insertPos + insertPosChange
                    end
                    
                    if length and #resultList == length and length == self.minLength*self.sameCount then --判断是否已达到要求的固定长度
                        local findCardInfo = dealResult(self, resultList)
                        if not targetCardByte or self.byteToSize[findCardInfo.cardByte] > self.byteToSize[targetCardByte] then
                            return findCardInfo
                        end
                    end
                else --如果查找序列发生中断，先判断是否已经满足查找条件，满足则返回结果
                    if not length and #resultList == self.minLength*self.sameCount then
                        local findCardInfo = dealResult(self, resultList)
                        if not targetCardByte or self.byteToSize[findCardInfo.cardByte] > self.byteToSize[targetCardByte] then
                            return findCardInfo
                        end
                    end
                    cardStack:addCards(resultList)
                    resultList = {}
                    insertPos = 1
                    break
                end
            end
            --已查找到序列终点，判断是否满足条件
            if length and #resultList == length then
                local findCardInfo = dealResult(self, resultList)
                if not targetCardByte or self.byteToSize[findCardInfo.cardByte] > self.byteToSize[targetCardByte] then
                    return findCardInfo
                end
            elseif not length and #resultList == self.minLength * self.sameCount then
                local findCardInfo = dealResult(self, resultList)
                if not targetCardByte or self.byteToSize[findCardInfo.cardByte] > self.byteToSize[targetCardByte] then
                    return findCardInfo
                end
            end
        end
    end
end


function M:find(data)
    local cardStack = data.srcCardStack:clone();
    local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList
    local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte or nil
    local lineMapStart = 1
    local lineMapEnd = #self.lineMap
    local step = 1

    for i=lineMapStart, lineMapEnd, step do
        local map = self.lineMap[i];
        local result = nil;
        if self.enableLaiZi == 1 then
            local lineTmp, leftCardStack = findLineWithLaizi(self, {
                srcCardStack = data.srcCardStack,
                queue = data.queue,
                map = map,
                length = length,
                tarCardByte = cardByte,
            });
            if lineTmp and #lineTmp == self.minNum then
                result = dealResult(self, lineTmp);
                cardStack = leftCardStack or cardStack;
            end
        else
            result = findFromOneMap(self, map, cardByte, length, data.queue, self.minLength, cardStack);
        end
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