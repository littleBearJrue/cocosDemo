-- @Author: name
-- @Date:   2017-11-27 11:37:41
-- @Last Modified by   LucasZhen
-- @Last Modified time 2018-07-26 17:23:09

local CardBase = import(".CardBase")
local M = class(CardBase)

M.CMD = {
	C2S = {
	
	},
	S2C = {
	},
}

M.bindingData = {
	get = {},
	set = {},
}

M.description = [[
功能描述说明：
	寻找手牌中的同张，参数有三个，分别为：
	self.args = {[1]=最短数量，[2]=最长数量}
	继承CardBase,有三个函数，分别为：检验函数，比较函数，寻找函数

具体执行的操作说明：

读取数据说明：
	
写入数据说明：
	
推送消息说明：
]]

function M:ctor(data, ruleDao)

end

function M:init(data)
	self._args = {}
	self._args[1] = data[1] -----可配参数 
	self._args[2] = data[2] -----可配参数
	self.minNum = self._args[1]
end



function M:check(data)


	-- self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
	local outCardList,invalidCardList = self:getValidCard(data.outCardInfo.cardList)
	local totalList =  data.outCardInfo.cardList
	-- local cardList = self:getValidCard(data.outCardInfo.cardList)
	if self.enableLaiZi ~=1 and  #outCardList ~= #data.outCardInfo.cardList then
		return false
	end

	if self.enableLaiZi == 1 and (#outCardList + #invalidCardList)~= #data.outCardInfo.cardList or #outCardList == 0 then 
		return false
	end

	local cardByte = 0
	if self.enableLaiZi ~= 1 then
		local value = outCardList[1].value
		if #outCardList < self._args[1] or #outCardList > self._args[2] then 
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
		if #outCardList+#invalidCardList < self._args[1] or #outCardList+#invalidCardList > self._args[2] then 
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


	-- local value = cardList[1].value
	-- local targetCard = cardList[1]
	-- if self.enableLaiZi == 1 then
	-- 	cardList =  data.outCardInfo.cardList
	-- 	for i,card in ipairs(cardList) do 
	-- 		if not CardUtils.isLaizi(data.ruleDao,card) then
	-- 			targetCard = card
	-- 			value = card.value
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- if #cardList < self._args[1] or #cardList > self._args[2] then
	-- 	return false 
	-- end
	-- for k,v in pairs(cardList) do 
	-- 	if v.value ~= value then
	-- 		if self.enableLaiZi == 1 then 
	-- 			if not CardUtils.isTargetLaizi(data.ruleDao,v,targetCard) then
	-- 				return false
	-- 			end 
	-- 		else
	-- 			return false
	-- 		end 
	-- 	end
	-- end 

	-- data.outCardInfo.size = self.sortRule.args
	-- data.outCardInfo.byteToSize = self.byteToSize
	-- data.outCardInfo.cardByte = cardList[1].byte;
	-- return true;
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

--私有函数，获取牌列表中每个byteToSize值的牌map,isIncludeLaiZi字段控制是否将癞子归入
-- function M:_getCardByteToSizeMap(cards,isIncludeLaiZi,ruleDao)
-- 	local orgCardMap = {}
-- 	for i,card in ipairs(cards) do 
-- 		if not orgCardMap[self.byteToSize[card.byte]] then 
-- 			orgCardMap[self.byteToSize[card.byte]] = {}
-- 		end
-- 		if not isIncludeLaiZi and CardUtils.isLaizi(ruleDao,card) then
-- 			--不允许癞子加入时直接跳过 
-- 		else
-- 			table.insert(orgCardMap[self.byteToSize[card.byte]],card)
-- 		end
-- 	end


-- 	--对每个表里的元素按照癞子进行排序,用于优先使用非癞子牌
-- 	if isIncludeLaiZi then 
-- 		for i,item in pairs(orgCardMap) do
-- 			for _,card in ipairs(item) do 
-- 				table.sort(item,function (a,b)
-- 					return a.flag<b.flag
-- 				end)
-- 			end
-- 		end
-- 	end
-- 	return orgCardMap
-- end



function M:find(data)
	--查找原牌
	local args = self._args
	local laiziList = {}
	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	local queue = data.queue and data.queue or 0
	local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local outCardStack = new(CardStack,{cards = outCardList})
	local invalidCardStack = new(CardStack,{cards = invalidCardList})
	local targetLength = length or args[1]
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
			if length < args[1] or length > args[2] then
				-- Log.v("TongZhang args[1]", args[1], "args[2]", args[2], "length", length)
				return
			end 
		end

		if length and #outCardList < length then
			return 
		end

		if #outCardList < args[1] then
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
				if cardByte and self.byteToSize[cardByte] >= self.byteToSize[map[i][1].byte] then
					isBigger = false
				end
				if #map[i] >= targetLength and isBigger then
					for j = 1,targetLength,1 do 
					    table.insert(returnList,map[i][j])
					end
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
				if cardByte and self.byteToSize[cardByte] >= self.byteToSize[map[i][1].byte] then
					isBigger = false
				end
				if #map[i] >= targetLength and isBigger then 
					for j = 1,targetLength,1 do 
					    table.insert(returnList,map[i][j])
					end
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

	if #returnList ~= 0 and #returnList == args[1] then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		} 

	end


-- end








	-- -- if self.enableLaiZi == 1 then 
	-- 	local args = self._args
	-- 	local laiziList = {}
	-- 	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	-- 	local queue = data.queue and data.queue or 0
	-- 	local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	-- 	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte

	-- 	if self.enableLaiZi ~= 1 then 
	-- 		if length then
	-- 			if length < args[1] or length > args[2] then
	-- 				-- Log.v("TongZhang args[1]", args[1], "args[2]", args[2], "length", length)
	-- 				return
	-- 			end 
	-- 		end

	-- 		if length and #outCardList < length then
	-- 			return 
	-- 		end

	-- 		if #outCardList < args[1] then
	-- 			return 
	-- 		end
	-- 	end
	-- 	--存在outCardList及invalidCardList中同时存在癞子的情况，将其癞子抽出合并
	-- 	if #laiziList ==0 then 
	-- 		laiziList = CardUtils.getLaiZiList(data.ruleDao,outCardList)
	-- 		laiziList = table.merge2(laiziList,CardUtils.getLaiZiList(data.ruleDao,invalidCardList))
	-- 	end

	-- 	--对癞子按牌点大小进行排序,用于处理手中出的牌全是癞子时，将最大牌点的癞子牌做为原生牌的情况
	-- 	table.sort(laiziList,function (a,b)
	-- 		if self.byteToSize[a] and self.byteToSize[b] then 
	-- 			return self.byteToSize[a.byte] < self.byteToSize[b.byte]
	-- 		end
	-- 	end)

	-- 	local targetLength = length or args[1]
	-- 	-- 癞子牌可作为原生牌的分组
	-- 	local includeLaiZiCardMap = self:_getCardByteToSizeMap(outCardList,true,data.ruleDao)
	-- 	-- 癞子牌不能做为原生牌的分组
	-- 	local orgCardMap = self:_getCardByteToSizeMap(outCardList,false,data.ruleDao)
	-- 	Log.e(outCardList)
	-- 	Log.e(includeLaiZiCardMap)
	-- 	Log.e(orgCardMap)

	-- 	local max = -1
	-- 	for i,v in pairs(includeLaiZiCardMap) do 
	-- 		if i>=max then 
	-- 			max = i
	-- 		end
	-- 	end
	-- 	local endi = queue ==1 and 1 or max
	-- 	local step = queue ==1 and -1 or 1


	-- 	--癞子能做为原生牌时的找法
	-- 	for i = queue == 1 and max or 1,endi,step do
	-- 		if includeLaiZiCardMap[i] and #includeLaiZiCardMap[i]~=0 then
	-- 			local isBigger = true
	-- 			if cardByte and self.byteToSize[cardByte] >= self.byteToSize[includeLaiZiCardMap[i][1].byte] then
	-- 				isBigger = false
	-- 			end

	-- 			if #includeLaiZiCardMap[i] >= targetLength and isBigger then
	-- 				local returnList = {}
	-- 			    for j = 1,targetLength,1 do 
	-- 			    	table.insert(returnList,includeLaiZiCardMap[i][j])
	-- 			    end
	-- 			    return
	-- 			    	{	cardList = returnList,
	-- 						cardByte = returnList[1].byte,
	-- 						cardType = self.uniqueId,
	-- 					}
	-- 			end
	-- 			--以下代码是考虑到outCardList里的牌有且仅有癞子牌，要将该癞子牌做为原生牌去寻找的情况，待优化
	-- 			--癞子牌做为原生牌，且支持癞子时
	-- 			if self.enableLaiZi ==1  and #includeLaiZiCardMap[i]+#laiziList >=targetLength and isBigger then
	-- 				local tempLaiZiList = {}
	-- 				--需要将做为原生牌的癞子从癞子列表中移出
	-- 				for j,card in ipairs(laiziList) do 
	-- 					if includeLaiZiCardMap[i][1] ~=card then 
	-- 						table.insert(tempLaiZiList,card)
	-- 					end
	-- 				end
	-- 				if #includeLaiZiCardMap[i]+ #tempLaiZiList >= targetLength then
	-- 					-- 缺少的张数 = 目标长度 - 原生牌长度 
	-- 					local dValue = targetLength - #includeLaiZiCardMap[i]
	-- 					--癞子可替代的牌都相同 -- 若有特殊的在子牌型里特殊处理
	-- 					local exampleLaizi = tempLaiZiList[1]
	-- 					if CardUtils.isTargetLaizi(data.ruleDao,exampleLaizi,includeLaiZiCardMap[i][1]) then
	-- 						local returnList = {}
	-- 						for j = 1,#includeLaiZiCardMap[i],1 do 
	-- 							table.insert(returnList,includeLaiZiCardMap[i][j])
	-- 						end
	-- 						for j = 1 ,dValue,1 do 
	-- 							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,tempLaiZiList[j],returnList[1]))
	-- 						end
	-- 						return
	-- 							{	cardList = returnList,
	-- 								cardByte = returnList[1].byte,
	-- 								cardType = self.uniqueId,
	-- 							}
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- 	--牌型不支持癞子时，不需要将癞子与原生牌分离去找
	-- 	if not self.enableLaiZi == 1 then
	-- 		return
	-- 	end

	-- 	--癞子未加入原生牌时的找法
	-- 	for i = queue == 1 and max or 1,endi,step do
	-- 		if orgCardMap[i] then
	-- 			if #orgCardMap[i]> 0 then
	-- 				--有原生牌的情况 
	-- 				local isBigger = true
	-- 				if cardByte and self.byteToSize[cardByte] >= self.byteToSize[orgCardMap[i][1].byte] then
	-- 					isBigger = false
	-- 				end
	-- 				if #orgCardMap[i]+#laiziList >= targetLength and isBigger then
	-- 					--目标长度 - 原生牌长度 = 缺少的张数
	-- 					local dValue = targetLength - #orgCardMap[i]
	-- 					--癞子可替代的牌都相同 -- 若有特殊的在子牌型里特殊处理
	-- 					local exampleLaizi = laiziList[1]
	-- 					--满足癞子可替换原生牌的情况
	-- 					if CardUtils.isTargetLaizi(data.ruleDao,exampleLaizi,orgCardMap[i][1]) then
	-- 						local returnList = {}
	-- 						for j = 1,#orgCardMap[i],1 do 
	-- 							table.insert(returnList,orgCardMap[i][j])
	-- 						end
	-- 						for j = 1 ,dValue,1 do 
	-- 							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],returnList[1]))
	-- 						end
	-- 						return
	-- 							{	cardList = returnList,
	-- 								cardByte = returnList[1].byte,
	-- 								cardType = self.uniqueId,
	-- 							}
	-- 					end
	-- 				end

	-- 			elseif #orgCardMap[i] == 0 then
	-- 				--没有原生牌的情况
	-- 				-- 传入的牌皆为癞子牌，且癞子的牌点不相同时，会取癞子牌中最大牌点的牌做为原生牌处理,癞子牌做过降序处理
	-- 				if #orgCardMap[i]+#laiziList >= targetLength then
	-- 					local replaceLaiZiCard = laiziList[1]
	-- 					--暂定上下文到此处时，癞子的数量是大于1的
	-- 					local laiziCard = laiziList[2]
	-- 					if CardUtils.isTargetLaizi(data.ruleDao,laiziCard,replaceLaiZiCard) then 
	-- 						local isBigger = true
	-- 						if cardByte and self.byteToSize[cardByte] >= self.byteToSize[replaceLaiZiCard.byte] then 
	-- 							isBigger = false
	-- 						end
	-- 						if isBigger then
	-- 							table.insert(orgCardMap[i],table.remove(laiziList,1))
	-- 							local dValue = targetLength - #orgCardMap[i]
	-- 							local returnList = {}
	-- 							for j = 1,#orgCardMap[i],1 do 
	-- 								table.insert(returnList,orgCardMap[i][j])
	-- 							end
	-- 							for j = 1 ,dValue,1 do 
	-- 								table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,laiziList[j],returnList[1]))
	-- 							end
	-- 							return
	-- 								{	cardList = returnList,
	-- 									cardByte = returnList[1].byte,
	-- 									cardType = self.uniqueId,
	-- 								}
	-- 						end

	-- 					end

	-- 				end

	-- 				-- 	if #orgCardMap[i]  == 0 then
	-- 				-- 		table.insert(orgCardMap[i],table.remove(laiziList,1))
	-- 				-- 	end 

	-- 			end
	-- 		end
	-- 	end
	-- else



	-- local sortData = {cardInfo = {}, ruleDao = data.ruleDao}
	-- sortData.cardInfo.cardList = data.srcCardStack:getCardList()
	-- self:sort(sortData)
	-- local args = self._args 
	-- local outCardList, invalidCardList = self:getValidCard(sortData.cardInfo.cardList)
	-- local queue = data.queue and data.queue or 0
	

	-- local length = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or nil
	-- local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	-- if length then
	-- 	if length < args[1] or length > args[2] then
	-- 		-- Log.v("TongZhang args[1]", args[1], "args[2]", args[2], "length", length)
	-- 		return
	-- 	end 
	-- end

	-- if length and #outCardList < length then
	-- 	return 
	-- end

	-- if #outCardList < args[1] then
	-- 	return 
	-- end

	-- local function removeToIndex(targetList, startIndex, endIndex, _step)
	-- 	local cardList = {}
	-- 	if _step == 1 then
	-- 		for i=endIndex, startIndex, -1 do
	-- 			table.insert(cardList, targetList[i])
	-- 			table.remove(targetList, i)
	-- 		end
	-- 	else
	-- 		for i=startIndex, endIndex, -1 do
	-- 			table.insert(cardList, targetList[i])
	-- 			table.remove(targetList, i)
	-- 		end
	-- 	end
	-- 	return cardList
	-- end
	-- -- Log.v("tongzhang args[1]", args[1], "args[2]", args[2])
	-- if cardByte then
	-- 	length = length == nil and self._args[1] or length
	-- 	-- 找牌长度相同的牌
	-- 	-- -- Log.v("tongzhang data.cardByte", data.cardByte, "data.length", data.length)
	-- 	local targetLength = length
	-- 	local targetSize = self.byteToSize[cardByte]
	-- 	-- dump(targetSize, "tongzhang cardByte")
	-- 	local i, iEnd, step = 1, #outCardList - targetLength + 1, 1

	-- 	if queue == 1 then
	-- 		i, iEnd, step = #outCardList, targetLength - 1, -1
	-- 	end
	-- 	local function compare()
	-- 		if step == 1 then
	-- 			return i <= iEnd
	-- 		else
	-- 			return i > iEnd
	-- 		end
	-- 	end
	-- 	while compare() do
	-- 		local card = outCardList[i]
	-- 		-- -- Log.v("tongzhang outcardList i", i, iEnd, #outCardList)
	-- 		-- dump(card.byte, "tongzhang byte1")
	-- 		-- dump(self.byteToSize[card.byte], "tongzhang byte1")
	-- 		if self.byteToSize[card.byte] > targetSize then
	-- 			local endCard = outCardList[i + (targetLength - 1) * step]
	-- 			if self.byteToSize[card.byte] == self.byteToSize[endCard.byte] then
	-- 				local flag = false
	-- 				if args[1] ~= args[2] then
	-- 					-- 找到第一张大的牌 和 顺移长度后的牌 size相同，则为同张
	-- 					local endNextCard = outCardList[i + targetLength * step]
	-- 					if endNextCard then
	-- 						if self.byteToSize[card.byte] ~= self.byteToSize[endNextCard.byte] or targetLength == args[2] then
	-- 							flag = true
	-- 						else
	-- 							break
	-- 						end
	-- 					else
	-- 						flag = true
	-- 					end
	-- 				else
	-- 					flag = true
	-- 				end
	-- 				if flag then
	-- 					local cardList = removeToIndex(outCardList, i, i + (targetLength - 1) * step, step)
	-- 					table.copyTo(outCardList, invalidCardList);
	-- 					return {
	-- 								cardList = cardList,
	-- 								cardByte = cardList[1].byte,
	-- 								cardType = self.uniqueId,
	-- 							}
	-- 				end
	-- 			end
	-- 		end
	-- 		i = i + step
	-- 	end
	-- end
	
	-- --ars[1] 最少数量 --args[2] 最大数量

	-- local startLength = args[1]
	-- if cardByte and length then
	-- 	startLength = length + 1
	-- else
	-- 	if queue == 1 then
	-- 		-- startLength, endLength = args[2], args[1]
	-- 	end
	-- end

	-- if startLength > args[2] then
	-- 	-- 需要找的长度超出了args[2]长度，则不需要找了
	-- 	return
	-- end
	-- -- Log.v("not length", startLength, args[2], outCardList)
	-- for targetLength=startLength, args[2], 1 do
	-- 	local i, iEnd, step = 1, #outCardList - targetLength + 1, 1

	-- 	if queue == 1 then
	-- 		i, iEnd, step = #outCardList, targetLength - 1, -1
	-- 	end

	-- 	-- local i = 1

	-- 	local function compare()
	-- 		if step == 1 then
	-- 			return i <= iEnd
	-- 		else
	-- 			return i > iEnd
	-- 		end
	-- 	end

	-- 	while compare() do
	-- 		local card = outCardList[i]
	-- 		local endCard = outCardList[i + (targetLength - 1) * step]
	-- 		-- if self.enableLaiZi == 1 then 
	-- 		-- 	if not CardUtils.isLaizi(data.ruleDao,card) and not CardUtils.isLaizi(data.ruleDao,endCard) then
				
	-- 		-- 	else
	-- 		-- 		if CardUtils.isLaizi(data.ruleDao,card) then
	-- 		-- 			card = CardUtils.getLaiziCard(data.ruleDao,card,endCard)
	-- 		-- 			Log.e(card,"change1")
	-- 		-- 		elseif  CardUtils.isLaizi(data.ruleDao,endCard) then 
	-- 		-- 			endCard = CardUtils.getLaiziCard(data.ruleDao,endCard,card)
	-- 		-- 			Log.e(endCard,"change2")
	-- 		-- 		end
	-- 		-- 	end
	-- 		-- end
	-- 		if self.byteToSize[card.byte] == self.byteToSize[endCard.byte] then
	-- 			-- 找到第一张大的牌 和 顺移长度后的牌 size相同，则为同张
	-- 			local flag = false
	-- 			-- args[1] 不等于 args[2]时，视为炸弹，找牌时只找数量相同的牌
	-- 			local endNextCard = outCardList[i + targetLength * step]
	-- 			if endNextCard then
	-- 				if self.byteToSize[card.byte] ~= self.byteToSize[endNextCard.byte] or targetLength == args[2] then
	-- 					-- if self.enableLaiZi == 1 then
	-- 					-- 	if  CardUtils.isLaizi(data.ruleDao,card) then
	-- 					-- 		outCardList[i] = card
	-- 					-- 	end
	-- 					-- 	if CardUtils.isLaizi(data.ruleDao,endCard) then
	-- 					-- 		outCardList[i + (targetLength - 1) * step] = endCard
	-- 					-- 	end
	-- 					-- end
	-- 					-- Log.v("find tong zhang le")
	-- 					flag = true
	-- 				else
	-- 					do break end
	-- 				end
	-- 			else
	-- 			end
	-- 			if flag then
	-- 				-- Log.v(" i ", i, i + (targetLength - 1) * step, step)
	-- 				local cardList = removeToIndex(outCardList, i, i + (targetLength - 1) * step, step)
	-- 				table.copyTo(outCardList, invalidCardList);
	-- 				return {
	-- 							cardList = cardList,
	-- 							cardByte = cardList[1].byte,
	-- 							cardType = self.uniqueId,
	-- 						}
	-- 			end
	-- 		end
	-- 		i = i + step
	-- 	end
	-- end
	-- end
end

return M;
