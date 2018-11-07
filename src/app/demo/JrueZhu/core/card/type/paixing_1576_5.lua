--[[--ldoc desc
@module paixing_1576_5
@author LucasZhen

Date   2018-01-09 19:35:02
Last Modified by   AmyGuo
Last Modified time 2018-07-20 14:44:28
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
	三王
	1张大王+1张小王+1日历牌 
]]

function M:ctor(data,ruleDao)
	local args = {1,1,1}
	self.m_byteNum = {};
	self.m_totalNum = args[1]+args[2]+args[3];

	self.m_byteNum[Card.ByteMap:getKeyByValue("大王")] = args[1]
	self.m_byteNum[Card.ByteMap:getKeyByValue("小王")] = args[2]
	self.m_byteNum[Card.ByteMap:getKeyByValue("日历牌")] = args[3]

end

local function _isCanInstead(targetCard,laiZiList,ruleDao)
	for i,card in ipairs(laiZiList) do 
		if not CardUtils.isTargetLaizi(ruleDao,laiZiCard,card) then
			return false
		end
	end
	return true
end



function M:check(data)
	local outCardList,invalidCardList = self:getValidCard(data.outCardInfo.cardList)
	--将outCardList降序排序
	-- table.sort( outCardList,function(a,b)
	-- 	return a.value > b.value
	-- end )

	--如果没有一张原生牌，则直接返回
	if #outCardList == 0 then 
		return false
	end

	if self.enableLaiZi ~= 1 then
	    --不可以使用癞子时，只需判断outCardList中的牌是否是指定牌即可 
	    if #outCardList ~= #data.outCardInfo.cardList then
			return false
		end
		if #outCardList ~= self.m_totalNum then 
			return false
		end
		-- local orgNums = 0
		local count = {}
		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if Card.isTribute(card) then normalByte = Card.getTributeOrigByte(card.byte) end 
			if not self.m_byteNum[normalByte] then
				return false;
			end
			count[normalByte] = (count[normalByte] or 0) + 1
			if count[normalByte] > self.m_byteNum[normalByte] then
				return false;
			end
		end
	else
		--使用癞子时，需考虑到invalidCardList中的牌是否可替代指定牌
		if #outCardList + #invalidCardList ~= self.m_totalNum then 
			return false
		end

		local laiZiList = {}
		for i,card in ipairs(invalidCardList) do 
			if not CardUtils.isLaizi(data.ruleDao,card) then 
				return false
			else 
				table.insert(laiZiList,card)
			end
		end
		local count =  {}
		for i,card in ipairs(outCardList) do
			local normalByte = Card.getNormalByte(card)
			if Card.isTribute(card) then normalByte = Card.getTributeOrigByte(card.byte) end 
			if not self.m_byteNum[normalByte] then
				return false;
			end
			count[normalByte] = (count[normalByte] or 0) + 1
			if count[normalByte] > self.m_byteNum[normalByte] then
				return false;
			end
		end


		if #laiZiList ~= 0 then
			for normalByte,num in pairs(self.m_byteNum) do
				local n =  count[normalByte] or 0
				if n < num then
					local dValue = num - n 
					if #laiZiList < dValue then
						return false 
					end
					local targetCard = Card.new(normalByte)
					if not _isCanInstead(targetCard,laiZiList,ruleDao) then 
						return false
					end				
				end 
			end 
		end
	end	
	data.outCardInfo.cardByte = outCardList[1].byte;
	return true;
end

function M:compare(data)
	--同牌型无需比较
end

function M:find(data)
	local outCardList,invalidCardList = self:getValidCard(data.srcCardStack:getCardList())
	local invalidCardStack = new(CardStack,{cards = invalidCardList})
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local targetLength = self.m_totalNum
	local returnList = {}
	local laiZiList = CardUtils.getLaiZiList(data.ruleDao,invalidCardList) --此牌型是针对于王炸，暂时不考虑癞子牌做为原生牌去替换的情况


	--如果没有一张原生牌，则直接返回
	if #outCardList == 0 then 
		return
	end
	--同牌型无压制关系
	if cardByte then 
		return
	end

	if self.enableLaiZi ~= 1 then
		--不带癞子的情况，直接找指定牌即可
		if #outCardList < targetLength then
			return
		end
		local recordMap = {}
		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if Card.isTribute(card) then normalByte = Card.getTributeOrigByte(card.byte) end 
			recordMap[normalByte] = recordMap[normalByte] or 0 
			if self.m_byteNum[normalByte] and recordMap[normalByte] < self.m_byteNum[normalByte] then 
				table.insert(returnList,card)
				recordMap[normalByte] = recordMap[normalByte]+ 1
			end
		end

		if #returnList ~= targetLength then
			return
		end
	else
		--带癞子的情况，需要处理癞子是否能够替代指定牌
		if #outCardList + #invalidCardList < targetLength then 
			return
		end
		local recordMap = {}
		--找到已有的原生牌并分组
		for i,card in ipairs(outCardList) do 
			local normalByte = Card.getNormalByte(card)
			if Card.isTribute(card) then normalByte = Card.getTributeOrigByte(card.byte) end 
			recordMap[normalByte] = recordMap[normalByte] or 0 
			if self.m_byteNum[normalByte] and recordMap[normalByte] < self.m_byteNum[normalByte] then 
				table.insert(returnList,card)
				recordMap[normalByte] = recordMap[normalByte]+ 1
			end
		end
		--再补每组差的癞子牌，直到数量满足为止
		if #returnList>0 and #returnList < targetLength then
			local tmpLaiZiList = {}
			table.copyTo(tmpLaiZiList,laiZiList)
			for normalByte,num in pairs(self.m_byteNum) do
				recordMap[normalByte] =  recordMap[normalByte] or 0
				if recordMap[normalByte] < num then
					local targetCard = Card.new(normalByte)
					for i =#tmpLaiZiList,1,-1 do 
						if CardUtils.isTargetLaizi(data.ruleDao,tmpLaiZiList[i],targetCard) then 
							table.insert(returnList,CardUtils.getLaiziCard(data.ruleDao,tmpLaiZiList[i],targetCard))
							table.remove(tmpLaiZiList,i)
							recordMap[normalByte] = recordMap[normalByte]+1
							if recordMap[normalByte] == num then 
								break
							end
						end
					end
				end 
			end
		end
	end

	if #returnList ~= 0 and #returnList == targetLength then  --表示找到了结果
		return
		{	cardList = returnList,
			cardByte = returnList[1].byte,
			cardType = self.uniqueId,
		}
	end
end

return M;
