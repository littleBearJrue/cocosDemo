--[[--ldoc desc
@module ParseUtils
@author RonanLuo

Date   2018-01-25 15:29:11
Last Modified by   JamesYang
Last Modified time 2018-08-31 11:36:23
]]

--[[
	数量	花色		牌点
	1/2张	主花色		级别牌
			副花色		3/4/5/6/7/../小王/大王
			黑红梅方
			同花色

	分隔符优先级: > / +
]]

local ParseUtils = {}

local __defaultColors = {0,1,2,3}

local __colorFunc = {
	["主花色"] = function (ruleDao, flowData)
		local mainColor = ruleDao:getMainColor();
		if mainColor >= 0 then
			flowData.color = mainColor;
		end
	end,
	["副花色"] = function (ruleDao, flowData)
		local mainColor = ruleDao:getMainColor();
		flowData.ANDs = {};
		for i=0,3 do
			if i ~= mainColor then
				table.insert(flowData.ANDs, {color = i});
			end
		end
	end,
	["同花色"] = function ( ruleDao, flowData )
		flowData.ORs = {};
		for i,v in ipairs(__defaultColors) do
			table.insert(flowData.ORs, {color = v});
		end
	end,
	["黑桃"] = function ( ruleDao, flowData )
		flowData.color = 3;
	end,
	["红桃"] = function ( ruleDao, flowData )
		flowData.color = 2;
	end,
	["梅花"] = function ( ruleDao, flowData )
		flowData.color = 1;
	end,
	["方块"] = function ( ruleDao, flowData )
		flowData.color = 0;
	end,
	["方片"] = function ( ruleDao, flowData )	
		flowData.color = 0;
	end,
}

--解析特殊花色
local function __parseCardColor(ruleDao, flowData)
	for k,v in pairs(__colorFunc) do
		local startIdx, endIdx = string.find(flowData.args, k);
		if startIdx and endIdx then
			v(ruleDao, flowData);
			flowData.args = string.sub(flowData.args, endIdx-string.len(flowData.args));
			break;
		end
	end
end

--解析牌张数
local function __parseCardNumber(ruleDao, flowData)
	local startIdx, endIdx = string.find(flowData.args, "张");
	if startIdx and endIdx then
		local numberStr = string.sub(flowData.args, 1, startIdx-1)
		flowData.number = tonumber(numberStr);
		flowData.args = string.sub(flowData.args, endIdx-string.len(flowData.args));
	else
		flowData.number = 1;
	end
end

--解析牌值
local function __parseCardValue(ruleDao, flowData)
	local value;
	repeat
		--对应具体牌值
		local byte = Card.ByteMap:getKeyByValue(flowData.args);
		if byte then
			flowData.byte = byte;
			flowData.value, flowData.color = CardUtils.getCardAttrFromByte(byte);
			return;
		end

		--对应级别牌
		if flowData.args == "级别牌" then			
			value = ruleDao:getMainValue();
			break;
		end

		--对应牌点
		value = Card.ValueMap:getKeyByValue(flowData.args);
		if value then
			break;
		end

		if not value then
			return;
		end
	until true

	--前面解析有具体花色限制
	if flowData.color then
		flowData.value = value;
		flowData.byte = CardUtils.getCardByteFromAttr(value, flowData.color);
		return;
	end

	--副花色/同花色区别处理
	local t = flowData.ANDs or flowData.ORs;
	if t then
		for i,v in ipairs(t) do
			v.value = value;
			v.byte = CardUtils.getCardByteFromAttr(value, v.color);
		end
		return;
	end

	--没有花色限制
	flowData.value = value;
end

--解析单个牌单元
local function __parseCardUnit(ruleDao, args, flowData)
	__parseCardNumber(ruleDao, flowData);
	__parseCardColor(ruleDao, flowData);
	__parseCardValue(ruleDao, flowData);
end

--[[
规则库牌张参数统一解析,符号顺序为 1.> 2.+ 3./
特殊花色参数:同花色，解析到 ORs 列表里
特殊花色参数:副花色，解析到 ANDs 列表里
	args:大王+同花色级别牌/小王+副花色级别牌(级别牌2，主花色红桃)
	result:  {{
		memberList={
			{number=1,byte=79,value=17,color=4},
			{number=1,ORs={{value=15,byte=2,color=0},{value=15,byte=18,color=1},{value=15,byte=34,color=2},{value=15,byte=50,color=3}}}},
			size=1},{
		memberList={
			{number=1,byte=78,value=16,color=4},
			{number=1,ANDs={{value=15,byte=2,color=0},{value=15,byte=18,color=1},{value=15,byte=50,color=3}}}},
			size=1}
		}
]]
function ParseUtils.parseCardByArgs(ruleDao, args)
	local arr1 = string.split(args, ">")
	local maxSize = #arr1;
	local result = {};
	for i1,v1 in ipairs(arr1) do
		local size = maxSize - i1 + 1;
		local arr2 = string.split(v1, "/");
		for i2,v2 in ipairs(arr2) do
			local sizeInfo = {size = size, memberList = {}, args = v2};
			local arr3 = string.split(v2, "+");
			for i3,v3 in ipairs(arr3) do
				local flowData = {args = v3};
				__parseCardUnit(ruleDao, v3, flowData)
				table.insert(sizeInfo.memberList, flowData);
				flowData.args = nil;
			end
			table.insert(result, sizeInfo);
		end
	end
	return result;
end

function ParseUtils.getOpCodeByName(name)
	local map = g_GameCodeMap
	local opCode = map[name]
    Log.i("util.getOpCodeByName", name)
	assert(opCode,"没有添加对应的opCode名称映射 "..name)
	return opCode
end

--规则库opcode参数统一解析,符号顺序为 1./ 2.+
-- result:  {{
-- 	memberList={
-- 		{},
-- 		{},
-- 		opcode=1},{
-- 	memberList={
-- 		{opcode = 1},
-- 		{opcode = 2}
--      opcode = 2}
-- 	}
function ParseUtils.parseOpCodeNamesByArgs(args)
	Log.i("ParseUtils.parseOpCodeNamesByArgs",args);
	local result = {};
	local arr1 = string.split(args, "/");
	for i1,name1 in ipairs(arr1) do
		local opInfo = {};
		local arr2 = string.split(name1, "+");
		if #arr1 > 1 and #arr2 > 1 then  ---不支持 "/" 和 "+" 同时存在的情况 ，找产品重新配置规则
			assert(false , "invalid parse args:"..args);
		end
		for i2,name in ipairs(arr2) do
			local opcode = ParseUtils.getOpCodeByName(name)
			table.insert(opInfo, opcode);
		end
		table.insert(result, opInfo);
	end
	return result;
end


--根据参数解析结果从 cardStack 里去查找满足条件的成员
--此处不考虑每个 member 包含重复的牌，有可能导致统计错误
function ParseUtils.checkCardsByParseArgs(ruleDao, cardStack, args)
	local function findCardsByInfo(info)
		if info.byte then
			return cardStack:getCardsByByte(info.byte);
		elseif info.value then
			return cardStack:getCardsByValue(info.value);
		else
			error("invalid card info!!!");
		end
	end

	--根据 memberList 的 member 判断是否满足张数
	local function checkCardsByMember(member)
		local result = {};
		if member.byte or member.value then
			local findCards = findCardsByInfo(member);
			while #findCards > member.number do
				table.remove(findCards, 1);
			end
			if #findCards >= member.number then
				table.insert(result, findCards);
			end
		elseif member.ANDs then
			local totalNum = member.number;
			local findTotal = {};
			for i,v in ipairs(member.ANDs) do
				local findCards = findCardsByInfo(v);
				while #findCards > totalNum do
					table.remove(findCards, 1);
				end
				totalNum = totalNum - findNum;
				table.insert(findTotal, findCards);
				if totalNum <= 0 then
					break;
				end
			end
			if totalNum <= 0 then
				local t = {};
				for i,v in ipairs(findTotal) do
					table.copyTo(t, v);
				end
				table.insert(result, result);
			end
		elseif member.ORs then
			local totalNum = member.number;
			for i,v in ipairs(member.ORs) do
				local findCards = findCardsByInfo(v);
				while #findCards > totalNum do
					table.remove(findCards, 1);
				end
				if #findCards >= totalNum then
					table.insert(result, findCards);
				end
			end
		end
		return result;
	end

	local result = {};
	local parseArr = ParseUtils.parseCardByArgs(ruleDao, args);
	for i,parseItem in ipairs(parseArr) do
		parseItem.result = {};
		local isFind = true;
		for i,v in ipairs(parseItem.memberList) do
			local result = checkCardsByMember(v);
			if #result == 0 then
				isFind = false;
				break;
			elseif #result == 1 then
				table.copyTo(parseItem.result, result[1]);
			else
				assert(not parseItem.result.options, "invalid parse args:"..parseItem.args);
				parseItem.result.options = result;
			end
		end
		if isFind then
			table.insert(result, parseItem);
		end
	end
	return result;
end

--[[
	处理顺子(连对)的连牌方式   "A-2-3-4-A-2" 拆分成  A-2-3 3-4-A-2
]]
function ParseUtils.parseLineMap(lineStr)
    local lineMap = {}
    local strArr = string.split(lineStr,"/")
    for _,str in ipairs(strArr) do
        local temp = {}
        local splitTemp = {}
        local arr = string.split(str, "-") 
        for i=#arr, 2, -1 do 
            table.insert(temp, 1, {curValue = arr[i-1], nextValue = arr[i] })
        end

        -- 若有循环连牌方式，找出小的连牌方式
        local temp_one = temp[1]
        for i = #temp, 3, -1 do
            local repeatCard = temp[i]
            if temp_one.curValue == repeatCard.nextValue then
                splitTemp = {}
                for index = 1, i - 2 do
                    table.insert(splitTemp, temp[index])
                end
                table.insert(splitTemp, {curValue = splitTemp[#splitTemp].nextValue})
                table.insert(lineMap, splitTemp)
                break
            end
        end

        -- 若有循环连牌方式，找出大的连牌方式
        local temp_end = temp[#temp]
        for i = 1, #temp - 1 do
            local repeatCard = temp[i]
            if temp_end.nextValue == repeatCard.curValue then
                splitTemp = {}
                for index = i + 1, #temp do
                    table.insert(splitTemp, temp[index])
                end
                table.insert(splitTemp, {curValue = splitTemp[#splitTemp].nextValue})
                table.insert(lineMap, splitTemp)
                break
            end
        end

        -- 若没有循环连牌方式，则整个是一个连牌方式
        if #splitTemp == 0 then
            table.insert(temp, {curValue = temp[#temp].nextValue})
            table.insert(lineMap,temp)
        end
    end
    return lineMap
end

-- 解析 对子>单牌 这种参数
-- return {cardRule1, cardRule2}  顺序和 >(分隔符) 无关
function ParseUtils.getCardRuleByNameSplit(ruleDao, str, sep)
	local allName = string.split(str, sep)
	local allCardRule = {}
	for _,name in ipairs(allName) do
		local cardRule = ruleDao:getCardRuleByName(name)
		table.insert(allCardRule, cardRule)
	end
	return allCardRule
end

--[[
解析 炸弹>飞机>三条>连对/顺子>对子>单牌 这种参数
return sequences = {
	[1]={炸弹,飞机,三条,连对,对子,单牌},
	[2]={炸弹,飞机,三条,顺子,对子,单牌},
}
]]
function ParseUtils.getCardRuleDiffrentSequenceByNameSplit(ruleDao, str, sep1, sep2)
	local sequences = {}
	local function getSequences(ret, params)
		table.insert(ret,{})
		local cardTypeNames = string.split(params,sep1)
		for _,name in ipairs(cardTypeNames) do
			local sybNames = string.split(name,sep2)
			if #sybNames > 1 then
				local cnt = #ret
				for i=1,#sybNames-1 do
					for i=1,cnt do
						local nextOrder = clone(ret[i])
						table.insert(ret,nextOrder)
					end
				end
				for i=1,#sybNames do
					local cardType = ruleDao:getCardRuleByName(sybNames[i])
					for j=1,cnt do
						table.insert(ret[(i-1)*cnt+j],cardType)
					end
				end
			else
				local cardType = ruleDao:getCardRuleByName(name) 
				for k,v in ipairs(ret) do
					table.insert(v,cardType)
				end
			end
		end
	end
	getSequences(sequences,str)
	return sequences
end

--[[
解析 炸弹>飞机>连对/顺子>单牌 这种参数
return sequences = {
	[1]={炸弹},
	[2]={飞机},
	[3]={连对,顺子},
	[4]={单牌},
}
]]
function ParseUtils.getCardRuleSameSequencesByNameSplit(ruleDao, str, sep1, sep2)
	local allName = string.split(str, sep1)
	local sequences = {}
	for _,name in ipairs(allName) do
		local sybNames = string.split(name,sep2)
		local subOrder = {}
		for k,v in ipairs(sybNames) do
			local cardRule = ruleDao:getCardRuleByName(v)
			table.insert(subOrder, cardRule)
		end
		table.insert(sequences, subOrder)
	end
	return sequences
end

return ParseUtils;