--[[--ldoc desc
@module paixing_1571_1
@author SeryZeng

Date   2018-01-16 20:33:39
Last Modified by   LucasZhen
Last Modified time 2018-07-20 14:08:45
]]


local TongZhang = import ("..base.TongZhang")
local M = class(TongZhang)

M.description = [[
三带一
3张牌点相同的牌+任意1张其它牌
]]

function M:ctor(data, ruleDao)
    -- 初始化 3同章
    local args = {3, 3}
    self.mainType = new(TongZhang, data, ruleDao)
    self.mainType:init(args)
    self.ruleDao = ruleDao
    self.minNum = 4
end
function M:check(data)
    -- 先调用排序方法
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
    -- 首先先判断Cards数组的大小
    local size = #data.outCardInfo.cardList
    if size ~= 4 then
        return false
    end
    -- 将牌组数据拆成两个部分
    -- 主牌的Cards
    local mainCards = {}
    -- 能用于比大小的牌的对象
    local comparedCard = nil
    -- 调用3同章的find方法
    local findData = {}
    local srcCardStack = new(CardStack ,{cards = data.outCardInfo.cardList})
    findData.ruleDao = data.ruleDao
    findData.srcCardStack = srcCardStack
    mainCards = self.mainType:find(findData)
    local subCards = nil
    local localCardStack = new(CardStack,{cards = findData.srcCardStack:getCardList()})
    -- 副牌型的牌点不能够与主牌型的牌点相同
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
        data.outCardInfo.size = self.sortRule.args
        data.outCardInfo.byteToSize = self.byteToSize
        data.outCardInfo.cardByte = comparedCard.byte
        return true
    else
        return false
    end
end

function M:compare(data)
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


function M:find(data)
    local targetCardInfo = data.targetCardInfo
    if targetCardInfo then 
    -- 得到对应的cardStack对象
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
    local mainCards= self.mainType:find(data)
    local localCradStack = new(CardStack , {cards = data.srcCardStack:getCardList()})
    local subCards = nil
    if mainCards then
        localCradStack:removeCards(mainCards.cardList)
        subCards = localCradStack:getCardList()
        local subFindData = {}
        subFindData.ruleDao = data.ruleDao
        subFindData.srcCardInfo = {
            cardList = subCards
        }
	    -- 对副牌的牌组进行排序
        self:sortBySingleCardSize({cardInfo = subFindData.srcCardInfo, ruleDao = subFindData.ruleDao})
        -- 对牌组进行逆序
        local subData = self:reverseTable(subFindData.srcCardInfo.cardList)

        if self.enableLaiZi == 1 then
            --支持癞子的情况下,排序，优先使用非癞子
            local tmp = {}
            local i = 1
            local s,e = 1,#subData 
            while i <= #subData do
                if CardUtils.isLaizi(data.ruleDao,subData[i]) then 
                    tmp[e] = subData[i]
                    e = e-1
                else
                    tmp[s] = subData[i]
                    s = s+1
                end
                i = i+1
            end
            subData = tmp
        end
        local subCard = nil
        for _index, card in pairs(subData) do
            local mainCardValue = mainCards.cardList[1].value
            if card.value ~= mainCardValue then 
                subCard = table.remove(subData, _index)
                break
            end
        end
        -- 如果副牌型为空直接返回
        if not subCard then 
            return
        end 
        -- 返回所找到的牌 和 剩余牌组
        table.insert(mainCards.cardList, subCard)
        return 
            {
            cardList = mainCards.cardList, 
            cardByte = mainCards.cardList[1].byte, 
            cardType = self.uniqueId
            }
    end
end




-- 组牌 (调用一次，组一次牌型)
-- @ 根据主牌型、副牌型、保牌列表
-- @ data的相关数据结构
-- {
-- 所有的保牌数据
-- reserveCards ={}
-- 主牌型所持有的牌型id
-- mainTypeid 
-- 副牌型所持有的牌型id
-- subTypeid = {}
-- 特殊界限值
-- cardValue
-- }
function M:combination(data)
    -- 得到当前的保牌数据
    local reserveCards = data.reserveCards 
    -- 得到当前主牌型所持有的牌型id
    local mainTypeid = data.mainTypeid
    -- 得到当前副牌型所持有的牌型id
    local subTypeid = data.subTypeid
    -- 得到牌点的边界值
    local cardValue = data.cardValue or 18
    if cardValue ~= 18 then
        cardValue = Card.ValueMap:rget(cardValue .. "")
    end
    
    local limits = data.limits 
    -- 副牌型的牌组
    local subCards = {}
    -- 当前主牌型对应的牌组
    local mainCardsSize = nil
    if data.reserveCards[mainTypeid] and #data.reserveCards[mainTypeid] > 0 then 
        mainCardsSize = #data.reserveCards[mainTypeid]
    else
        return false
    end
    -- 因为当主牌型有多个的时候，是按照从小到大的顺序获取
    local mainCard = data.reserveCards[mainTypeid][mainCardsSize]

    -- 得到副牌型需要的牌的数量（这个参数自己算）(所有的数据都是存储在CardList)
    local subCardNum = 1
    local num = 1
    -- 从原始保牌数据中进行删除当前选中的主牌型牌组(删除最后一个)
    local deletCards = {}
    deletCards[mainTypeid] = table.remove(data.reserveCards[mainTypeid])
    -- dump(deletCards, "hahaha")
    -- 需要进行保牌的牌组
    local needProtectedCard = {}
    -- 遍历副牌型所持有的牌型id
    for _, cardType in pairs(subTypeid) do
        --单牌>对子>三条>连对>顺子>飞机
        --最外层的循环跳出判断
        if subCardNum == 0 then
            break 
        end
        local cardTypeid = cardType
        --得到对应的保牌结果
        local cardInfoList = data.reserveCards[cardType]
        --判断得到的保牌结果是否存在
        if cardInfoList then 
            --对所找到的保牌结果进行逆序
            cardInfoList = self:reverseTable(cardInfoList)
            local cloneCardList = clone(cardInfoList)
            -- cardInfo 指的是保牌出来的单个对象
            for _cardInfoIndex, cardInfo in pairs(cloneCardList) do
                local index = {}
                local isCheckSubCards = false
                --cardInfo.cardList 才是真正存放数据的地方
                for _index, card in pairs(cardInfo.cardList) do
                    -- 校验是否符合规则
                    local isCheck = self:subCardCheck(mainCard, card) and card.value <= cardValue
                    if limits then 
                        if table.keyof(limits,card.byte) then
                            isCheck = false 
                        end
                    end
                    
                    if isCheck then 
                        isCheckSubCards = true
                        -- 将符合规则的牌添加到副牌型牌组当中
                        table.insert(subCards, card)
                        -- -- 删除符合规则的牌
                        table.insert(index, _index)
                        -- 副牌型需要的牌的数量 - 1 
                        subCardNum = subCardNum - 1 
                        -- 判断当前的循环是否继续
                        if subCardNum == 0 then
                            break 
                        end
                    end 
                end

                index = self:reverseTable(index)
                for _, key in pairs(index) do
                    table.remove(cardInfo.cardList, key)
                end
                -- 判断当前的cardInfo是否有剩余
                if isCheckSubCards then
                    if #cardInfo.cardList > 0 then 
                        --有剩余，代表该CardInfo剩余的Card要被重新保牌
                        for _, card in pairs(cardInfo.cardList) do
                            -- Log.v("ssssss", card)
                            table.insert(needProtectedCard, card)
                        end
                    end 
                    -- 从原有的保牌结果中删除当前的CardInfo
                    -- Log.v("删除的索引" .. #cardInfoList - _cardInfoIndex + 1)
                    table.remove(data.reserveCards[cardTypeid], #cardInfoList - _cardInfoIndex + 1)
                end 
                -- 判断当前的循环是否继续
                if subCardNum == 0 then
                    break 
                end
            end 
        end 
    end 

    -- 对拆分结果进行重新的保牌，按照需要保牌的规则id顺序进行保牌
    local cardList = needProtectedCard
    local findSrcCardStack = new(CardStack ,{cards = cardList})
    local findData = {ruleDao = self.ruleDao, srcCardStack = findSrcCardStack}
    local protectedData = {}
    -- 对牌型进行逆序
    local protectedTyoeid = self:reverseTable(subTypeid)
    for i, type in ipairs(protectedTyoeid) do--{6,5,4,3,2,1}
        protectedData[type] = {}
        while true do
            if #findData.srcCardStack:getCardList() == 0 then
                break
            end
            local cardTypeObj = self.ruleDao:getCardRuleById(type)
            local resultData = cardTypeObj:find(findData)
            if resultData then
                findData.srcCardStack:removeCards(resultData.cardList)
                table.insert(protectedData[type], resultData)
            else
                break
            end
        end
    end
    -- 进行组牌
    if #subCards == 0 then 
        for key, list in pairs(deletCards) do
            table.insert(data.reserveCards[key], list)
        end
        -- dump(data.reserveCards, "组牌内部")
        return false
    end 
    if #subCards ~= 1 then 
        return false
    end 
    for _, card in pairs(subCards) do
        table.insert(mainCard.cardList, card)
    end
    protectedData[self.uniqueId] = {}
    local combinationData = {
        cardList = mainCard.cardList, 
        cardByte = mainCard.cardList[1].byte, 
        cardType = self.uniqueId

    }
    -- 
    table.insert(protectedData[self.uniqueId], combinationData)
    --返回对应的保牌结果
    return protectedData
end

-- 用于副牌型的牌型校验
function M:subCardCheck(mainCard, subCard) 
    for _, card in pairs(mainCard.cardList) do
        if card.value == subCard.value then
            --副牌型的牌点与主牌型的牌点相同
            return false
        end
    end
    return true
end 

-- 将牌组逆序
function M:reverseTable(tab) 
    local tmp = {} 
    for i = #tab, 1, -1 do 
        tmp[#tab - i + 1] = tab[i]
    end 
    return tmp 
end 

return M; 
