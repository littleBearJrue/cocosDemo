--[[--ldoc desc
@module CardUtils
@author CelineJiang

Date   2018-04-10 10:54:21
Last Modified by   LisaChen
Last Modified time 2018-08-27 18:44:19
]]
local CardUtils = {}

local __defaultTab = {
	__index = function (t,k)
		local v = {};
		rawset(t,k,v);
		return v;
	end
}

function CardUtils.getCardsFromBytes(bytes)
	local t = {}
	for i,v in ipairs(bytes) do
		t[i] = Card.new(v);
	end
	return t;
end

function CardUtils.getBytesFromCards(cards)
	local t = {}
	for i,v in ipairs(cards) do
		t[i] = v.byte;
	end
	return t;
end

function CardUtils.getCardAttrFromByte(byte)
	return Card.getCardAttrFromByte(byte);
end

function CardUtils.getCardByteFromAttr(value, color, flag)
	return Card.getCardByteFromAttr(value, color, flag);
end

function CardUtils.getCardFromAttr(value, color, flag)
	local cardByte = CardUtils.getCardByteFromAttr(value, color, flag)
	return Card.new(cardByte);
end

-- @param ignoreContext 找牌型的时候是否忽略牌型环境，保牌为true，此时uniqueId为-1表明在特殊环境下有不同的牌型，在使用时再重新判断牌型
function CardUtils.getReserveCards(ruleDao, srcCardStack, priority, ignoreContext)
	local typeArr = priority;
	local result = {};

	for _,v in ipairs(typeArr) do
		local findList, leftCards = CardUtils.findCardsByType(ruleDao, srcCardStack, v.uniqueId, true, ignoreContext);
		result[v.uniqueId] = findList
		srcCardStack = leftCards;
	end

	local allCardType = ruleDao:getAllCardTypes()
	for _,v in ipairs(allCardType) do
		result[v.uniqueId] = result[v.uniqueId] or {}
	end

	result.other = srcCardStack:getCardList(true)
	return result
end

--- 查找手牌里的特定手牌各xxx张
--@param srcCards 手牌，CardStack 对象
--@param targetCards 特定手牌
--@int number 张数
function CardUtils.getSpecialCardsWithNum(cardStack, byteMap)
	local result = {};
	for k,v in pairs(byteMap) do
		local cards = cardStack:getCardsByByte(k);
		if #cards >= v then
			for i=1,v do
				table.insert(result, cards[i]);
			end
		else
			return;
		end
	end
	return result;
end

function CardUtils.getLogicColor(ruleDao, card)
	local isMain = CardUtils.isMainCard(ruleDao, card);
	return isMain and ruleDao:getMainColor() or card.color;
end

function CardUtils.getLogicValue(data)
	if not data.rule then
		return;
	end
	local ruleDao = data.ruleDao;
	for i,v in ipairs(data.rule) do
		local t = ruleDao:getCardRuleById(v.id);
		assert(t, "invalid sort rule : "..v.id)
		local result = t:main({ruleDao = ruleDao, args = v.args});
		if result then
			return result;
		end
	end
end

--[[
获取主牌方法
@param cardList 手牌
@param mainColor 主花色
@param mainValue 本局级牌
@param otherMain 常主值（比如淄博升级为大小王235）
@usage
    local mainColor = 0 -- 方块
	local mainValue = 4
	local otherMain = {17, 16, 15, 3, 5} -- 牌的byte值 {大小王，2,3,5}
]]
function CardUtils.getMainCards(ruleDao, cardList)
	local mainCards = table.selectall(cardList, function (i,v)
		return CardUtils.isMainCard(ruleDao, v);
	end)
	
	return mainCards;
end

function CardUtils.getOtherMainCards(ruleDao)
	local mainCards = ruleDao:getGameConfig("mainCards");
	local result = {};
	local mark = {};
	for k,v in pairs(mainCards) do
		if v == true then
			mark[k] = true;
			table.insert(result, Card.new(k));
		end
	end

	local mainValue = ruleDao:getMainValue();
	for i=0,3 do
		local byte = CardUtils.getCardByteFromAttr(mainValue, i);
		if not mark[byte] then
			table.insert(result, Card.new(byte));
		end
	end

	return result, mark;
end


function CardUtils.getCardSize(data)
	local function __setCardSize(result, size, cardStr)
		local byte = Card.ByteMap:getKeyByValue(cardStr);
		if byte then
			result[byte] = size;
			return;
		end

		local value = Card.ValueMap:getKeyByValue(cardStr);
		for i=0,3 do
			local byte = CardUtils.getCardByteFromAttr(value, i);
			result[byte] = size;
		end
		for i=5,8 do
			local byte = CardUtils.getCardByteFromAttr(value, i);
			result[byte] = size;
		end
	end

	local result = {};
	local arr1 = string.split(data.args[1], '>');
	local totalSize = #arr1;
	for i,v in ipairs(arr1) do
		local arr2 = string.split(v, '/');		
		for _,v in ipairs(arr2) do
			__setCardSize(result, totalSize - i + 1, v);
		end
	end
	
	return result;
end

---先根据牌值排序，然后根据花色在排序
function CardUtils.getCardSizeByValueAndColor(data)
	local function __setCardSize(result, byte , totalSize)
		-- Log.i("CardUtils.getCardSizeByValueAndColor",byte , totalSize)
		if byte then
			result[byte] = totalSize;
		end
	end

	local result = {};
	local totalSize = 1;
	local cardValues = string.split(data.args[1], '>');
	local cardColors = string.split(data.args[2], '>');

	for i = #cardValues , 1 , -1 do
		local value = cardValues[i];
		local byte = Card.ByteMap:getKeyByValue(value);
		if byte then  --排除大小王
			__setCardSize(result, byte , totalSize)
			totalSize = totalSize + 1;
		else
			local cardValue = Card.ValueMap:getKeyByValue(value);
			for i = #cardColors , 1 , -1 do 
				local color = cardColors[i];
				local key = Card.ColorMap:getKeyByValue(color);
				local byte = CardUtils.getCardByteFromAttr(cardValue , key);
				__setCardSize(result, byte , totalSize)
				totalSize = totalSize + 1;
			end
		end
	end

	return result;
end


---先根据花色排序，然后根据牌值在排序
function CardUtils.getCardSizeByColorAndValue(data)
	local function __setCardSize(result, byte , totalSize)
		-- Log.i("CardUtils.getCardSizeByColorAndValue",byte , totalSize)
		if byte then
			result[byte] = totalSize;
		end
	end
	local result = {};
	local totalSize = 1;
	local cardValues = string.split(data.args[2], '>');
	local cardColors = string.split(data.args[1], '>');

	for j=#cardColors , 1 , -1 do
		for i = #cardValues , 1 , -1 do
			local value = cardValues[i];
			local byte = Card.ByteMap:getKeyByValue(value);
			if byte then  --排除大小王
				-- __setCardSize(result, byte , totalSize)
				-- totalSize = totalSize + 1;
			else
				local cardValue = Card.ValueMap:getKeyByValue(value);
				local color = cardColors[j];
				local key = Card.ColorMap:getKeyByValue(color);
				local byte = CardUtils.getCardByteFromAttr(cardValue , key);
				__setCardSize(result, byte , totalSize)
				totalSize = totalSize + 1;
			end
		end
	end

	for i = #cardValues , 1 , -1 do --单独对大小王处理
		local value = cardValues[i];
		local byte = Card.ByteMap:getKeyByValue(value);
		if byte then  --排除大小王
			__setCardSize(result, byte , totalSize)
			totalSize = totalSize + 1;
		end
	end


	return result;
end

function CardUtils.checkCardInfo(data)
	local ruleDao = data.ruleDao;
	local outCardInfo = data.outCardInfo;

	if outCardInfo.cardType then
		local t = ruleDao:getCardRuleById(outCardInfo.cardType);
		if not t then
			return false;
		end
		return t:check(data);
	end

	for i,v in ipairs(ruleDao:getAllCardTypes()) do
		local result, cardByte = v:check(data);
		-- Log.v("CardUtils.checkCardInfo, result", v.uniqueId, data.outCardInfo.cardList, result)
		if result then
			data.outCardInfo.cardType = v.uniqueId;
			return true;
		end
	end

	return false;
end

function CardUtils.getMatchCardTypes(data)
	local ruleDao = data.ruleDao;
	local outCardInfo = data.outCardInfo;
	local matchList = {};
	for i,v in ipairs(ruleDao:getAllCardTypes()) do
		local t = { ruleDao = ruleDao, outCardInfo = table.clone(outCardInfo) };
		if v:check(t) then
			table.insert(matchList, t.outCardInfo);
		end
	end
	return matchList;
end

function CardUtils.compareCards(ruleDao, outCardInfo, targetCardInfo)
	local t = ruleDao:getCardRuleById(outCardInfo.cardType);

	if outCardInfo.cardType == targetCardInfo.cardType then	
		-- Log.i("CardUtils.compareCards")
		return t:compare({
			ruleDao = ruleDao,
			outCardInfo = outCardInfo,
			targetCardInfo = targetCardInfo,
		});
	end

	return t.larger[targetCardInfo.cardType] == true;
end

--升级类比较大小规则
function CardUtils.compareCards2(ruleDao, outCardInfo, targetCardInfo)
	-- if outCardInfo.cardType ~= targetCardInfo.cardType then
	-- 	return false;
	-- end

	local mainColor = ruleDao:getMainColor();
	if outCardInfo.cardColor == mainColor  --主压副时牌型要一致，，否者往下继续判断
		and targetCardInfo.cardColor ~= mainColor 
		and outCardInfo.cardType == targetCardInfo.cardType then
		return true;
	end
    ----跨牌型压牌
    if outCardInfo.cardType ~= targetCardInfo.cardType then
		local targetCardRule = ruleDao:getCardRuleById(targetCardInfo.cardType)
		if not targetCardRule.less then
			return false
		end
		for _, lessType in ipairs(targetCardRule.less) do
			if lessType == outCardInfo.cardType then
				return true
			end
		end
		return false
	end

	local t = ruleDao:getCardRuleById(outCardInfo.cardType);
	return t:compare({
		ruleDao = ruleDao,
		outCardInfo = outCardInfo,
		targetCardInfo = targetCardInfo,
	});
end

function CardUtils.removeCards(cardList, removeList)
	local index = 1
	for i,removeCard in ipairs(removeList) do
		for j,card in ipairs(cardList) do
			if removeCard == card then
				table.remove(cardList,j)
				break
			end
		end
	end
	return cardList
end

function CardUtils.getCardMapByColor(cardList)
	local t = {};
	for i,v in ipairs(cardList) do
		if v.color >= 0 and v.color <= 3 then
			if not t[v.color] then
				t[v.color] = {};
			end
			table.insert(t[v.color], v);
		end
	end
	return t;
end

function CardUtils.getCardsByColor(cardList, color)
	local t = {};
	for i,v in ipairs(cardList) do
		if v.color == color then
			table.insert(t, v);
		end
	end
	return t;
end

function CardUtils.getCardMapByValue(cardList)
	local t = {};
	for i,v in ipairs(cardList) do
		if not t[v.value] then
			t[v.value] = {};
		end
		table.insert(t[v.value], v);
	end
	return t;
end

function CardUtils.getCardsByValue(cardList, value)
	local t = {};
	for i,v in ipairs(cardList) do
		if v.value == value then
			table.insert(t, v);
		end
	end
	return t;
end

function CardUtils.getCardsByByte(cardList, byte)
	local t = {};
	for i,v in ipairs(cardList) do
		if Card.getNormalByte(v) == byte then
			table.insert(t, v);
		end
	end
	return t;
end

function CardUtils.isMainCard(ruleDao, card)
	local mainColor = ruleDao:getMainColor();
	local mainValue = ruleDao:getMainValue();
	local mainCards = ruleDao:getGameConfig("mainCards");

	if type(card) == "table" then
		local normalByte = Card.getNormalByte(card);
		return card.color == mainColor or card.value == mainValue or mainCards[normalByte] == true;
	elseif type(card) == "number" then
		if mainCards[card] == true then return true end
		local value, color = CardUtils.getCardAttrFromByte(card);
		return color == mainColor or value == mainValue;
	end
end

function CardUtils.isOtherMainCard(ruleDao, card)
	local mainValue = ruleDao:getMainValue();
	local mainCards = ruleDao:getGameConfig("mainCards");
	local normalByte = Card.getNormalByte(card);
	return card.value == mainValue or mainCards[normalByte] == true;
end

function CardUtils.getColorCountPriority(ruleDao, cardList, excludeColor)
	local allColor = {-1,0,1,2,3}
	for _,exclude in ipairs(excludeColor or {}) do
		for i,color in ipairs(allColor) do
			if exclude == color then
				table.remove(allColor, i);
				break
			end
		end
	end
	local t = {}
	for _,color in ipairs(allColor) do
		local colorCardList = CardUtils.getCardsByColor2(ruleDao, cardList, color)
		-- Log.v("CardUtils.getColorCountPriority", color, colorCardList)
		table.insert(t, {color = color, cardList = colorCardList})
	end
	table.sort(t, function(a, b)
		return #a.cardList < #b.cardList
	end)
	return t
end

function CardUtils.getColorPriorityByCount(ruleDao, colorMap, excludeColor, queue)
	queue = queue or 0  -- 0 表示少的优先级更高
	local allColor = {0,1,2,3}
	for _,color in ipairs(excludeColor) do
		table.removeByValue(allColor, color)
	end
	---colorMap中存在对应花色的牌数量为零的情况
	for i = #allColor, 1, -1 do
		if #colorMap[allColor[i]] == 0 then
			table.removeByValue(allColor, allColor[i])
		end
	end
	table.sort(allColor, function(a, b)
		if #colorMap[a] == #colorMap[b] then
			return a > b
		end
		if queue == 0 then
			return #colorMap[a] < #colorMap[b]
		else
			return #colorMap[a] > #colorMap[b]
		end
	end)
	return allColor
end

function CardUtils.getCardsByColor2(ruleDao, cardList, color)
	local mainColor = ruleDao:getMainColor();
	local mainValue = ruleDao:getMainValue();
	local mainCards = ruleDao:getGameConfig("mainCards");
	local t = {};
	for i,v in ipairs(cardList) do
		if v.color == color and color == mainColor then
			table.insert(t, v);
		elseif v.color == color then
			if not CardUtils.isMainCard(ruleDao, v) then
				table.insert(t, v);
			end
		elseif color == mainColor then
			if CardUtils.isMainCard(ruleDao, v) then
				table.insert(t, v);
			end
		else
			--DoNothing
		end
	end
	return t;
end

-- 通过牌型名称 获取 牌绝对ID
function CardUtils.getUniqueIdByName(ruleDao, name)
	local t = ruleDao:getCardRuleByName(name);
	return t and t.uniqueId or nil;
end

function CardUtils.getNameByUniqueId(ruleDao, id)
	local t = ruleDao:getCardRuleById(id);
	return t and t.name or nil;
end

function CardUtils.getCardRuleByName(ruleDao, name)
	return ruleDao:getCardRuleByName(name);
end

function CardUtils.getOrigCard(ruleDao, cards)
	local cardList = {}
	for i,card in ipairs(cards) do
		if CardUtils.isLaizi(ruleDao, card) then
			cardList[i] = CardUtils.getLaiziOriginalCard(ruleDao, card)
		else
			cardList[i] = card
		end
	end
	return cardList
end

function CardUtils.findCardsByType(ruleDao, srcCardStack, typeId, findAll, ignoreContext)
	local rule = ruleDao:getCardRuleById(typeId);
	if not rule then
		Log.e("CardUtils.findCardsByType, invalid type", typeId, debug.traceback());
		return {}
	end

	local data = {
		ruleDao 		= ruleDao, 
		srcCardStack 	= srcCardStack:clone(),
		queue 			= 0,
		ignoreContext   = ignoreContext,
	}
	local findList = {};
	while true do
		if #data.srcCardStack:getCardList(true) == 0 then 
			break 
		end
		
		local find = rule:find(data)
		if find then
			data.srcCardStack:removeCards(find.cardList)
			findList[#findList+1] = find
			if findAll ~= true then
				break;
			end
		else
			break
		end
	end
	return findList, data.srcCardStack;
end

function CardUtils.findCardsByTarget(ruleDao, srcCardStack, targetCardInfo, findAll)
	local rule = ruleDao:getCardRuleById(targetCardInfo.cardType);
	if not rule then
		Log.e("CardUtils.findCardsByTarget, invalid type", targetCardInfo.cardType, debug.traceback());
		return {}
	end

	local data = {
		ruleDao 		= ruleDao,
		srcCardStack 	= srcCardStack:clone(),
		targetCardInfo 	= targetCardInfo,
	}
	local findList = {};
	while true do
		if #data.srcCardStack:getCardList(true) == 0 then 
			break 
		end
		local find = rule:find(data)
		-- Log.v("CardUtils.findCardsByTarget", data.targetCardInfo, data.srcCardInfo)
		if find then 
			data.srcCardStack:removeCards(find.cardList)
			findList[#findList+1] = find
			if findAll ~= true then
				break;
			end
		else
			break
		end
	end
	return findList, data.srcCardStack;
end

function CardUtils.getCardLogicColor(ruleDao, card)
	local isMain = CardUtils.isMainCard(ruleDao, card);
	return isMain and ruleDao:getMainColor() or card.color;
end

function CardUtils.getSingleCardSize(ruleDao)
	local t = ruleDao:getCardRuleByName(g_GameConst.CARD_TYPE.SINGLE);
	return t.byteToSize;
end

function CardUtils.sortCards(ruleDao, cardList)
	local byteToSize = ruleDao:getCardRuleByName(g_GameConst.CARD_TYPE.SINGLE).byteToSize;
	table.sort(cardList, function (a,b)
		local sizeA = byteToSize[a.byte]
		local sizeB	= byteToSize[b.byte]
		if sizeA ~= sizeB then
			return sizeA > sizeB
		else
			return a > b
		end
	end)
end

function CardUtils.getCardPoint(ruleDao, card)
	local pointCards = ruleDao:getGameConfig("pointCards");
	local normalByte = Card.getNormalByte(card);
	return pointCards[normalByte] or 0;
end

function CardUtils.getColorMapByCards2(ruleDao, cards)
	local t = {};
	setmetatable(t, __defaultTab)
	for i,v in ipairs(cards) do
		local color = CardUtils.getLogicColor(ruleDao, v);
		table.insert(t[color], v);
	end
	return t;
end

-------------------------- 癞子 --------------------------------

-- 是否是癞子
function CardUtils.isLaizi(ruleDao, card)
	local laizi = ruleDao:getGameData("c_laiziList") or {};
	local normalByte = Card.getNormalByte(card);
	if laizi[card.flag] or laizi[normalByte] then
		return true;
	end
	return false;
end

-- 是否是指定牌的癞子
function CardUtils.isTargetLaizi(ruleDao, card, targetCard)
	if not CardUtils.isLaizi(ruleDao, card) then
		return false;
	end

	local laiziReplace = ruleDao:getGameData("c_laiziReplacement") or {};
	local normalByte = Card.getNormalByte(targetCard);
	if Card.isTributeByte(normalByte) then
		normalByte = Card.getTributeOrigByte(normalByte);
	end
	if laiziReplace[normalByte] then
		return true;
	end
	return false;
end

--[[
	-- 获取癞子
	param laiziCard 癞子牌
	param target 癞子要充当的牌
]]
function CardUtils.getLaiziCard(ruleDao, laiziCard, target)
	-- if not CardUtils.isLaizi(ruleDao, laiziCard) then
	-- 	Log.e("laiziCard is not laizi", laiziCard);
	-- 	return laiziCard;
	-- end

	local cardFlag = 0;
	if laiziCard.flag > 0 and laiziCard.flag <= 0x4f then
		cardFlag = laiziCard.flag;
	else
		cardFlag = Card.getNormalByte(laiziCard);
	end
	local normalByte = Card.getNormalByte(target);
	return Card.new(bit.blshift(cardFlag, 8) + normalByte);
end

-- 获取癞子的原始牌
function CardUtils.getLaiziOriginalCard(ruleDao, card)
	if not CardUtils.isLaizi(ruleDao, card) then
		return card;
	elseif card.flag > 0 and card.flag <= 0x4f then
		return Card.new(card.flag);
	else
		return card;
	end
end

-- 获取原始牌组
function CardUtils.getLaiziOriginalCardList(ruleDao, cards)
	local cardList = {};
	for i,card in ipairs(cards) do
		if CardUtils.isLaizi(ruleDao, card) and card.flag > 0 and card.flag <= 0x4f then
			cardList[i] = Card.new(card.flag);
		else
			cardList[i] = card;
		end
	end
	return cardList;
end

-- 牌组里是否有癞子
function CardUtils.hasLaizi(ruleDao, cards)
	for i,card in ipairs(cards) do 
		if CardUtils.isLaizi(ruleDao, card) then
			return true;
		end
	end
	return false;
end

--获取牌组里癞子的数量
function CardUtils.getLaiZiNum(ruleDao,cards)
	local num = 0 
	for i,card in ipairs(cards) do 
		if CardUtils.isLaizi(ruleDao, card) then
			num = num+1
		end
	end
	return num
end

-- 获取牌组里癞子牌的列表
function CardUtils.getLaiZiList(ruleDao, cards)
	local laiZiList = {}
	for i,card in ipairs(cards) do 
		if CardUtils.isLaizi(ruleDao,card) then 
			table.insert(laiZiList,card)
		end
	end
	return laiZiList
end

-- 获取牌组里原生牌的列表
function CardUtils.getOrigList(ruleDao,cards)
	local origList = {}
	for i,card in ipairs(cards) do
		if not CardUtils.isLaizi(ruleDao,card) then 
			table.insert(origList,card)
		end
	end
	return origList
end

-- 更新癞子配置
--[[
	cfg = {
		laiziCfg = { [0x4e] = true, [0x4f] = true},
		replaceCfg = { [0x01] = true, [0x02] = true },
	}
]]
function CardUtils.updateLaiziCfg(tableDB, cfg)
	if cfg.laiziCfg then
		tableDB:setGameData("c_laiziList", cfg.laiziCfg);
	end

	if cfg.replaceCfg then
		tableDB:setGameData("c_laiziReplacement", cfg.replaceCfg);
	end
end

--------------------------------------------------------------

-- format 支持： 花色+牌点/牌点/花色/X张花色+牌点/X张花色/X张牌点
-- packs 几幅牌
function CardUtils.getCardBytesByFormat(tableDB, format, packs)
	local function getByteByValue(parseValue)
		local str = parseValue and tostring(parseValue) or ""
		-- 花色+牌点
		local byte = Card.ByteMap:getKeyByValue(str)
		if byte then
			return {byte}
		end

		-- 牌点
		local value = Card.ValueMap:getKeyByValue(str)
		if value then
			local tmp = {}
			local keyValue = Card.ByteMap:getKeyValueMap()
			for k,v in pairs(keyValue) do
				local startIdx, endIdx = string.find(v,tostring(str)) 
				if startIdx and endIdx then
					table.insert(tmp,k)
				end
			end
		    return tmp
		end

		-- 花色
		local color = Card.ColorMap:getKeyByValue(str)
		if color then
			local tmp = {}
			local keyValue = Card.ByteMap:getKeyValueMap()
			for k,v in pairs(keyValue) do
				local startIdx, endIdx = string.find(v,tostring(str)) 
				if startIdx and endIdx then
					table.insert(tmp,k)
				end
			end
		    return tmp
		end
	end


	local function getByteByParseValue(parseValue,packs)
		local str = parseValue and tostring(parseValue) or ""
		local startIdx, endIdx = string.find(str, "张");
		if startIdx and endIdx then
			local num = tonumber(string.sub(str, 1, startIdx-1));
			str = string.sub(str, endIdx-string.len(str));

			local cardBytes = getByteByValue(str)
			if cardBytes then
				local tmp = {}
				for i = 1, packs do
					table.copyTo(tmp,cardBytes)
				end
				return table.random(tmp, num)
			end
		end
	end

	packs = packs or 1
	local cardBytes = {}
	if format then
		local filterStr = string.split(format,",")
		for k,v in pairs(filterStr) do
			local bytes = getByteByValue(v)
			if bytes then
				table.copyTo(cardBytes,bytes)
			else
				local parseBytes = getByteByParseValue(v,packs)
				if parseBytes then
					table.copyTo(cardBytes,parseBytes)
				end
			end
		end
	end

	return cardBytes
end


--[[ 
	------warning---------
	根据目标牌找出能压的牌,支持跨牌型 --升级类游戏 要求张数一致
	allowRepeat 是否允许某些重复的牌，主要是跨牌型压甩牌是可能涉及到不同的拆牌组合
	ignoreSize 是否只要找同牌型，忽视大小,跟压甩牌时同一组优先级，只比较最大的就行
]]

--处理返回结果的截断，，例如如果allowRepeat为true，可能截断 334455 --->> 3344 和 4455
local function parseBiggerTypeResult(ruleDao, finds, srcCardStack, targetLength, allowRepeat)
	if #finds == 0 then
		return {}, srcCardStack
	end
	local srcCardStack = srcCardStack:clone()
	local findList = {}
	for _, find in pairs(finds) do
		local count = #find.cardList
		if count > targetLength then
			local lastdeleteIndex = count --记录下最后删除的位置

			local _ = not allowRepeat and srcCardStack:removeCards(find.cardList)

			local offset = allowRepeat and find.offset or targetLength
			for i = 1, #find.cardList - targetLength + 1, offset do
				local find2 = {}
				find2.cardList = {}
				for j = i, i + targetLength - 1 do
					table.insert(find2.cardList, find.cardList[j])
					lastdeleteIndex = j
				end

				local data = {}
				data.ruleDao = ruleDao
				data.outCardInfo = find2
				ruleDao:getCardRuleById(find.cardType):check(data) --重新封装cardByte等数据

				table.insert(findList, data.outCardInfo)
			end
			for k = lastdeleteIndex + 1, count do --如果找到的牌张数不能符合整数倍关系，将多删除的牌补回
				local _ = not allowRepeat and srcCardStack:addCard(find.cardList[k])
			end
		elseif count == targetLength then
			local _ = not allowRepeat and srcCardStack:removeCards(find.cardList)
			table.insert(findList, find)
		end
	end
	return findList, srcCardStack
end

function CardUtils.findCardsByTarget2(ruleDao, srcCardStack, targetCardInfo, findAll, allowRepeat, ignoreSize)
	local findAll = findAll 
	local allowRepeat = allowRepeat --是否一张牌允许重复使用, 
	local ignoreSize = ignoreSize --是否只是找同牌型，不需要压牌
	Log.v("findCardsByTarget2", allowRepeat, ignoreSize)
	local rule = ruleDao:getCardRuleById(targetCardInfo.cardType);
	if not rule then
		Log.e("CardUtils.findCardsByTarget2, invalid type", targetCardInfo.cardType, debug.traceback());
		return {}
	end

	local data = {
		ruleDao 		= ruleDao,
		srcCardStack 	= srcCardStack:clone(),
		targetCardInfo 	= targetCardInfo,
	}

	local findList = {};
	local leftCards = {};
	local finds = CardUtils._findCardsByTargetInBiggerType(ruleDao, data.srcCardStack, targetCardInfo, findAll, allowRepeat)
	findList, leftCards = parseBiggerTypeResult(ruleDao, finds, data.srcCardStack, #targetCardInfo.cardList,allowRepeat)

	if not findAll and #findList > 0 then
		return findList, data.srcCardStack
	end

	if not allowRepeat then --不允许重复使用，甩牌时可能要遍历所有组合，所以可能涉及到连对会到连三中拆牌的情况
		data.srcCardStack = leftCards
	end

	if ignoreSize == true then --忽视大小，按牌型找，并截取长度相同的
		local finds = CardUtils.findCardsByType(ruleDao, data.srcCardStack, rule.uniqueId, findAll)
		local findList2 = finds
		if rule.offset ~= 0 then ----------- Waring------------对子，三张等不需要进行偏移截取
			for _, find in pairs(finds) do
				find.offset = rule.offset
			end
			findList2 = parseBiggerTypeResult(ruleDao, finds, data.srcCardStack, #targetCardInfo.cardList, allowRepeat)
		end
		for _, find in pairs(findList2) do
			table.insert(findList, find)
		end
	else
		if allowRepeat and findAll then --循环找出所有能压的牌，诸如连对等牌型可能会重复使用一些牌
			local targetCardInfo = targetCardInfo
			while true do
				local find = rule:find({ruleDao = ruleDao, srcCardStack = data.srcCardStack, targetCardInfo = targetCardInfo, queue = 1})
				----TODO: lineBase2 找牌可能有问题，，，检查
				if not find or not find.cardList then
					break
				end
				table.insert(findList, find)
				targetCardInfo = find
			end
		else		
			local finds, leftCards = CardUtils.findCardsByTarget(ruleDao, data.srcCardStack, targetCardInfo, findAll)
			for _, find in pairs(finds) do
				table.insert(findList, find)
			end
			data.srcCardStack = leftCards
		end
	end
	return findList, data.srcCardStack;
end

--------****************private method************---------
--找出更大的牌型的牌，升级类游戏
function CardUtils._findCardsByTargetInBiggerType(ruleDao, srcCardStack, targetCardInfo, findAll, allowRepeat)
	local rule = ruleDao:getCardRuleById(targetCardInfo.cardType);
	if not rule then
		Log.e("CardUtils.findCardsByTarget2, invalid type", targetCardInfo.cardType, debug.traceback());
		return 
	end
	local bigRules = {}
	if rule.less and #rule.less > 0 then
		for _, id in pairs(rule.less) do
			local rule2 = ruleDao:getCardRuleById(id)
			if rule2.offset == 0 or #targetCardInfo.cardList % rule2.offset == 0 then --是否能满足张数要求，比如用四拖拉机压制三拖拉机，必须张数是12的倍数才符合
				table.insert(bigRules, rule2)
			end
		end
	end

	if #bigRules <= 0 then
		return {}
	end

	local findList = {}
	local srcCards = srcCardStack:clone()
	for _, rule in pairs(bigRules) do
		local finds, leftCards = CardUtils.findCardsByType(ruleDao, srcCards, rule.uniqueId, findAll)
		if #finds > 0 then
			for _, find in pairs(finds) do
				find.offset = rule.offset
				table.insert(findList, find)
				if findAll ~= true then
					return findList, leftCards
				end
			end
		end
		if not allowRepeat then
			srcCards = leftCards
		end
	end
	return findList
end

return CardUtils;