--[[--ldoc desc
@module paixing_1574_3
@author JansonHuang

Date   2018-03-26 15:30:54
Last Modified by   JansonHuang
Last Modified time 2018-04-09 15:58:41
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
七大调
含7-8张牌点相同的牌型
]]

function M:ctor(data,ruleDao)
    assert(self.args,"缺少七大调参数")
    assert(#self.args == 3,"七大调参数长度不对")
    self.minLength = tonumber(self.args[1]);
    self.maxLength = tonumber(self.args[2]);
    self.defaultLength = tonumber(self.args[3]);--默认出几张牌
end

function M:check(data)
    local cardList = self:getValidCard(data.outCardInfo.cardList)
    if #cardList ~= #data.outCardInfo.cardList then
        return false
    end

    if #cardList < self.minLength or #cardList > self.maxLength then
        -- Log.v("七大调：超出了规定长度，不符合")
        return false;
    end

    local cardStack = new(CardStack, {cards = cardList});
    local card = cardList[1];
    local cardCount = cardStack:getNumberByValue(card.value);
    if cardCount ~= #cardList then
        Log.v(cardCount);
        -- Log.v("七大调：存在两个以上的牌点，不符合")
        return false;
    end
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao});
    data.outCardInfo.cardByte = data.outCardInfo.cardList[1].byte;
    return true
end

function M:compare(data)
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
    local outCardList = data.outCardInfo.cardList
    local targetCardList = data.targetCardInfo.cardList
    if #outCardList ~= #targetCardList then
        return false
    end
    local outCardByte = data.outCardInfo.cardByte
    local targetCardByte = data.targetCardInfo.cardByte
    Log.i("比较",outCardByte,targetCardByte)
    return self.byteToSize[outCardByte] > self.byteToSize[targetCardByte]
end

function M:find(data)
    local cardStack = data.srcCardStack;
    local recordList = {};
    local findList = {};

    for _,card in ipairs(cardStack:getCardList()) do
        local val = card.value;
        if not recordList[val] then
            recordList[val] = {}
        end
        table.insert(recordList[val],card)
    end

    for k,arr in pairs(recordList) do
        if #arr >= self.minLength then
            table.insert(findList,{cardList = arr,value = k});
        end
    end
    -- 排序
    local function sort(data)
        table.sort(data.cardList, function(c1, c2)
            local s1 = self.byteToSize[c1.byte]
            local s2 = self.byteToSize[c2.byte]
            if s1 == s2 then
                return Card.getNormalByte(c1) > Card.getNormalByte(c2)
            end
            return s1 > s2
        end)
    end

    for i,v in ipairs(findList) do
        sort(v)
        -- 如果牌张数超过了最大限制，则去掉尾牌
        if #v.cardList > self.maxLength then
            v.cardList = table.selectall(v.cardList,function(k,val)
                if k <= self.maxLength then
                    return true
                end
            end)
        end
        v.cardByte = v.cardList[1].byte
    end
    -- Log.v("findList",findList)
    table.sort(findList,function(a,b)
        if a.cardByte < b.cardByte then
            return true
        end
    end)

    --统一处理返回结果
    local function dealResult(resultList)
        --TODO：是否统一排序
        if not resultList then
            return
        end

        return
            {
                cardList = resultList,
                cardByte = resultList[1].byte,
                cardType = self.uniqueId,
            }
    end

    local function findOne(index,length)
        if findList and findList[index] then
            if length then
                if #findList[index].cardList < length then
                    -- Log.v("手牌的数量小于要压的牌的数量")
                    return false;
                elseif #findList[index].cardList == length then
                    return dealResult(findList[index].cardList);
                else
                    findList[index].cardList = table.selectall(findList[index].cardList,function(k,val)
                        if k <= length then
                            return true
                        end
                    end)
                    return dealResult(findList[index].cardList);
                end

            else
                return dealResult(findList[index].cardList);
            end
        end
        return false
    end

    local minIndex = 1;
    local maxIndex = #findList;
    local length  = (data.targetCardInfo and data.targetCardInfo.cardList) and #data.targetCardInfo.cardList or nil
    local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
    if cardByte then
        --有需要压过的牌点大小
        -- Log.v("有需要压过的牌点大小",cardByte)
        local hasLarger = false;
        for i,v in ipairs(findList) do
            if v.cardByte > cardByte then
                minIndex = i;
                hasLarger = true;
                break;
            end
        end
        if hasLarger == false then
            -- Log.v("没有找到能压的过的牌")
            return;
        end
    end
    if data.queue == 0 then
        -- 从大到小找牌
        for i=maxIndex,minIndex,-1 do
            local res,left = findOne(i,length);
            if res then
                return res;
            end
        end
    else
        -- 从小到大找牌
        for i=minIndex,maxIndex do
            local res,left = findOne(i,length);
            if res then
                return res;
            end
        end
    end
end

return M;