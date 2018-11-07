--[[--ldoc desc
@module CardBase
@author KevinZhang

Date   2018-06-20 18:06:56
Last Modified by   VincentZhang
Last Modified time 2018-09-03 18:17:20
]]--出牌规则库基类
local CardBase = class(LibBase, "CardBase")

local __defaultTab = {
	__index = function (t,k)
		local v = {};
		rawset(t,k,v);
		return v;
	end
}

local __defaultSize = {
	__index = function (t,k)
		assert(type(k) == "number", "invalid byte : "..k);
		local byte = k;
		if Card.isLaiziByte(byte) then
			byte = Card.getNormalByte2(k);
		end
		if Card.isTributeByte(byte) then
			byte = Card.getTributeOrigByte(byte);
		end
		local size = rawget(t, byte);
		if size then
			rawset(t, k, size);
			return size;
		end
		rawset(t,k,0);
		return 0;
	end	
}

local __getter = {
	byteToSize = function (t,k)
		if t.m_byteToSize and not t:isSizeDirty() then
			return t.m_byteToSize;
		end
		t:updateSizeInfo();
		return t.m_byteToSize;
	end,
	sizeToByte = function (t,k)
		if t.m_sizeToByte and not t:isSizeDirty() then
			return t.m_sizeToByte;
		end
		t:updateSizeInfo();
		return t.m_sizeToByte;
	end,
}

--[[
	onlyId          可视化的唯一id，目前用于机器人好牌换牌的牌型查找
	name			牌型名称
	typeId			对应牌型规则库ID
	uniqueId 		对应游戏牌型编号（唯一id）
	args			这个牌型配置的参数
	sortRule.id		牌点大小规则id
	sortRule.args	牌点大小规则id的参数
	enableLaiZi		是否启用癞子   0:未启用     1:启用
	larger			包含可以压制的牌型(这里是牌型编号){[2] = true}
	less			包含可以压制我这个牌型的所有牌型uniqueId  {1,2,3,4,5}

	mainType		主牌型 部分牌型才有，例如 三打一 四带二
	subType			副牌型

	minNum			最小张数，牌型根据自身特征去设置
	offset			偏移数，每组偏移的牌张数，牌型根据自身特征去设置
]]
function CardBase:ctor(data, ruleDao)
	self.ruleDao	= ruleDao;
	self.name 		= data.name
	self.onlyId 	= data.id 
	self.typeId 	= data.typeRule.id;
	self.uniqueId 	= data.uniqueId;
	self.args 		= data.typeRule.args;
	self.sortRule 	= data.sortRule
	self.enableLaiZi= data.enableLaiZi
	self.priority	= data.priority or self.uniqueId;
	self.less 		= data.less
	self.larger 	= data.larger
	self.mainType 	= data.mainType or -1;
	self.subType 	= data.subType or -1;
	self.minNum 	= 0;
	self.offset		= 0;
	self.m_byteToSize = nil;
	self.m_sizeToByte = nil;
	local mt = getmetatable(self);
	setmetatable(self, {
		__index = function (t,k)
			local func = __getter[k];
			if func then
				return func(t,k);
			end
			return mt and mt.__index[k] or nil;
		end
	})
end
 
--  待废除，新牌型不要使用此方法，请使用CardStack
function CardBase:sort(data)
	if self:isSizeDirty() then
		self:updateSizeInfo();
	end
	local sortSize = data.cardInfo.byteToSize
	if self.byteToSize ~= sortSize then
		table.sort(data.cardInfo.cardList, function(c1, c2)
			local s1 = self.byteToSize[c1.byte] 
			local s2 = self.byteToSize[c2.byte]
			if s1 == s2 then
				return Card.getNormalByte(c1) > Card.getNormalByte(c2)
			end
			return s1 > s2
		end)
	end
	data.cardInfo.byteToSize = self.byteToSize
	data.cardInfo.size = self.sortRule.args
end

-- 对副牌的牌组进行排序
-- (对于三带二，四带一这种牌型，针对某些牌点不能加入主牌，副牌又可以加入的情况，对副牌按照单牌牌点大小进行排序)
function CardBase:sortBySingleCardSize(data)
	if self:isSizeDirty() then
		self:updateSizeInfo();
	end
	local singleCard
	if type(g_GameConst.CARD_TYPE.SINGLE) == 'string' then 
		singleCard = self.ruleDao:getCardRuleByName(g_GameConst.CARD_TYPE.SINGLE) 
	else 
		singleCard = self.ruleDao:getCardRuleById(g_GameConst.CARD_TYPE.SINGLE) 
	end 
	table.sort(data.cardInfo.cardList, function(c1, c2)
        local s1 = singleCard.byteToSize[c1.byte] 
        local s2 = singleCard.byteToSize[c2.byte]
        if s1 == s2 then
            return Card.getNormalByte(c1) > Card.getNormalByte(c2)
        end
        return s1 > s2
    end)
    data.cardInfo.byteToSize = singleCard.byteToSize
    data.cardInfo.size = singleCard.sortRule.args
end 

--  牌型通用方法，从牌列表中找出所有这个牌型有效的牌
function CardBase:getValidCard(srcCardList)
	local validCards, invalidCards = {}, {};
	for i,card in ipairs(srcCardList) do
		if self.byteToSize[card.byte] > 0 then
			table.insert(validCards, card)
		else
			table.insert(invalidCards, card)
		end
	end
	return validCards, invalidCards;
end

function CardBase:isValidCard(card)
	return self.byteToSize[card.byte] > 0;
end

--[[检查是否符合牌型   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	outCardInfo	{
		cardList = {card1, card2, ...}
		-- 根据牌型需要，可以往这里插入需要的字段
	}

	return 校验结果(true or false), byte用于判断大小的牌
]]
function CardBase:check(data)
	Log.i("Not Implemented")
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
function CardBase:compare(data)
	Log.i("Not Implemented")
end

--[[查找符合牌型的手牌，以及移除掉手牌后剩下的牌   需要用到的参数:
	ruleDao		数据对象，为客户端也能通用算法库，代替db的职责
	srcCardStack	从CardStack内找牌
	targetCardInfo = {
		cardByte = card.byte,
		cardList = {},
		-- 以及 check 方法新增的字段
	}
	
	queue,		-- 按照这个队列方式找牌  (默认)0:从前到后,即大到小   1:从后到前,即小到大
	ignoreContext, -- 满足特殊保牌需求，忽略上下文环境找牌（如忻州踹牌的44、444牌型），找到的牌cardType固定设置为-1；
	return 	{
				cardList = {},
				cardByte = byte,
				cardType = self.uniqueId,
			}
]]
function CardBase:find(data)
	Log.i("Not Implemented")
end

function CardBase:isSizeDirty()
	return self.m_isSizeDirty;
end

function CardBase:setSizeDirty(isDirty)
	self.m_isSizeDirty = isDirty;
end

function CardBase:updateSizeInfo(sizeInfo)
	if sizeInfo then
		self.m_byteToSize = {}
		for k,v in pairs(sizeInfo) do
			self.m_byteToSize[k] = v;
		end
		setmetatable(self.m_byteToSize, __defaultSize);
	elseif self.sortRule and #self.sortRule > 0 then
		self.m_byteToSize = CardUtils.getLogicValue({ruleDao = self.ruleDao, rule = self.sortRule});
		setmetatable(self.m_byteToSize, __defaultSize);
	end			
	if self.m_byteToSize then
		local sizeToByte = {};
		setmetatable(sizeToByte, __defaultTab)
		local maxSize = 0-math.huge;
		local minSize = math.huge;
		for k,v in pairs(self.m_byteToSize) do
			table.insert(sizeToByte[v], k);
			if v > maxSize then
				maxSize = v;
			end
			if v < minSize then
				minSize = v;
			end
		end
		sizeToByte.maxSize = maxSize;
		sizeToByte.minSize = minSize;
		self.m_sizeToByte = sizeToByte;

		self:setSizeDirty(false);
	end
end

function CardBase:combination(data)
	-- body
end

return CardBase;