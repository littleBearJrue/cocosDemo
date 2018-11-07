--[[--ldoc desc
@module TongZhangDaiPai
@author SeryZeng

Date   2018-03-19 15:41:50
Last Modified by   LucasZhen
Last Modified time 2018-07-20 12:27:03
]]
local TongZhang = import("..base.TongZhang")
local CardBase = import(".CardBase")
local M = class(CardBase)

--[[
	A张牌点相同的的牌+任意B张其它牌
	B牌点不能和A牌点相同，B牌点之间无限制
]]

function M:ctor(data, ruleDao)
	self.mainType = new(TongZhang, data, ruleDao)
end

--[[
    需先调用
    {同张数量，带牌数量}
]]
function M:init(data)
	self._args = {}
	self._args[1] = data[1]
	self._args[2] = data[2]

	self.mainType:init({self._args[1],self._args[1]})
	self.minNum = self._args[1] + self._args[2]
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
    	for _, subCard in pairs(findData.srcCardStack:getCardList(true)) do
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
		self:sortBySingleCardSize({cardInfo = {cardList = subCards.cardList}, ruleDao = tmpData.ruleDao})

        local subCardList = {}
        local mainCardValue = mainCards.cardList[1].value
        for i = #subCards.cardList, 1, -1 do
            if subCards.cardList[i].value ~= mainCardValue then 
                table.insert(subCardList,table.remove(subCards.cardList,i))
            end
            if #subCardList == self._args[2] then
            	break
            end
        end

        if #subCardList ~= self._args[2] then 
            return
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

--[[
	组牌 (调用一次，组一次牌型)
	reserveCards 	保牌数据
	mainTypeid		主牌型id
	subTypeid = {}	所有可拆的牌型id
	cardValue 		副牌型牌点限定(可不传，如果有则限定所有副牌牌点小于或等于该牌点)

	返回:
	组牌结果，拆牌后重新保牌结果，与保牌数据结构一致，
	return {[组牌id] = {单个组牌},[拆后重新保牌id] = {}}
]]
function M:combination(data)
    local reserveCards = clone(data.reserveCards) 
    local mainTypeid = data.mainTypeid
    local subTypeid = data.subTypeid
    local cardValue = data.cardValue
    local limits = data.limits
    if cardValue then
        cardValue = Card.ValueMap:getKeyByValue(tostring(cardValue))
    end 

    -- 判断主牌型是否存在
    if not reserveCards[mainTypeid] or #reserveCards[mainTypeid] == 0 then
    	return false
    end

    -- 当主牌型有多个时，从小到大的顺序获取
    if #reserveCards[mainTypeid] == 0 then
    	return false
    end
    local mainCard = table.remove(reserveCards[mainTypeid])
    -- 需要进行保牌的牌组
    local needProtectedCard = {}
    -- 找到的副牌
    local subCards = {}
    -- 遍历副牌型所持有的牌型id
    for _, cardType in pairs(subTypeid) do
        self:_findOneType(reserveCards[cardType], mainCard, cardValue, subCards, needProtectedCard, self._args[2],limits)
        if #subCards == self._args[2] then
        	break
        end
    end 

    if #subCards ~= self._args[2] then
    	return false
    end
    
    for k,v in pairs(reserveCards) do
	    data.reserveCards[k] = v
    end

    -- 返回的保数据
    local protectedData = {}

    -- 对拆分结果进行重新的保牌，按照需要保牌的规则id顺序进行保牌
    if #needProtectedCard > 0 then
	    local findData = {ruleDao = self.ruleDao, srcCardStack = new(CardStack,{cards = needProtectedCard})}
	    -- 对牌型进行逆序
	    for i = #subTypeid, 1, -1 do --{6,5,4,3,2,1}
	        protectedData[subTypeid[i]] = {}
	        while true do
	            if findData.srcCardStack:getNumber() == 0 then
	                break
	            end
	            local cardTypeObj = self.ruleDao:getCardRuleById(subTypeid[i])
	            local resultData = cardTypeObj:find(findData)
	            if resultData then
	                findData.srcCardStack:removeCards(resultData.cardList)
                    findData.srcCardStack = new(CardStack,{cards = findData.srcCardStack:getCardList()})
	                table.insert(protectedData[subTypeid[i]], resultData)
	            else
	                break
	            end
	        end
	    end
	end

	-- 副牌排序
	self:sort({cardInfo = {cardList = subCards}, ruleDao = data.ruleDao})

	-- 构造组合牌
    for _, card in pairs(subCards) do
        table.insert(mainCard.cardList, card)
    end
    protectedData[self.uniqueId] = {}
    local combinationData = {
        cardList = mainCard.cardList, 
        cardByte = mainCard.cardList[1].byte, 
        cardType = self.uniqueId
    }

    table.insert(protectedData[self.uniqueId], combinationData)
    --返回对应的保牌结果
    return protectedData
end

-- 找和主牌型不同牌点的单牌
function M:_findOneType(cardInfoList, mainCard, limitValue, subCards, needProtectedCard, subCardNum,limits)
	if cardInfoList then
		local mainCardValue = mainCard.cardList[1].value
		for i = #cardInfoList, 1, -1 do
			local hasRemove = false
			for j = #cardInfoList[i].cardList, 1, -1 do
				local card = cardInfoList[i].cardList[j]
                -- 校验是否符合规则
                local isCheck = mainCardValue ~= card.value and (not limitValue or card.value <= limitValue)
                if limits then 
                    if table.keyof(limits,card.byte) then
                        isCheck = false 
                    end
                end
                if isCheck then 
                    -- 将符合规则的牌添加到副牌型牌组当中
                    table.insert(subCards, card)
                    table.remove(cardInfoList[i].cardList,j)

                    hasRemove = true
                    if subCardNum == #subCards then
                    	break
                    end
                end
            end

            -- 判断当前的cardInfo是否有剩余
            if hasRemove then
                if #cardInfoList[i].cardList > 0 then 
                    --有剩余，代表该CardInfo剩余的Card要被重新保牌
                    for _, card in pairs(cardInfoList[i].cardList) do
                        table.insert(needProtectedCard, card)
                    end
                end 
                -- 从原有的保牌结果中删除
                table.remove(cardInfoList, i)
            end

            if subCardNum == #subCards then
                break
            end 
		end
	end
end

return M
