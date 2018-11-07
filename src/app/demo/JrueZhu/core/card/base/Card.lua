local Card = {};

--[[	
	16位表示一张牌, 0xABCD
	AB: 00-4F 用来表示癞子牌的原始牌值
		50-FF 用来表示特殊牌标记
	CD: C, 花色, 0-4 用来表示普通牌的花色， 5-9用来表示贡牌花色
		D, 牌点
]]


local _ByteMap = {
	[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3",  [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7",
	[0x08] = "方块8", [0x09] = "方块9", [0x0a] = "方块10", [0x0b] = "方块J", [0x0c] = "方块Q", [0x0d] = "方块K",

	[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3",  [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7",
	[0x18] = "梅花8", [0x19] = "梅花9", [0x1a] = "梅花10", [0x1b] = "梅花J", [0x1c] = "梅花Q", [0x1d] = "梅花K",

	[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3",  [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7",
	[0x28] = "红桃8", [0x29] = "红桃9", [0x2a] = "红桃10", [0x2b] = "红桃J", [0x2c] = "红桃Q", [0x2d] = "红桃K",

	[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3",  [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7",
	[0x38] = "黑桃8", [0x39] = "黑桃9", [0x3a] = "黑桃10", [0x3b] = "黑桃J", [0x3c] = "黑桃Q", [0x3d] = "黑桃K",

	[0x4e] = "小王", [0x4f] = "大王", [0x40] = "日历牌", [0x41] = "听用牌",
}
Card.ByteMap = new(BiMap, _ByteMap);

local _SpecialCardInfo = {
	[0x40] = { color = 4, value = 0 },
	[0x90] = { color = 4, value = 0 },
	[0x41] = { color = 4, value = 0 },
	[0x91] = { color = 4, value = 0 },
}

Card.SpecialCards = {
	Calendar = 0x40, --日历牌
	TingYong = 0x41, --听用牌
};

Card.CardFlag = {
	Default			= 0, 	--默认
}

local _ValueMap = {	
	[3] = "3";
	[4] = "4";
	[5] = "5";
	[6] = "6";
	[7] = "7";
	[8] = "8";
	[9] = "9";
	[10] = "10";
	[11] = "J",
	[12] = "Q",
	[13] = "K",
	[14] = "A",
	[15] = "2",
	[16] = "小王",
	[17] = "大王",
}
Card.ValueMap = new(BiMap, _ValueMap);

local _ColorMap = {
	[0] = "方块";
	[1] = "梅花";
	[2] = "红桃";
	[3] = "黑桃";	
}
Card.ColorMap = new(BiMap, _ColorMap);

local function __getByteStr(byte)
	return _ByteMap[byte] or _ByteMap[byte - 0x50] or tostring(byte);
end

local function __tostring(t)
	if t.flag == 0 then
		return __getByteStr(t.byte);
	else
		local byte = Card.getNormalByte(t);
		return string.format("%s(%s)", __getByteStr(byte), __getByteStr(t.flag));
	end
end

local function __eq(t1, t2)
	if Card.isLaizi(t1) and Card.isLaizi(t2) then
		return t1.byte == t2.byte;
	elseif Card.isLaizi(t1) then
		return t1.flag == t2.byte;
	elseif Card.isLaizi(t2) then
		return t2.flag == t1.byte;
	else
		return t1.byte == t2.byte;
	end
end

local function __lt(t1, t2)
	if t1.value == t2.value then
		return t1.color < t2.color;
	end
	return t1.value < t2.value;
end

local function __le(t1, t2)
	if t1.value == t2.value then
		return t1.color <= t2.color;
	end
	return t1.value < t2.value;
end

local _metatable = {
	__tostring = __tostring,
	__eq = __eq,
	__le = __le,
	__lt = __lt,	
}

function Card.new(byte)
	local card = new(Card);
	card.byte = byte;
	card.value, card.color, card.flag = Card.getCardAttrFromByte(byte);

	setmetatable(card, _metatable);

	return card;
end

function Card.getCardAttrFromByte(byte)
	local flag = math.floor(byte / 0x100);
	local color, value = -1, -1;
	local byte2 = byte % 0x100;
	if _SpecialCardInfo[byte2] then
		color = _SpecialCardInfo[byte2].color;
		value = _SpecialCardInfo[byte2].value;
	else
		color = math.floor(byte2 / 0x10);
		value = byte2 % 0x10;
		if value < 3 then
			value = value + 13;
		elseif value > 13 then
			value = value + 2;
		end
		if color >= 5 and color <= 9 then
			color = color - 5;
		end
	end
	return value, color, flag;
end

function Card.getCardByteFromAttr(value, color, flag)
	flag = flag and flag * 0x100 or 0;
	assert(value and color, "inalid args!!!");
	if value > 15 then
		value = value - 2;
	elseif value > 13 then
		value = value - 13;
	end
	color = color * 0x10;
	return flag + color + value;
end

function Card.getNormalByte(card)
	return Card.getNormalByte2(card.byte)
end

function Card.getNormalByte2(byte)
	if byte > 0x100 then
		byte = byte % 0x100;
	end
	-- if byte > 0x50 and byte < 0xA0 then
	-- 	byte = byte - 0x50;
	-- end
	return byte;
end

function Card.isTribute(card)
	if card.flag > 0 then
		return Card.isTributeByte(card.flag);
	else
		return Card.isTributeByte(card.byte);
	end
end

function Card.isTributeByte(byte)
	return byte > 0x50 and byte < 0xA0;
end

function Card.getTributeOrigByte(byte)
	return byte - 0x50;
end

function Card.getTributeCard(card)
	assert(card.byte < 0x50, "invalid card : "..card.byte);
	local newByte = card.byte + 0x50;
	return Card.new(newByte);
end

function Card.isLaizi(card)
	return card.flag > 0;
end

function Card.isLaiziByte(byte)
	return byte > 0x100;
end

return Card;