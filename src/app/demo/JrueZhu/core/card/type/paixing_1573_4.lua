--[[--ldoc desc
@module paixing_1573_4
@author AmyGuo

Date   2018-05-15 10:54:34
Last Modified by   AmyGuo
Last Modified time 2018-06-19 15:22:51
]]

local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local TongZhang = import("..base.TongZhang")
local M = class(CardBase)

--[[
    3张牌点相同的牌算一组牌，2组牌起连 连牌顺序【3-4-5-6-7-8-9-10-J-Q-K】不区分花色  
    1张<=总共可带<(每组牌带 2 张牌之和)
]]


--  ["args"] = 
--  {
--     [1] = 2,
--     [2] = '3-4-5-6-7-8-9-10-J-Q-K',
--     [3] = 2,
-- },

function M:ctor(data, ruleDao)
    self.mainType = new(LineBase, data, ruleDao)
    self:init()
end

--[[
    需先调用
    sameCount 相同牌张数
    minLength 牌组数
    lineArgs  连牌
    carryCount 每组牌带牌数量
]]
function M:init()
    self._args = {}
    self._args["sameCount"] = 3
    self._args["minLength"] = self.args[1]
    self._args["lineArgs"]  = self.args[2]
    self._args["carryCount"]= self.args[3]

    self.mainType:init(self._args)
    self.minNum = (self._args.sameCount + self._args.carryCount) * self._args.minLength
    self.offset = self._args.sameCount + self._args.carryCount
end

function M:check(data)
	self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})

    -- 找主牌型
    local findData = {}
    findData.ruleDao = data.ruleDao
    findData.srcCardStack = new(CardStack,{cards = data.outCardInfo.cardList})

    local mainCards = self.mainType:find(findData)

    if mainCards then
        findData.srcCardStack:removeCards(mainCards.cardList)
        local subCardsNum = findData.srcCardStack:getNumber()

    	if not ( subCardsNum > 0 and  (#mainCards.cardList / self._args.sameCount) >= self._args.minLength and 
            subCardsNum < (#mainCards.cardList / self._args.sameCount) * self._args.carryCount ) then
    		return false
    	end

        data.outCardInfo.size = self.sortRule.args
        data.outCardInfo.byteToSize = self.byteToSize
        data.outCardInfo.cardByte = mainCards.cardList[1].byte
        data.outCardInfo.groupLenght = #mainCards.cardList / self._args.sameCount
        return true
    end
    return false 
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

    if not tmpData.targetCardInfo then 
        return
    end
    -- 从压牌里面找主牌型
    local targetLength = #tmpData.targetCardInfo.cardList
    local targetCardInfo = tmpData.targetCardInfo
    if targetCardInfo then 
        local targetCardData = {
            ruleDao = tmpData.ruleDao, 
            srcCardStack = new(CardStack,{cards = targetCardInfo.cardList})
        }
        local targetmainInfo = self.mainType:find(targetCardData)
        if targetmainInfo then 
            tmpData.targetCardInfo = targetmainInfo
        end 
    end 

    local mainCards = self.mainType:find(tmpData)
    if mainCards then
        tmpData.srcCardStack:removeCards(mainCards.cardList)
        local subCards = tmpData.srcCardStack:getCardList()
    	-- 排序
		self:sort({cardInfo = {cardList = subCards}, ruleDao = tmpData.ruleDao})

        local subCardList = {}
        -- 副牌从小到大
        for i = #subCards, 1, -1 do
        	-- 副牌可以和主牌牌点相同
            table.insert(subCardList,table.remove(subCards,i))
        end
        local fupaiNum = targetLength - #tmpData.targetCardInfo.cardList
        if #subCardList < fupaiNum then 
            return 
        end 

        -- 保持从大到小排序
        for i = 1, fupaiNum do
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
-- function M:combination(data)
--     local reserveCards = clone(data.reserveCards) 
--     local mainTypeid = data.mainTypeid
--     local subTypeid = data.subTypeid
--     local cardValue = data.cardValue
--     if cardValue then
--         cardValue = Card.ValueMap:getKeyByValue(tostring(cardValue))
--     end 

--     -- 判断主牌型是否存在
--     if not reserveCards[mainTypeid] or #reserveCards[mainTypeid] == 0 then
--     	return false
--     end

--     -- 当主牌型有多个时，从小到大的顺序获取
--     if #reserveCards[mainTypeid] == 0 then
--     	return false
--     end
--     local mainCard = table.remove(reserveCards[mainTypeid])
--     -- 需要进行保牌的牌组
--     local needProtectedCard = {}
--     -- 找到的副牌
--     local subCards = {}
--     local subCardsNum = (#mainCard.cardList / self._args.sameCount) * self._args.carryCount
--     -- 遍历副牌型所持有的牌型id
--     for _, cardType in pairs(subTypeid) do
--         --单牌>对子>三条>连对>顺子>飞机
--         self:_findOneType(reserveCards[cardType], mainCard, cardValue, subCards, needProtectedCard, subCardsNum)
--         if #subCards == subCardsNum then
--         	break
--         end
--     end 

--     if #subCards ~= subCardsNum then
--     	return false
--     end
    
--     for k,v in pairs(reserveCards) do
-- 	    data.reserveCards[k] = v
--     end

--     -- 返回的保数据
--     local protectedData = {}

--     -- 对拆分结果进行重新的保牌，按照需要保牌的规则id顺序进行保牌
--     if #needProtectedCard > 0 then
-- 	    local findData = {ruleDao = self.ruleDao, srcCardStack = new(CardStack,{cards = needProtectedCard})}
-- 	    -- 对牌型进行逆序
-- 	    for i = #subTypeid, 1, -1 do --{6,5,4,3,2,1}
-- 	        protectedData[subTypeid[i]] = {}
-- 	        while true do
-- 	            if findData.srcCardStack:getNumber() == 0 then
-- 	                break
-- 	            end
-- 	            local cardTypeObj = self.ruleDao:getCardRuleById(subTypeid[i])
-- 	            local resultData = cardTypeObj:find(findData)
-- 	            if resultData then
--                     findData.srcCardStack:removeCards(resultData.cardList)
-- 	                findData.srcCardStack = new(CardStack,{cards = findData.srcCardStack:getCardList()})
-- 	                table.insert(protectedData[subTypeid[i]], resultData)
-- 	            else
-- 	                break
-- 	            end
-- 	        end
-- 	    end
-- 	end

-- 	-- 副牌排序
-- 	self:sort({cardInfo = {cardList = subCards}, ruleDao = data.ruleDao})

-- 	-- 构造组合牌
--     for _, card in pairs(subCards) do
--         table.insert(mainCard.cardList, card)
--     end
--     protectedData[self.uniqueId] = {}
--     local combinationData = {
--         cardList = mainCard.cardList, 
--         cardByte = mainCard.cardList[1].byte, 
--         cardType = self.uniqueId
--     }

--     table.insert(protectedData[self.uniqueId], combinationData)
--     --返回对应的保牌结果
--     return protectedData
-- end


-- -- 某个牌型数据中找副牌
-- function M:_findOneType(cardInfoList, mainCard, limitValue, subCards, needProtectedCard, subCardNum)
-- 	if cardInfoList then
-- 		for i = #cardInfoList, 1, -1 do
-- 			local hasRemove = false
-- 			for j = #cardInfoList[i].cardList, 1, -1 do
-- 				local card = cardInfoList[i].cardList[j]
--                 -- 校验是否符合规则
--                 local isCheck = not limitValue or card.value <= limitValue
--                 if isCheck then 
--                     -- 将符合规则的牌添加到副牌型牌组当中
--                     table.insert(subCards, card)
--                     table.remove(cardInfoList[i].cardList,j)

--                     hasRemove = true
--                     if subCardNum == #subCards then
--                     	break
--                     end
--                 end
--             end

--             -- 判断当前的cardInfo是否有剩余
--             if hasRemove then
--                 if #cardInfoList[i].cardList > 0 then 
--                     --有剩余，代表该CardInfo剩余的Card要被重新保牌
--                     for _, card in pairs(cardInfoList[i].cardList) do
--                         table.insert(needProtectedCard, card)
--                     end
--                 end 
--                 -- 从原有的保牌结果中删除
--                 table.remove(cardInfoList, i)
--             end

--             if subCardNum == #subCards then
--                 break
--             end 
-- 		end
-- 	end
-- end

return M