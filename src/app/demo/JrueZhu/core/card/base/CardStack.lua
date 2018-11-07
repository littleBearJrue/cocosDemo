local CardStack = {};

local __defaultTab = {
	__index = function (t,k)
		local v = {}
		rawset(t,k,v);
		return v;
	end
}

local __defaultNum = {
	__index = function (t,k)
		rawset(t,k,0);
		return 0;
	end
}

local function __tostring( t )
	return table.tostring(t.__curCardList);
end

function CardStack:ctor(data)	
	self.__origCardBytes = {};
	self.__curCardList = {};
	self.__curCardNumber = 0
	
	if data and data.bytes then
		self:initFromBytes(data.bytes);
	elseif data and data.cards then
		self:initFromCards(data.cards);
	end

	self:resetCache();

	local mt = getmetatable(self);
	mt.__tostring = __tostring;
end

function CardStack:initFromBytes(bytes)
	for i,v in ipairs(bytes) do
		local card = Card.new(v);
		self:addCard(card);
	end
	self.__origCardBytes = bytes;
end

function CardStack:initFromCards(cards)
	for i,v in ipairs(cards) do
		self:addCard(v);
		self.__origCardBytes[i] = v.byte;
	end
end

function CardStack:getOrigCardBytes()
	return self.__origCardBytes;
end

function CardStack:getCardList(noCopy)
	if noCopy == true then
		return self.__curCardList;
	end
	local cardList = {}
	table.copyTo(cardList,self.__curCardList)
	return cardList;
end

function CardStack:getCurCardBytes()
	local t = {}
	for i,v in ipairs(self.__curCardList) do
		t[i] = Card.getNormalByte(v);
	end
	return t;
end

function CardStack:addCards(cards)
	for i,v in ipairs(cards) do
		self:addCard(v);
	end
end

function CardStack:checkBytes( bytes )
	local count = {}
	for i,v in ipairs(bytes) do
		count[v] = (count[v] or 0) + 1;
	end
	for k,v in pairs(count) do
		if self:getNumberByByte(k) < v then
			return false;
		end
	end
	return true;
end

function CardStack:checkCards( cards )
	local count = {}
	for i,v in ipairs(cards) do
		local normalByte = Card.getNormalByte(v);
		count[normalByte] = (count[normalByte] or 0) + 1;
	end
	for k,v in pairs(count) do
		if self:getNumberByByte(k) < v then
			return false;
		end
	end
	return true;
end

function CardStack:removeCards( cards )
	for i,v in ipairs(cards) do
		self:removeCard(v);
	end
end

function CardStack:addCard(card)
	table.insert(self.__curCardList, card);
	self.__curCardNumber = self.__curCardNumber + 1;
	self:resetCache();
end

function CardStack:removeCard(card)
	for i,v in ipairs(self.__curCardList) do
		if v == card then
			table.remove(self.__curCardList, i);
			self.__curCardNumber = self.__curCardNumber - 1;
			self:resetCache();
			return;
		end
	end
	Log.e("remove card failed, handCard", self.__curCardList)
	Log.e("remove card failed, removeCard", card)
	error("remove card failed!!!")
end

function CardStack:clone()
	return new(CardStack, { cards = self.__curCardList});
end

function CardStack:resetCache( ... )
	self.__cache = {};
end

function CardStack:getNumberByValue(val)
	local number = 0;
	for i,v in ipairs(self.__curCardList) do
		if v.value == val then
			number = number + 1;
		end
	end
	return number;
end

function CardStack:getNumberByByte(byte)
	local map = self:getByteMap();
	return map[byte];
end

function CardStack:getCardsByValue(val, noCopy)
	local map = self:getValueMap();
	if noCopy == true then
		return map[val]
	end
	local t = {};
	table.copyTo(t, map[val])
	return t;
end

function CardStack:getCardsByByte(byte)
	local map = self:getByteMap();
	local t = {};
	for i=1,map[byte] do
		table.insert(t, Card.new(byte));
	end
	return t;
end

function CardStack:getCardsByColor(color, noCopy)
	local map = self:getColorMap();
	if noCopy == true then
		return map[color];
	end
	local t = {};
	table.copyTo(t, map[color])
	return t;
end

function CardStack:getNumber()
	return self.__curCardNumber;
end

--获取牌值与数量的映射表
--[[
	{
		{ [0x01] = 3, [0x02] = 4, }
	}
]]
function CardStack:getByteMap()
	if self.__cache.byteMap then
		return self.__cache.byteMap;
	end

	local t = {};
	setmetatable(t, __defaultNum);
	for i,v in ipairs(self.__curCardList) do
		local normalByte = Card.getNormalByte(v);
		t[normalByte] = t[normalByte] + 1;
	end
	self.__cache.byteMap = t;
	return t;
end

--获取花色与牌的映射表
--[[
	{
		{ [0] = {c1,c2,c3}, [1] = {} }
	}
]]
function CardStack:getColorMap()
	if self.__cache.colorMap then
		return self.__cache.colorMap;
	end

	local t = {};
	setmetatable(t, __defaultTab);
	for i,v in ipairs(self.__curCardList) do
		table.insert(t[v.color], v);
	end
	self.__cache.colorMap = t;
	return t;
end

--获取牌点与牌的映射表
--[[
	{
		{ [0] = {c1,c2,c3}, [1] = {} }
	}
]]
function CardStack:getValueMap()
	if self.__cache.valueMap then
		return self.__cache.valueMap;
	end

	local t = {};
	setmetatable(t, __defaultTab);
	for i,v in ipairs(self.__curCardList) do
		table.insert(t[v.value], v);
	end
	self.__cache.valueMap = t;
	return t;
end

--获取张数与牌点的映射表
--[[
	{
		{ [3] = {4,5,6}, [4] = {7,8} }
	}
]]
function CardStack:getNumberValueMap()
	if self.__cache.numberValueMap then
		return self.__cache.numberValueMap;
	end

	local t = {};
	setmetatable(t, __defaultTab);
	local map = self:getValueMap();
	for k,v in pairs(map) do
		table.insert(t[#v], k);
	end
	self.__cache.numberValueMap = t;
	return t;
end

--获取张数与牌值的映射表
--[[
	{
		{ [3] = {0x01, 0x02}, [4] = {0x03, 0x04} }
	}
]]
function CardStack:getNumberByteMap()
	if self.__cache.numberByteMap then
		return self.__cache.numberByteMap;
	end

	local t = {};
	setmetatable(t, __defaultTab);
	local map = self:getByteMap();
	for k,v in pairs(map) do
		table.insert(t[v], k);
	end
	self.__cache.numberByteMap = t;
	return t;
end

--获取牌值张数等于 num 的牌值列表
function CardStack:getBytesByNumber(num)
	local map = self:getNumberByteMap();
	return map[num];
end

--获取牌点张数等于 num 的牌点列表
function CardStack:getValuesByNumber(num)
	local map = self:getNumberValueMap();
	return map[num];
end

return CardStack;