-- @Author: LiangWang
-- @Date:   2018-01-29 17:50:14
-- @Last Modified by   KevinZhang
-- @Last Modified time 2018-03-08 17:38:35
local TongZhang = import("..base.TongZhang")
local M = class(TongZhang)


M.description = [[
四带二
4张牌点相同的的牌+任意2对。
]]

function M:ctor(data, ruleDao)
    --初始化4张同章
    local args = {4, 4}
    local args2 = {2, 2}

    self.mainType = new(TongZhang, data, ruleDao)
    self.mainType:init(args)
    self.subType = new(TongZhang, data, ruleDao)
    self.subType:init(args2)

    self.minNum = 8
end


function M:check(data)
    -- 首先校验输入的CardList的长度是否符合要求
    local size = #data.outCardInfo.cardList
    if size ~= 8 then
        return false
    end 
    -- 将手牌拆成两个对应的牌组 ，分别对应的主牌和副牌
    local mainCards = {}
    local comparedCard = nil
    -- 调用4同章的方法
    local findData = {}
    local cardStack = new(CardStack ,{cards = data.outCardInfo.cardList})
    findData.ruleDao = data.ruleDao
    findData.srcCardStack = cardStack
    mainCards  = self.mainType:find(findData)
    local subCards = nil
    local localCardStack = new (CardStack , {cards = findData.srcCardStack:getCardList()})
    if mainCards then
        localCardStack:removeCards(mainCards.cardList)
        subCards = localCardStack:getCardList()
        comparedCard = mainCards.cardList[1]
        for _, v in pairs(mainCards.cardList) do
            local mainCard = v
            for _, subCard in pairs(subCards) do
                if mainCard.value == subCard.value then
                    -- 副牌型与主牌型的牌点相同
                    return false
                end
            end
        end
        -- 验证副牌型是否为4同章
        local findSubData = {}
        local findSubCardStack = new(CardStack ,{cards = subCards})
        findSubData.ruleDao = data.ruleDao
        findSubData.srcCardStack = findSubCardStack
        local srcCards = nil
        local leftCards = nil
        srcCards = self.mainType:find(findSubData)
        if srcCards then
            -- 副牌的牌组为4同章
            return false 
        end
        -- 验证副牌型是否为2同章
        srcCards = self.subType:find(findSubData)
        if srcCards then
            findSubData.srcCardStack:removeCards(srcCards.cardList)
            srcCards = self.subType:find(findSubData)
            if not srcCards then 
                return false
            end
        end
        data.outCardInfo.size = self.sortRule.args
        data.outCardInfo.byteToSize = self.byteToSize
        data.outCardInfo.cardByte = comparedCard.byte
        return true 
    else
        return false
    end
end

-- 比较传入数据 ，两组手牌的大小
function M:compare(data)
    -- 还是比较两个数组长度是否符合标准
    -- 排序
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
    self:sort({cardInfo = data.targetCardInfo, ruleDao = data.ruleDao})
    -- 牌张数检测
    local outCardList = data.outCardInfo.cardList
    local targetCardList = data.targetCardInfo.cardList
    if #outCardList ~= #targetCardList then 
        return false
    end

    return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte]
end


-- 寻找
function M:find(data)
    local targetCardInfo = data.targetCardInfo
    if targetCardInfo then 
        local targetCardInfoCardStack = new(CardStack, {cards = targetCardInfo.cardList})
        local targetCardData = {
            ruleDao = data.ruleDao, 
            srcCardStack = targetCardInfoCardStack, 
        }
        local targetmainInfo = self.mainType:find(targetCardData)
        if targetmainInfo then 
            data.targetCardInfo = targetmainInfo
        end 
    end 
    local mainCards = self.mainType:find(data)
    local localCardStack = new(CardStack , {cards = data.srcCardStack:getCardList()})
    local otherCards = nil
    local subFindDataCardStack = nil
    if mainCards then 
        localCardStack:removeCards(mainCards.cardList)
        otherCards = {cardList = localCardStack:getCardList()}
        subFindDataCardStack = new(CardStack, {cards = otherCards.cardList})
        local subFindData = {}
        subFindData.ruleDao = data.ruleDao
        subFindData.srcCardStack = subFindDataCardStack
        local DoubleCards = {}
        local lastCards = {}
        while(true)do 
            local subFindCards = self.subType:find(subFindData)
            if not subFindCards then 
                break 
            end 
            subFindDataCardStack:removeCards(subFindCards.cardList)
            if #lastCards == 0 or lastCards[1].value ~= subFindCards.cardList[1].value then 
            table.insert(DoubleCards, subFindCards.cardList)
            lastCards = subFindCards.cardList
            end
        end 
        -- 将副牌型筛选剩余牌组倒序
        DoubleCards = self:reverseTable(DoubleCards)
        local subCards = {}
        -- 校驗
        for _index, cards in pairs(DoubleCards) do
            local mainCardValue = mainCards.cardList[1].value
            if mainCardValue ~= cards[1].value then 
                table.insert(subCards, cards[1])
                table.insert(subCards, cards[2])
            end 
            if #subCards >= 4 then 
                break
            end 
        end
        if #subCards < 4 then 
            return
        end 

        -- 确定找到的牌组
        for _, card in pairs(subCards) do
            table.insert(mainCards.cardList, card)
        end
        return {
            cardList = mainCards.cardList, 
            cardByte = mainCards.cardList[1].byte, 
            cardType = self.uniqueId
            }
    end
end


-- 逆序接口
function M:reverseTable(tab) 
    local tmp = {} 
    for i = 1, #tab do 
        local key = #tab 
        tmp[i] = table.remove(tab) 
    end 
    return tmp 
end 

return M
