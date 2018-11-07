--[[--ldoc desc
@module paixing_1576_1
@author SinChen

Date   2018-01-15 11:51:44
Last Modified by   LucasZhen
Last Modified time 2018-05-23 18:47:46
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
	4王炸牌型：大王、大王、小王、小王
	实现4王炸牌型的校验、同牌型比较、对子牌型的查找

]]

M.bindingData = {
	set = {},
	get = {},
}

function M:ctor(data,ruleDao)
	local args = data.typeRule.args
	local jokerNameList = string.split(args[1],'+')
	self.jokerByteList = {}
	for i,v in ipairs(jokerNameList) do
		self.jokerByteList[i] = Card.ByteMap:rget(v)
	end
	self.sameCount 		= tonumber(args[2])
	self.minNum = #jokerNameList * args[2]
end

--[[检查是否符合牌型   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	outCardInfo	{
		cardList = {card1, card2, ...}
		-- 根据牌型需要，可以往这里插入需要的字段
	}

	-- 校验牌型之后，要对原始数据outCardInfo操作，添加两个元素进去，size = self.sortRule.args,  byteToSize = self.byteToSize
	return 校验结果(true or false), byte用于判断大小的牌
]]
function M:check(data)
	Log.v("M:check")
	local cardList 	= data.outCardInfo.cardList
	local length	= #data.outCardInfo.cardList
	if length ~= #self.jokerByteList*self.sameCount then
		return false
	end
	
	for i,v in ipairs(self.jokerByteList) do
		if #CardUtils.getCardsByByte(cardList, v) ~= self.sameCount then
			return false
		end
	end
	data.outCardInfo.size = self.sortRule.args
	data.outCardInfo.byteToSize = self.byteToSize
	data.outCardInfo.cardByte = cardList[1].byte
	return true
end

--[[牌型比较   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	outCardInfo	{
		cardList = {card1, card2, ...},
		cardByte = byte,
	}
	targetCardInfo	{
		cardList = {card1, card2, ...},
		cardByte = byte,
	}

	return true or false
]]
function M:compare(data)
	Log.i("M:compare")
	-- 四王炸最大 无需比较
end

--[[查找符合牌型的手牌，以及移除掉手牌后剩下的牌   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	srcCardInfo = {
		cardList = {card1, card2, ...},
		size = {}, 		同 self.sortRule.args
		byteToSize = {},同 self.byteToSize
	},
	targetCardInfo = {
		cardByte = card.byte,
		cardList = {},
		-- 以及 check 方法新增的字段
	}
	--  cardByte, length 待移除
	cardByte,	-- 从比这个牌更大的牌开始找,不穿则从最小开始找
	length,		-- 总的牌长度,不传则没有要求
	
	queue,		-- 按照这个队列方式找牌  (默认)0:从前到后,即大到小   1:从后到前
	laiziList = {0x01,0x01},	--癞子列表
	reserveCards, --保牌结果

	return 	{
				cardList = {},
				cardByte = byte,
				cardType = self.uniqueId,
			}, 	{
					cardList = {},
					size = {},
					byteToSize = {},
				}
]]
function M:find(data)
	local outCardList 		= data.srcCardStack:getCardList()
	local targetCardList 	= data.targetCardInfo and data.targetCardInfo.cardList
	
	if targetCardList then
		local targetLength  = #targetCardList 
		for i,v in ipairs(self.jokerByteList) do
			local jokerCards 	= CardUtils.getCardsByByte(targetCardList, v)
			targetLength 		= targetLength - #jokerCards
		end
		if targetLength == 0 then
			return
		end
	end

	local cardList = {}
 	for i,v in ipairs(self.jokerByteList) do
		local jokerCards 	= CardUtils.getCardsByByte(outCardList, v)
		Log.i("M:find JokerCards",jokerCards)
		if #jokerCards < self.sameCount then 
			return false
		end
		local needList = {}
		for i =1,self.sameCount do 
			table.insert(needList,jokerCards[i])
		end
		cardList 			= table.merge2(cardList, needList)
	end

	return self:returnInfo(cardList,outCardList)
end


-- 返回结果
function M:returnInfo(cardList,outCardList)
	-- Log.v("M:returnInfo",cardList,outCardList)
	return {
				cardList = cardList,
				cardByte = cardList[1].byte,
				cardType = self.uniqueId,
			}
end

return M;