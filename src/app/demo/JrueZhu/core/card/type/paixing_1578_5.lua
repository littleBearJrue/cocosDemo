-- @Author: LisaChen
-- @Date:   2017-11-27 11:37:41
-- @Last Modified by   LisaChen
-- @Last Modified time 2018-09-04 13:10:57

local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
	上一出牌是【三炸/四炸】时，【2】张【4】
参数说明：   
	self._args =  {[1] = '三炸/四炸',[2] = 2,[3] = 4,}
]]
function M:ctor(data,ruleDao)
	local args = table.copyTab(data.typeRule.args)
	self._args = args
end

-- 添加了牌型环境的找牌算法
function M:check(data)
	local targetCardInfos = data.ruleDao:getGameData("c_lastPlayCardRecord")
	--targetCardInfos = {{cardByte = 35,cardList = { 0x04,0x04,0x14,0x24 },cardType = 5, opCode = 2, opData = { 0x04,0x04,0x14,0x24 },uid = 2}} -- 牌型文件测试的时候打开
	if next(targetCardInfos) == nil then -- 没有压制牌型
		return false
	end
	-- 寻找最后一个出牌玩家
	local targetCardInfo
	for i = #targetCardInfos, 1, -1 do
		if targetCardInfos[i].opData and next(targetCardInfos[i].opData) ~= nil then
			targetCardInfo = targetCardInfos[i]
			break
		end
	end

	if targetCardInfo then
		local patternNames = string.split(self._args[1], "/")
		for _,v in ipairs(patternNames) do
			local cardType = data.ruleDao:getCardRuleByName(v)
			local cardTypeId = tonumber(cardType.uniqueId)
			if targetCardInfo.cardType == cardTypeId then -- 如果检测到是压[三炸/四炸]牌型时
				return self:check2(data)
			end
		end
	end
	return false
end

-- 对子的找牌算法，因为牌点限制，不会找其他的牌，类似TongZhangcheck
function M:check2(data)
	local outCardList,invalidCardList = self:getValidCard(data.outCardInfo.cardList)
	local totalList =  data.outCardInfo.cardList
	if self.enableLaiZi ~=1 and  #outCardList ~= #data.outCardInfo.cardList then
		return false
	end

	if self.enableLaiZi == 1 and (#outCardList + #invalidCardList)~= #data.outCardInfo.cardList or #outCardList == 0 then 
		return false
	end

	local cardByte = 0
	if self.enableLaiZi ~= 1 then
		local value = outCardList[1].value
		if #outCardList ~= self._args[2] then 
			return false 
		end
		for k,v in pairs(outCardList) do 
			if v.value ~= value then
				return false 
			end
		end
		cardByte = outCardList[1].byte
	else
		for i,card in ipairs(invalidCardList) do 
			if not CardUtils.isLaizi(data.ruleDao,card) then
				return false
			end 
		end
		if #outCardList+#invalidCardList ~= self._args[2] then 
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

		for i,card in ipairs(totalList) do
			if CardUtils.isLaizi(data.ruleDao,card) then 
				if not CardUtils.isTargetLaizi(data.ruleDao,card,targetCard) then
					return false
				end
			else
				if card.value ~= value then
					return false 
				end
			end 
		end
	end 

	data.outCardInfo.size = self.sortRule.args
	data.outCardInfo.byteToSize = self.byteToSize
	data.outCardInfo.cardByte = cardByte;
	return true;
end

function M:compare(data)
	-- 没有相同牌型可以压，牌型的唯一组合
	return false
end

function M:find(data)
	local function hasSpecialTargetCardType()
		local targetCardInfos = data.ruleDao:getGameData("c_lastPlayCardRecord")
		-- targetCardInfos = {{cardByte = 35,cardList = { 0x04,0x04,0x14,0x24 },cardType = 5, opCode = 2, opData = { 0x04,0x04,0x14,0x24 },uid = 2}} -- 牌型文件测试的时候打开
		if next(targetCardInfos) ~= nil then -- 存在压制牌型
			-- 寻找最后一个出牌玩家
			for i = #targetCardInfos, 1, -1 do
				if targetCardInfos[i].opData and next(targetCardInfos[i].opData) ~= nil  then
					local patternNames = string.split(self._args[1], "/")
					for _,v in ipairs(patternNames) do
						local cardType = data.ruleDao:getCardRuleByName(v)
						local cardTypeId = tonumber(cardType.uniqueId)
						if targetCardInfos[i].cardType == cardTypeId then -- 如果检测到不是压[三炸/四炸]牌型时
							return true
						end
					end
				end
			end
		else
			return false
		end
	end
	
	local flag = hasSpecialTargetCardType() -- 记录是否压制对应牌型（判断是否保牌，false保牌，true正常压牌）
	Log.v("1111", flag)
	

	if not data.ignoreContext then -- 需要上下文环境语义，data.ignoreContext默认为nil，会走进来
		if not flag then
			return
		end
	end
	
	--查找原牌
	local args = self._args
	local laiziList = {}
	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	local queue = data.queue and data.queue or 0
	local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local outCardStack = new(CardStack,{cards = outCardList})
	local invalidCardStack = new(CardStack,{cards = invalidCardList})
	local targetLength = length or args[2]
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
	if self.enableLaiZi ~= 1 then 
		if length then
			if length < args[2] or length > args[2] then
				return
			end
		end

		if length and #outCardList < length then
			return 
		end

		if #outCardList < args[2] then
			return 
		end
	end

	local max = -1
	for i,v in pairs(map) do 
		if i>=max then 
			max = i
		end
	end
	local endi = queue == 0 and 1 or max
	local step = queue == 0 and -1 or 1

	--不用癞子的牌型直接走这里
	if self.enableLaiZi ~=1 then 
		for i = queue == 0 and max or 1,endi,step do
			if map[i] and #map[i]~=0 then
				local isBigger = true
				local checkList = {}

				if #map[i] >= targetLength then
					for j = 1,targetLength,1 do 
					    table.insert(checkList,map[i][j])
					end
				end

				local compareData = {
					ruleDao = data.ruleDao,
					targetCardInfo = data.targetCardInfo,
					outCardInfo = {cardList = checkList, cardByte = map[i][1].byte}	
				}
				if (data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList > 0) and not self:compare(compareData) then
					isBigger = false
				end
				if #checkList == targetLength and isBigger then
					returnList = checkList
					break
				end
			end
		end
	end

	--再去找补癞子的牌型
	if #returnList ==0 and self.enableLaiZi == 1 then
		for i = queue == 0 and max or 1,endi,step do
			if map[i] and #map[i]~=0 then
				local isBigger = true
				local checkList = {}
				if #map[i] >= targetLength then
					for j = 1,targetLength,1 do 
					    table.insert(checkList,map[i][j])
					end
				end				
				local compareData = {
					ruleDao = data.ruleDao,
					targetCardInfo = data.targetCardInfo,
					outCardInfo = {cardList = checkList, cardByte = map[i][1].byte}	
				}
				if (data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList > 0) and not self:compare(compareData) then
					isBigger = false
				end
				if #checkList == targetLength and isBigger then 
					returnList = checkList
					break
				elseif #map[i] + #laiziList >= targetLength and isBigger  then
					if CardUtils.isTargetLaizi(data.ruleDao,laiziList[1],map[i][1]) then 
						local dValue = targetLength - #map[i]
						for j = 1,#map[i] do 
							table.insert(returnList,map[i][j])
						end
						for j =1,dValue do 
							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],map[i][1]))
						end
						break
					end
				elseif (#map[i] + #laiziList + #exLaiZiList)>= targetLength and isBigger then
					if (not table.keyof(exLaiZiList,map[i][1])) or #exLaiZiList ~= #map[i]  then  ---确保该组的癞子牌没有重复使用
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
							local dValue = targetLength - #map[i] -#laiziList
							--插入原生组的牌
							for j = 1,#map[i] do 
								table.insert(returnList,map[i][j])
							end
							--插入只能当癞子组的牌
							for j,card in ipairs(laiziList) do 
								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,card,map[i][1]))
							end

							--插入即可当癞子也可当原生牌的牌
							for j = 1,dValue do
								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,tmpExLaiZiList[j],map[i][1]))
							end
							break
						end
					end
				end
			end
		end
	end

	if #returnList ~= 0 and #returnList == args[2] then  --表示找到了结果
	
	local uniqueId = self.uniqueId
	if data.ignoreContext and not flag then -- 定义了忽略前提条件且不是压制对应一些牌型（保牌部分非跟出压制【self._args[1]】牌型，设置一个无意义的牌型id）
		uniqueId = -1
	end

	return {	
		cardList = returnList,
		cardByte = returnList[1].byte,
		cardType = uniqueId,
	}

	end
end


return M;