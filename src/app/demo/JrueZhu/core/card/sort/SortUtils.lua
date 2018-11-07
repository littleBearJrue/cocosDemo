--[[--ldoc desc
@module SortUtils
@author RonanLuo

Date   2018-01-16 11:44:26
Last Modified by   LisaChen
Last Modified time 2018-07-11 16:39:15
]]

local SortUtils = {};
local M = SortUtils;

M.SortFlag = {
	DEFAULT = 0,
	SJ1 = 1,    --  升级连对/姐妹对不补齐牌点，不连续
	SJ2 = 2,    --  双扣
}

local kPointNumber = 13;

local function __setCardSizeBySortInfo(sortInfo, byte, value, color, size)
	if not byte then
		byte = CardUtils.getCardByteFromAttr(value, color);
	end

	if sortInfo.result[byte] then
		return -1;
	end

	if not value or not color then
		value, color = CardUtils.getCardAttrFromByte(byte);
	end

	if not size then
		size = sortInfo.curSize;
	end

	if sortInfo.fillGap and sortInfo.fillGap[color] then
		size = size + sortInfo.fillGap[color];
	end

	sortInfo.result[byte] = size;
	return size;
end

local s_setterInfo = {
	map = {
		["主级别牌"] = function (ruleDao, sortInfo)
			local mainColor = ruleDao:getMainColor();
			if mainColor < 0 then
				return;
			end

			local mainValue = ruleDao:getMainValue();
			local result = __setCardSizeBySortInfo(sortInfo, nil, mainValue, mainColor);

			if result == -1 and sortInfo.sortFlag == M.SortFlag.SJ2 then
				for i=0,3 do
					sortInfo.fillGap[i] = (sortInfo.fillGap[i] or 0) + 1;
				end
			end
		end,
		["副级别牌"] = function (ruleDao, sortInfo)
			local mainColor = ruleDao:getMainColor();
			if mainColor < 0 then
				return;
			end

			local mainValue = ruleDao:getMainValue();
			for i=0,3 do
				if i ~= mainColor then
					__setCardSizeBySortInfo(sortInfo, nil, mainValue, i);
				end
			end
		end,
		["级别牌"] = function (ruleDao, sortInfo)
			local mainValue = ruleDao:getMainValue();
			for i=0,3 do
				__setCardSizeBySortInfo(sortInfo, nil, mainValue, i);
			end
		end,	
		["级牌"] = function (ruleDao, sortInfo)
			local mainValue = ruleDao:getMainValue();
			for i=0,3 do
				__setCardSizeBySortInfo(sortInfo, nil, mainValue, i);
			end
		end,	
	},
	match = {
		["(主花色)(%w+)"] = function (ruleDao, sortInfo, valueStr)
			local mainColor = ruleDao:getMainColor();
			if mainColor < 0 then
				return;
			end
			local value = Card.ValueMap:getKeyByValue(valueStr);
			__setCardSizeBySortInfo(sortInfo, nil, value, mainColor);
		end,
		["(副花色)(%w+)"] = function (ruleDao, sortInfo, valueStr)
			local mainColor = ruleDao:getMainColor();
			if mainColor < 0 then
				return;
			end
			for i=0,3 do
				if i ~= mainColor then
					local value = Card.ValueMap:getKeyByValue(valueStr);
					__setCardSizeBySortInfo(sortInfo, nil, value, i);
				end
			end
		end,
	},
}

local function __setCardSizeByValue(ruleDao, sortInfo, value)
	-- Log.v("__setCardSizeByValue", value)
	if sortInfo.sortFlag == M.SortFlag.default then
		for i=0,3 do		
			__setCardSizeBySortInfo(sortInfo, nil, value, i, sortInfo.curSize);
		end
		return;
	end

	for i=0,3 do
		local byte = CardUtils.getCardByteFromAttr(value, i);
		local result;
		if CardUtils.isMainCard(ruleDao, byte) and sortInfo.isDistinguishZhuFu then
			result = __setCardSizeBySortInfo(sortInfo, byte, value, i, sortInfo.curSize);
		else
			result = __setCardSizeBySortInfo(sortInfo, byte, value, i, sortInfo.curSize - kPointNumber);
		end

		if result == -1 and sortInfo.sortFlag == M.SortFlag.SJ2 then
			sortInfo.fillGap[i] = (sortInfo.fillGap[i] or 0) + 1;
		end
	end
end

local function __setCardSize(ruleDao, sortInfo, args)
	-- Log.v("M.setCardSize", args, type(args), sortInfo.curSize, sortInfo.fillGap)
	--是否具体牌值
	local byte = Card.ByteMap:getKeyByValue(args);
	if byte then
		return __setCardSizeBySortInfo(sortInfo, byte, nil, nil, sortInfo.curSize);
	end

	--是否具体牌点
	local value = Card.ValueMap:getKeyByValue(args);
	if value then
		return __setCardSizeByValue(ruleDao, sortInfo, value);
	end

	--是否特殊手牌
	if s_setterInfo.map[args] then
		return s_setterInfo.map[args](ruleDao, sortInfo);
	end

	for k,v in pairs(s_setterInfo.match) do
		local t1,t2 = string.match(args, k)
		if t1 then
			return v(ruleDao, sortInfo, t2);
		end
	end

	error("invalid card size : "..args);
end

--普通排序
function M.getCardSize(data, cardSize)
	local arr1 = string.split(cardSize, '>');
	local sortInfo = {};
	sortInfo.result = {};
	sortInfo.totalSize = #arr1;
	sortInfo.sortFlag = data.sortFlag;
	if data.isDistinguishZhuFu ~= nil then
		sortInfo.isDistinguishZhuFu = data.isDistinguishZhuFu
	else
		sortInfo.isDistinguishZhuFu = true; -- 牌点大小是否区分主副牌
	end
	
	if sortInfo.sortFlag ~= M.SortFlag.default then
		sortInfo.totalSize = sortInfo.totalSize + kPointNumber; --加上副牌点数 3,4,...,K,A,2
		if sortInfo.sortFlag == M.SortFlag.SJ2 then
			sortInfo.fillGap = {};
		end
	end
	sortInfo.curSize = sortInfo.totalSize;

	for i,v in ipairs(arr1) do
		local arr2 = string.split(v, '/');		
		for _,v in ipairs(arr2) do
			__setCardSize(data.ruleDao, sortInfo, v);
		end
		sortInfo.curSize = sortInfo.curSize - 1;
	end

	return sortInfo.result;
end

return SortUtils;