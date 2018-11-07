--[[--ldoc desc
@module LineBase2
@author KevinZhang

Date   2018-05-18 10:15:27
Last Modified by   VincentZhang
Last Modified time 2018-08-14 17:25:30
]]-- @Author: JansonHuang
-- @Date: 2018-01-23 17:49:35
--

local CardBase = import('.CardBase')
local LineBase2 = class(CardBase)

LineBase2.description = [[
功能描述说明：
    另外一种比较大小方式的顺子序列,使用byteToSize来比较
]]

function LineBase2:ctor(data, ruleDao)

end

------------初始化函数，初始化顺子序列,子类需自己调用完成初始化
function LineBase2:init(data)
    self.sameCount = data.sameCount -----可配参数
    self.minLength = data.minLength -----可配参数
    self.fixedLength = data.fixedLength -----可配参数 表示牌必须是固定张数
    self.isOnlyDaXiaoWang = data.isOnlyDaXiaoWang --可配参数 表示牌大小王单独连
    self.minNum = self.sameCount * self.minLength
    self.offset = self.sameCount
    self.isJiCardSeparate = data.isJiCardSeparate --可配参数 表示主副级别牌是否需断开(即主副级别牌是否可连)
    self.isSameColor = data.isSameColor
end

function LineBase2:check(data)
    local cardList = self:getValidCard(data.outCardInfo.cardList)
    if #cardList ~= #data.outCardInfo.cardList then
        return false
    end

    if self.isSameColor then
        local color = CardUtils.getLogicColor(data.ruleDao, cardList[1])
        for i = 2, #cardList do
            if CardUtils.getLogicColor(data.ruleDao, cardList[i]) ~= color then
                return false
            end
        end
    end


    if math.fmod(#cardList, self.sameCount) ~= 0 then
        return false;
    end

    local cardStack = new(CardStack, {cards = cardList})

    for _, card in pairs(cardList) do
        local normalByte = Card.getNormalByte(card)
        local curCount = cardStack:getNumberByByte(normalByte)
        if curCount ~= self.sameCount then
            return false
        end
        --如果大小王单独成连，则判断是否只有大王和小王
        if self.isOnlyDaXiaoWang and card.color == 4 then
            for i,v in ipairs(cardList) do
                --存在不是大小王的牌
                if v.color ~= 4 then
                    return false;
                end
            end
        end
    end

    --如果存在固定长度要求，则检查牌张数
    if self.fixedLength and #cardList ~= self.fixedLength then
        Log.i("牌张数不符合要求，要求"..self.fixedLength.."张，现在牌有"..#cardList.."张")
        return false;
    end
    if #cardList < self.sameCount * self.minLength then
        return false
    end

    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})

    assert(self.sameCount,"必须调用init方法初始化sameCount");
    assert(self.minLength,"必须调用init方法初始化minLength");

    local minLength = #cardList / self.sameCount;
    local minSize = self.sizeToByte.minSize;
    local maxSize = self.sizeToByte.maxSize;
    local mainValue = data.ruleDao:getMainValue()
    -- Log.i("minSize",minSize)
    -- Log.i("maxSize",maxSize)

    local checkOneMap = function(curSize)
        -- Log.i("checkOneMap "..curSize)
        local curLength = 0;

        local checkIsBothJiCard = function (curSize,npSize)
            local curBytes = self.sizeToByte[curSize]
            local npBytes = self.sizeToByte[npSize]
            local curValue = Card.new(curBytes[1]).value
            local npValue = Card.new(npBytes[1]).value
            if curValue == npValue and mainValue == curValue then
                return true
            end 
        end

        local checkMeetSameCount = function(size,callBack)
            local bytes = self.sizeToByte[size];
            -- local bb = {}
            -- for i,by in ipairs(bytes) do
            --     local val = Card.ByteMap:getValueByKey(by)
            --     table.insert(bb,val)
            -- end
            -- Log.i("curSize",size)
            -- Log.i("curSize   bytes--------------- ",size,bb)
            for i,byte in ipairs(bytes) do
                local curCount = cardStack:getNumberByByte(byte);
                -- dump("curCount------------ "..curCount.." *** "..byte)
                if curCount == self.sameCount then
                    if callBack then
                        callBack();
                    end
                    break;
                else
                end
            end
        end

        local findOne = false;
        checkMeetSameCount(curSize,function()
             findOne = true;
             curLength = curLength + 1;
        end)

        -- 如果在当前的大小里面找到一对才继续检查左右两边的
        if findOne then
            -- Log.i("curLength",curLength)
            -- Log.i("LineBase2,find one",curSize)
            if curLength >= minLength then
                return true;
            end
            local preSize = curSize - 1;
            local nextSize = curSize + 1;
            local hasPrePair = false;
            local hasNextPair = false;
            local goPre = true;
            local goNext = true;
            while curLength < minLength do
                -- dump("enter while")
                if goPre and preSize >= minSize then
                    checkMeetSameCount(preSize,function()
                        -- Log.i("has pre  ",preSize)
                        curLength = curLength + 1;
                        hasPrePair = true;
                    end)
                    if self.isJiCardSeparate and hasPrePair and checkIsBothJiCard(curSize,preSize) then
                        return false;
                    end
                end
                if goNext and nextSize <= maxSize then
                    checkMeetSameCount(nextSize,function()
                        -- Log.i("has next  ",nextSize)
                        curLength = curLength + 1;
                        hasNextPair = true;
                    end)
                    if self.isJiCardSeparate and hasNextPair and checkIsBothJiCard(curSize,nextSize) then
                        return false;
                    end
                end
                if hasPrePair then
                    preSize = preSize - 1;
                    hasPrePair = false;
                else
                    goPre = false;
                end
                if hasNextPair then
                    nextSize = nextSize + 1;
                    hasNextPair = false;
                else
                    goNext = false;
                end
                if not goPre and not goNext then
                    break;
                end
                -- if curLength >= self.minLength then
                --     Log.i("preSize,nextSize",preSize,nextSize)
                -- end
            end
            -- dump("LineBase2,find ".. curLength)
            return curLength == minLength;
        end
        return false;
    end

    for i=minSize,maxSize do
        local res = checkOneMap(i);
        if res then
            data.outCardInfo.cardByte = data.outCardInfo.cardList[1].byte;
            data.outCardInfo.cardType = self.uniqueId
            return true;
        end
    end

    return false;
end

function LineBase2:compare(data)
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
    local outCardList = data.outCardInfo.cardList
    local targetCardList = data.targetCardInfo.cardList
    if #outCardList ~= #targetCardList then
        return false
    end
    local outCardByte = data.outCardInfo.cardByte
    local tagetCardByte = data.targetCardInfo.cardByte
    Log.i("比较",outCardByte)
    Log.i("比较2",tagetCardByte)
    return self.byteToSize[outCardByte] > self.byteToSize[tagetCardByte]
end

function LineBase2:find(data)
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

        if self.isOnlyDaXiaoWang then --大小王单独成连
            for _,card in ipairs(resultList) do
                if card.color == 4 then
                    for i,v in ipairs(resultList) do
                        if v.color ~= 4 then
                            return false;
                        end
                    end
                    break;
                end
            end
        end

        if self.isJiCardSeparate then
            local mainValue = data.ruleDao:getMainValue()
            local hasJiCard = false
            for i = 1,#resultList,self.sameCount do
                local value = resultList[i].value 
                if hasJiCard and mainValue == value then
                    return false
                elseif value == mainValue then
                    hasJiCard = true
                end
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

    local checkMeetSameCount = function(size,callBack)
        local bytes = self.sizeToByte[size];
        if bytes then
            -- dump("size--------------- "..size)
            for i,byte in ipairs(bytes) do
                local curCount = cardStack:getNumberByByte(byte);
                -- dump("curCount------------ "..curCount.." *** "..byte)
                if curCount >= self.sameCount then
                    local cards = cardStack:getCardsByByte(byte);
                    cards = table.selectall(cards, function (i,v)
                        return i <= self.sameCount
                    end)
                    if callBack then
                        callBack(cards);
                    end
                    break;
                end
            end
        end
    end

    local function findFromOneMap(curSize,targetCardByte,length,queue)
        local change = nil;
        local curLength = 0;
        local resultList = {};
        if queue == 1 then
            change = 1
        else
            change = -1
        end

        local canGoNext = false;
        local csize = curSize;
        while true do
            checkMeetSameCount(csize,function(cards)
                canGoNext = true;
                curLength = curLength + 1;
                if queue == 1 then
                    for i,card in ipairs(cards) do
                        table.insert(resultList,1,card);
                    end
                else
                    table.copyTo(resultList,cards);
                end
            end);
            csize = csize + change;
            if not canGoNext then
                break;
            else
                canGoNext = false;
            end
            if self.fixedLength then
                if curLength * self.sameCount == self.fixedLength then
                    return dealResult(resultList);
                end
            end
            if length then
                if curLength * self.sameCount == length then
                    return dealResult(resultList);
                end
            end
        end
        if not length and curLength >= self.minLength then
            return dealResult(resultList);
        end
    end

    local minSize = self.sizeToByte.minSize;
    local maxSize = self.sizeToByte.maxSize;
    local minIndex = minSize;
    local length  = (data.targetCardInfo and data.targetCardInfo.cardList) and #data.targetCardInfo.cardList or nil
    local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
    if cardByte then
        --有需要压过的牌点大小
        local size = self.byteToSize[cardByte];
        if size < minSize or size > maxSize then
            return;
        end
        minIndex = size;
    end
    if data.queue == 0 then
        -- 从大到小找牌
        for i=maxSize,minIndex+1,-1 do
            local res,left = findFromOneMap(i,cardByte,length,data.queue);
            if res then
                return res,left;
            end
        end
    else
        -- 从小到大找牌
        for i=minIndex,maxSize do
            local res,left = findFromOneMap(i,cardByte,length,data.queue);
            if res then
                return res,left
            end
        end
    end
end

return LineBase2