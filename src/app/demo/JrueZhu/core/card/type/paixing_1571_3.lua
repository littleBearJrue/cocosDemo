--[[--ldoc desc
@module paixing_1571_3
@author name

Date   2018-02-27 18:05:16
Last Modified by   JamesYang
Last Modified time 2018-07-27 15:41:57
]]


local TongZhangDaiPai = import ("..base.TongZhangDaiPai")
local M = class(TongZhangDaiPai)

M.description = [[
三带二
3张牌点相同的牌+任意2张对子
]]

function M:ctor(data, ruleDao)
    TongZhangDaiPai.init(self,{3,2,2})
end

function M:check(data)
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
    -- 长度判断
    local size = #data.outCardInfo.cardList
    if size ~= self.minNum then
        return false
    end

    -- 找主牌型
    local findData = {}
    findData.ruleDao = data.ruleDao
    findData.srcCardStack = new(CardStack,{cards = data.outCardInfo.cardList})
    local mainCards = self.mainType:find(findData)
    if mainCards then
        findData.srcCardStack:removeCards(mainCards.cardList)
        local subCardValue = 0;
        for _, subCard in pairs(findData.srcCardStack:getCardList(true)) do
            local fristValue = findData.srcCardStack:getCardList(true)[1].value;
            local curValue = subCard.value;
            if fristValue ~= curValue then
                Log.i("not same value" , fristValue , curValue)
                return false;
            end
            if mainCards.cardList[1].value == subCard.value then
                -- 副牌型与主牌型的牌点相同
                return false
            end
        end

        data.outCardInfo.size = self.sortRule.args
        data.outCardInfo.byteToSize = self.byteToSize
        data.outCardInfo.cardByte = mainCards.cardList[1].byte

        return true
    end
end


function M:find(data)
    local tmpData = clone(data)
    self:sort({cardInfo = {cardList = tmpData.srcCardStack:getCardList(true)}, ruleDao = tmpData.ruleDao})
    -- 先寻找主牌型对应的牌组
    local targetCardInfo = tmpData.targetCardInfo
    if targetCardInfo then 
        local targetCardData = {
            ruleDao = tmpData.ruleDao, 
            srcCardStack = new(CardStack, {cards = targetCardInfo.cardList})
        }
        local targetmainInfo = self.mainType:find(targetCardData)
        if targetmainInfo then 
            tmpData.targetCardInfo = targetmainInfo
        end 
    end 

    local mainCards = self.mainType:find(tmpData)
    if mainCards then
        -- 副牌从小到大
        tmpData.srcCardStack:removeCards(mainCards.cardList)
        local subCards = {cardList = tmpData.srcCardStack:getCardList()}

        local valueMap = tmpData.srcCardStack:getValueMap()

        -- self:sortBySingleCardSize({cardInfo = {cardList = subCards.cardList}, ruleDao = tmpData.ruleDao})
        local temp = clone(valueMap)
        local newMap = {}
        for i,cards in pairs(temp) do 
            if type(i) == "number" then 
                table.sort(cards,function (a,b)
                    return self.byteToSize[a.byte] > self.byteToSize[b.byte]
                end)
                table.insert(newMap,cards)
            end
        end
        
        table.sort(newMap,function (a,b)
            return self.byteToSize[a[1].byte] < self.byteToSize[b[1].byte] 
        end)

        local subCardList = {}
        local mainCardValue = mainCards.cardList[1].value
        for k,cards in ipairs(newMap) do
            local cardLen = #cards;
            if cardLen == self._args[2] then
                for k,v in pairs(cards) do
                    table.insert(subCardList,v);
                end
                break;
            end
            if #subCardList == self._args[2] then
                break;
            end
        end

        ---当有3张以上的牌型的时候
        if #subCardList == 0 then
            for k,cards in ipairs(newMap) do
                local cardLen = #cards;
                if cardLen > self._args[2] then
                    for i = 1 , self._args[2] do
                        local card = cards[i]
                        table.insert(subCardList,card);
                    end
                    break;
                end
                if #subCardList == self._args[2] then
                    break;
                end
            end
        end

        if #subCardList ~= self._args[2] then
            return;
        end

        for i = #subCardList, 1, -1 do
            table.insert(mainCards.cardList,subCardList[i])
        end

        return {
            cardList = mainCards.cardList, 
            cardByte = mainCards.cardList[1].byte, 
            cardType = self.uniqueId
        }

    end
end

return M; 