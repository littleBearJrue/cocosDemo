-- @Author: KevinZhang
-- @Date:   2017-11-14 20:47:22
-- @Last Modified by   LucasZhen
-- @Last Modified time 2018-05-22 11:36:00

local CardBase = import("..base.CardBase")
local M = class(CardBase)


M.description = [[
功能描述说明：
	单牌：一张任意牌
]]


function M:ctor(data, ruleDao)
	
	self.minNum = 1
end

M.bindingData = {
	set = {},
	get = {},
}

function M:check(data)
	self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
	local outCardList = data.outCardInfo.cardList
	local outCardInfo = data.outCardInfo

	for i,card in ipairs(outCardList) do 
		if self.byteToSize[card.byte] == 0 then 
			return false
		end
	end

	outCardInfo.size = self.sortRule.args
	outCardInfo.byteToSize = self.byteToSize
	if #outCardList == 1 then
		outCardInfo.cardByte = outCardList[1].byte;
		return true;
	end
	return false;
end

-- 还有其他用不上的数据也传过来，未列出
function M:compare(data)
	-- self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
	-- self:sort({cardInfo = data.targetCardInfo, ruleDao = data.ruleDao})
	-- dump(data.outCardInfo.cardByte, "510k")
	-- dump(data.targetCardInfo.cardByte, "510k")
	if #data.outCardInfo.cardList~=1 or #data.targetCardInfo.cardList~=1 then
		return false
	end

	return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte]
end

---查找符合牌型的手牌，以及移除掉手牌后剩下的牌
--data.cardInfo    {cardStack, cardList, size, byteToSize}
function M:find(data)
	local sortData = {cardInfo = {}, ruleDao = data.ruleDao}
	sortData.cardInfo.cardList = data.srcCardStack:getCardList()
	self:sort(sortData)
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte
	local handCardList = {}
	table.copyTo(handCardList, sortData.cardInfo.cardList)
	local resultCard = {}
	local leftCards = {}
	if not cardByte or not self.byteToSize[cardByte] then
		if data.queue == 1 then 
			resultCard[1] = handCardList[#handCardList]
			table.remove(handCardList, #handCardList)
		else 
			resultCard[1] = handCardList[1]
			table.remove(handCardList, 1)
		end
	else
		local startIndex,endIndex,step = 1,#handCardList,1
		if data.queue == 1 then 
			startIndex,endIndex,step = #handCardList,1,-1
		end
		local targetCardByte = cardByte
		for i = startIndex,endIndex,step  do
			if self.byteToSize[handCardList[i].byte] > self.byteToSize[targetCardByte] then
				resultCard[1] = handCardList[i]
				table.remove(handCardList, i)
				break
			end
		end
	end
	leftCards = handCardList
	if #resultCard == 0 then
		return
	end

	for i,card in ipairs(resultCard) do 
		if self.byteToSize[card.byte] == 0 then 
			return
		end
	end
	-- Log.i("find result",data.queue,resultCard)
	return {cardList = resultCard, cardByte = resultCard[1].byte, cardType = self.uniqueId}
end


return M;