-- @Author: JanzenWang
-- @Date:   2018-08-27 17:19:29
-- @Last Modified by:   JanzenWang
-- @Last Modified time: 2018-08-27 18:07:13


local CardBase = import("..base.CardBase")
local M = class(CardBase)


M.bindingData = {
	set = {},
	get = {},
}

M.description = [[
功能描述说明：
	牌型：[1]张牌点相同的的牌，至少包含[2]张癞子牌
	特征：牌点相同的N张牌，不区分花色

	必须启用癞子
]]
function M:ctor(data,ruleDao)
	local args = table.copyTab(data.typeRule.args)

	self.length = args[1]
	self.limitLaiZiNum = args[2]

end



function M:check(data)

	local outCardList,invalidCardList = self:getValidCard(data.outCardInfo.cardList)
	local totalList =  data.outCardInfo.cardList
	if self.enableLaiZi ~= 1 then
		return false
	end

	if (#outCardList + #invalidCardList) ~= #data.outCardInfo.cardList or #outCardList == 0 then 
		return false
	end

	local cardByte = 0

	for i,card in ipairs(invalidCardList) do 
		if not CardUtils.isLaizi(data.ruleDao,card) then
			return false
		end 
	end

	if #outCardList+#invalidCardList ~=  self.length then 
		return false 
	end

	--先对outCardList进行牌值降序排序
	table.sort(outCardList,function(a,b)
		return a.value>b.value
	end)

	--首先找到outCardList中的第一张非癞子牌做为原生牌
	local value = nil
	local targetCard = nil 
	for i,card in ipairs(outCardList) do 
		if not CardUtils.isLaizi(data.ruleDao,card) then 
			value = card.value
			cardByte = card.byte
			targetCard = card
			break
		end
	end
	--如果都是癞子牌，则取牌点最大的牌做为原生牌
	if not value then
		targetCard = outCardList[1]
		value = outCardList[1].value
		cardByte = outCardList[1].byte
	end
	local count = 0;
	for i,card in ipairs(totalList) do
		if CardUtils.isLaizi(data.ruleDao,card) then 
			count = count + 1;
			if not CardUtils.isTargetLaizi(data.ruleDao,card,targetCard) then
				return false
			end
		else
			if card.value ~= value then
				return false 
			end
		end 
	end

	if count < self.limitLaiZiNum then
		return false;
	end

	data.outCardInfo.size = self.sortRule.args
	data.outCardInfo.byteToSize = self.byteToSize
	data.outCardInfo.cardByte = cardByte;

	return true;
end

function M:compare(data)
	self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
	self:sort({cardInfo = data.targetCardInfo, ruleDao = data.ruleDao})
	local outCardList = data.outCardInfo.cardList
	local targetCardList = data.targetCardInfo.cardList
	if #outCardList == #targetCardList then 
		return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte]
	elseif #outCardList > #targetCardList then
		return true
	end
	return false
end

function M:find(data)
	--查找原牌
	local laiziList = {}
	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	local queue = data.queue and data.queue or 0
	local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local outCardStack = new(CardStack,{cards = outCardList})
	local invalidCardStack = new(CardStack,{cards = invalidCardList})
	local targetLength = length or self.length
	local returnList = {}
	local map = outCardStack:getValueMap()

	local temp = clone(map)
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
	map = newMap


	--对map中的元素排序，优先使用非癞子牌
	if self.enableLaiZi == 1 then 
		for i,item in pairs(map) do 
			for _,card in ipairs(item) do 
				table.sort(item,function (a,b)
					return a.flag < b.flag
				end)
			end
		end
	end
	
	local laiziList = CardUtils.getLaiZiList(data.ruleDao,invalidCardList) --只可做癞子牌的癞子
	local exLaiZiList = CardUtils.getLaiZiList(data.ruleDao,outCardList) 	--可以做原生牌或者癞子牌的癞子



	if self.enableLaiZi ~= 1 or (#laiziList + #exLaiZiList < self.limitLaiZiNum) then 
		return
	end

	local max = -1
	for i,v in pairs(map) do 
		if i>=max then 
			max = i
		end
	end
	local endi = queue == 0 and 1 or max
	local step = queue == 0 and -1 or 1

	--再去找补癞子的牌型
	for i = queue == 0 and max or 1,endi,step do
		if map[i] and #map[i]~=0 then
			local isBigger = true
			if cardByte and self.byteToSize[cardByte] >= self.byteToSize[map[i][1].byte] then
				isBigger = false
			end
			if #laiziList >= self.limitLaiZiNum and #map[i] + #laiziList >= targetLength and isBigger  then
				if CardUtils.isTargetLaizi(data.ruleDao,laiziList[1],map[i][1]) then 
					-- 首先插入规定数目的癞子
					for j = 1,self.limitLaiZiNum do
						table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],map[i][1]))
					end
					local dValue = targetLength - self.limitLaiZiNum
					-- 插入原生牌
					local limit = #map[i] > dValue and dValue or #map[i]
					for j = 1,limit do 
						table.insert(returnList,map[i][j])
					end

					-- 长度不够，癞子来凑
					if #returnList < targetLength then
						for j = 1,targetLength - #returnList do 
							j = j + self.limitLaiZiNum
							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],map[i][1]))
						end
					end
					break
				end
			elseif (#laiziList + #exLaiZiList) >= self.limitLaiZiNum and (#map[i] + #laiziList + #exLaiZiList)>= targetLength and isBigger then
				if (not table.keyof(exLaiZiList,map[i][1])) or #exLaiZiList ~= #map[i]  then  ---确保该组的癞子牌没有重复使用

					--TODO  这段代码根据逻辑写出，简单测试过，项目没用
					--      如果哪款游戏用到，请详细测试

					local tmpExLaiZiList = {}
						table.copyTo(tmpExLaiZiList, exLaiZiList)
					for j = #tmpExLaiZiList,1,-1 do 
						if tmpExLaiZiList[j] == map[i][1] then 
							table.remove(tmpExLaiZiList,j)
						end
					end
					local isCanInstead = false
					if laiziList[1] then 
						isCanInstead = CardUtils.isTargetLaizi(data.ruleDao,laiziList[1],map[i][1]) 
					end
					if tmpExLaiZiList[1] then 
						isCanInstead = CardUtils.isTargetLaizi(data.ruleDao,tmpExLaiZiList[1],map[i][1]) 
					end
					if isCanInstead then 

						local exLaiZiUseNum = 0;
						-- 首先插入规定数目的癞子
						local count = #laiziList > self.limitLaiZiNum and self.limitLaiZiNum or #laiziList
						for j = 1,count do
							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],map[i][1]))
						end

						if count < self.limitLaiZiNum then
							--插入即可当癞子也可当原生牌的牌
							exLaiZiUseNum = self.limitLaiZiNum - count
							for j = 1,exLaiZiUseNum do
								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,tmpExLaiZiList[j],map[i][1]))
							end
						end

						-- 插入原生牌
						local dValue = targetLength - self.limitLaiZiNum
						local num = #map > dValue and dValue or #map
						for j = 1, num do 
							table.insert(returnList,map[i][j])
						end

						if #returnList < targetLength then
							if #laiziList > self.limitLaiZiNum then
								for i = self.limitLaiZiNum + 1, #laiziList do 
									table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],map[i][1]))
								end
							end

							--插入即可当癞子也可当原生牌的牌
							dValue = targetLength - #returnList
							for j = exLaiZiUseNum + 1, dValue + exLaiZiUseNum do
								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,tmpExLaiZiList[j],map[i][1]))
							end	
						end
						break
					end
				end
			end
		end
	end

	if #returnList ~= 0 and #returnList == self.length then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		} 

	end
end

return M;
