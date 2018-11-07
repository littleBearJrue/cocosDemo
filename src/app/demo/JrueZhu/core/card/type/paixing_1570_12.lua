--[[--ldoc desc
@module paixing_1570_12
@author AbelYi

Date   2018-08-28 14:14:38
Last Modified by   AbelYi
Last Modified time 2018-08-29 12:06:53
]]

local LineBase = import("..base.LineBase")
local M = class(LineBase)

function M:ctor(data)
    local typeArgs = data.typeRule.args
    local args = {}
    args.sameCount = 1
    args.minLength = typeArgs[1]
    args.lineArgs = typeArgs[2]
    LineBase.init(self,args)
end

M.description = [[
功能描述说明：
    牌型：顺子/单龙
    特征：$1张相连的单牌 连牌顺序【$2】不区分花色，，只能单向连牌，不能循环连牌，同牌点的牌不能用2次
    例如：(3 4 5)、(6 7 8 9 10)
    范围：3-4-5-...-Q-K-A

]]



function M:check(data)
    if #data.outCardInfo.cardList ~= self.minNum then
        return false
    end
    return self.super.check(self,data)
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

--找到value在序列中的位置
local function getLineMapIndex(lineMap,value,minLength)
    for i, v in ipairs(lineMap) do
        if v.curValue == value and i >= minLength then
            Log.i("function getLineMapIndex",v.curValue , i)
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
            if lineMap[i+1] then
                findIndex  =  i+1;
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

---找到序列大于targetCardByte的起始下标
local function getBeginIndex(self, lineMap,targetCardByte,length, minLength)
    local length = length and length or self.minLength * self.sameCount
    if not targetCardByte then
        return 1
    else
        local card = Card.new(targetCardByte)
        local targetIndex = getLineMapIndex(lineMap,Card.ValueMap:get(card.value),self.minLength)
        if targetIndex and targetIndex < #lineMap then
            return (targetIndex + 1) - length/self.sameCount + 1;
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
                    return true;
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


local function findFromOneMap(self, map, targetCardByte, length, queue, minLength, cardStack)
    Log.i("function M:find2")
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
        local curCount = cardStack:getNumberByValue(Card.ValueMap:rget(curValue))  --得到每个牌值的手牌数量
        if curCount >= self.sameCount then
            local cards = cardStack:getCardsByValue(Card.ValueMap:rget(curValue))
            for j=1, self.sameCount do --找到的牌数量满足要求
                table.insert(resultList, insertPos, cards[j])
                cardStack:removeCard(cards[j]);
                insertPos = insertPos + insertPosChange
            end
            if length and #resultList == length and length == self.minLength*self.sameCount then --判断是否已达到要求的固定长度

                if isSameColor(resultList) == false then
                    Log.i("function findFromOneMap sameColor" , resultList);
                    return dealResult(self, resultList);
                end
                cardStack:addCards(resultList)
                resultList = {}
                insertPos = 1
            end
        else --如果查找序列发生中断，先判断是否已经满足查找条件，满足则返回结果
            if not length and #resultList == self.minLength*self.sameCount then
                if isSameColor(resultList) == false then
                    return dealResult(self, resultList);
                end
            end
            cardStack:addCards(resultList)
            resultList = {}
            insertPos = 1
        end
    end
    --已查找到序列终点，判断是否满足条件
    if length and #resultList == length then
        if isSameColor(resultList) == false then
            return dealResult(self, resultList);
        end
    elseif not length and #resultList == self.minLength * self.sameCount then
        if isSameColor(resultList) == false then
            return dealResult(self, resultList);
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
            Log.i("function M:find1")
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