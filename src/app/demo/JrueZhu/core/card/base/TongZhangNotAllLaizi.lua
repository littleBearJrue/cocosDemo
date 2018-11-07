-- @Author: XiongmeiLai
-- @Date:   2018-04-23 15:11:57
-- @Last Modified by   LucasZhen
-- @Last Modified time 2018-05-04 16:16:19

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
	self.args = {[1]=最短数量，[2]=最长数量, [3]=最少原生牌数量}
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
	self._args[1] = data[1] or 2-----可配参数 
	self._args[2] = data[2] or 2-----可配参数
	self._args[3] = data[3] or 1-----可配参数
	self.minNum = self._args[1]
end



function M:check(data)
	local args = self._args
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
	local count = 0
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
			return false
		end

		for i,card in ipairs(totalList) do
			if CardUtils.isLaizi(data.ruleDao,card) then 
				if not CardUtils.isTargetLaizi(data.ruleDao,card,targetCard) then
					return false
				end
			else
				if card.value ~= value then
					return false 
				else
					count = count + 1
				end
			end 
		end
	end 

	if count < args[3] then
		return false
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

	--先进行一次遍历，优先去找不补癞子的牌型
	for i = queue == 0 and max or 1,endi,step do
		if map[i] and #map[i]~=0 then
			local isBigger = true
			if cardByte and self.byteToSize[cardByte] >= self.byteToSize[map[i][1].byte] then
				isBigger = false
			end
			if #map[i] >= targetLength and isBigger and #map[i] >= args[3] and not CardUtils.isLaizi(data.ruleDao,map[i][1]) then
				for j = 1,targetLength,1 do 
				    table.insert(returnList,map[i][j])
				end
				break
			end
		end
	end

	--再去找补癞子的牌型
	if #returnList ==0 and self.enableLaiZi == 1 then
		for i = queue == 0 and max or 1,endi,step do
			if map[i] and #map[i]~=0 and #map[i] >= args[3] and not CardUtils.isLaizi(data.ruleDao,map[i][1]) then
				local isBigger = true
				if cardByte and self.byteToSize[cardByte] >= self.byteToSize[map[i][1].byte] then
					isBigger = false
				end
				if #map[i] + #laiziList >= targetLength and isBigger  then
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
	
	if #returnList ~= 0 and #returnList >= args[1] and #returnList <= args[2] then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		}

	end
end

return M;
