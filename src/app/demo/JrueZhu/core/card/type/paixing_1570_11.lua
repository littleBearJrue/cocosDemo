-- @Author: JanzenWang
-- @Date:   2018-08-17 16:59:09
-- @Last Modified by:   JanzenWang
-- @Last Modified time: 2018-09-03 14:59:30

local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
	牌型：顺子/单龙
	特征：$1张及以上相连的单牌，连牌顺序【$2】不区分花色
 	例如：3 4 5 6
 	范围：3-4-5-...-Q-K-A
]]

function M:ctor(data)
    local typeArgs = data.typeRule.args
	local args = {}
	args.sameCount = 1
	args.minLength = tonumber(typeArgs[1])
    args.lineArgs = typeArgs[2]
	LineBase.init(self, args)
end

M.bindingData = {
	set = {},
	get = {},
}

function M:compare(data)
	local outCardList = data.outCardInfo.cardList
	local targetCardList = data.targetCardInfo.cardList
	if #outCardList ~= #targetCardList then 
		return false
	end

	if self.byteToSize[data.outCardInfo.cardByte] - self.byteToSize[data.targetCardInfo.cardByte] == 1 then
		return true
	end
end


local function buildMapList(self, params)
	local oriCards = params.oriCards;
	local queue = params.queue;
	local map = params.map;

	local oriCardStack = new(CardStack, {cards = oriCards})
	
	local low = queue == 1 and 1 or #map;
	local up = queue == 1 and #map or 1;
	local step = queue == 1 and 1 or -1;

	local mapList = {};
	for i=low, up, step do
		local nowMap = map[i];
		-- item：（cards：手牌非癞子，lacks：组成连张所缺的牌）
		local item = {cards = {}, lacks = {}};
		local cards = oriCardStack:getCardsByValue(Card.ValueMap:rget(nowMap.curValue));
		if #cards > 0 then
			local up = #cards > self.sameCount and self.sameCount or #cards;
			for j=1,up do
				table.insert(item.cards, cards[j]);
			end
			for j=up+1,self.sameCount do
				table.insert(item.lacks, nowMap.curValue);
			end
		else
			for j=1,self.sameCount do
				table.insert(item.lacks, nowMap.curValue);
			end
		end
		table.insert(mapList, item);
	end
	
	return mapList;
end

-- 获取某个序列所需要的癞子数
local function getSubSeqNeedLaiziCount(mapList, startIdx, endIdx)
	local count = 0;
	for i=startIdx, endIdx do
		count = count + #mapList[i].lacks;
	end
	return count;
end

-- 获取一个 mapItem 的 byte 大小
local function getMapListItemByte(mapItem)
	if #mapItem.cards > 0 then
		return mapItem.cards[1].byte;
	else
		return CardUtils.getCardByteFromAttr(Card.ValueMap:rget(mapItem.lacks[1]), 0);
	end
end

local function sortResult(self, result)
	table.sort(result, function(a, b)
		return self.byteToSize[a.byte] > self.byteToSize[b.byte];
	end)
	return result;
end

-- 尝试构建某个连接位（凑一个mapItem）
local function fulfillOneMapItem(self, params)
	local mapItem = params.mapItem;
	local cardStack = params.cardStack;
	local laiziList = CardUtils.getLaiZiList(self.ruleDao, cardStack:getCardList());
	
	local result = {};
	if #mapItem.cards > 0 then
		for _,card in ipairs(mapItem.cards) do
			cardStack:removeCard(card);
			table.insert(result, card);
		end
	end
	
	if #mapItem.lacks > 0 then
		-- 先把癞子当原始牌尝试接入
		local linkSuccCount = 0;
		local lackVal = Card.ValueMap:rget(mapItem.lacks[1]);
		for _,lackStr in ipairs(mapItem.lacks) do
			for idx,laizi in ipairs(laiziList) do
				if laizi.value == lackVal then
					linkSuccCount = linkSuccCount + 1;
					cardStack:removeCard(laiziList[idx]);
					table.insert(result, table.remove(laiziList, idx));
					break;
				end
			end
		end

		-- 癞子原始牌处理后还有缺，癞子变为替用牌接入
		if linkSuccCount ~= #mapItem.lacks then
			local virCard = CardUtils.getCardFromAttr(Card.ValueMap:rget(mapItem.lacks[1]), 0);
			for l=1, #mapItem.lacks-linkSuccCount do
				for idx,laizi in ipairs(laiziList) do
					if CardUtils.isTargetLaizi(self.ruleDao, laizi, virCard) then
						local tarLaiziCard = CardUtils.getLaiziCard(self.ruleDao, laizi, virCard);

						if self:isValidCard(tarLaiziCard) then
							table.insert(result, tarLaiziCard);
							cardStack:removeCard(laiziList[idx]);
							table.remove(laiziList, idx);
							linkSuccCount = linkSuccCount + 1;
							break;
						end
					end
				end
			end
		end

		-- 凑不出来，重置
		if linkSuccCount ~= #mapItem.lacks then
			for _,card in ipairs(result) do
				cardStack:addCard(CardUtils.getLaiziOriginalCard(self.ruleDao, card));
			end
			return false;
		else
			return true, result;
		end
	end

	if #result > 0 then
		return true, result;
	end
end




local function findLineWithLaizi(self, params)
	local srcCardStack = params.srcCardStack;
	local queue = params.queue;
	local map = params.map;
	local length = params.length and params.length or self.minNum;
	local tarCardByte = params.tarCardByte or CardUtils.getCardByteFromAttr(Card.ValueMap:rget(map[1].curValue), 0);
	
	local mapList = buildMapList(self, {
		oriCards = CardUtils.getOrigList(self.ruleDao, srcCardStack:getCardList()),
		queue = queue,
		map = map,
	})

	local cardStack = srcCardStack:clone();

	local lineLen = length/self.sameCount;
	local result, maxIdx = {}, 0;
	-- 拼接基本序列（最短长度）
	for i=1,#mapList-lineLen+1 do
		local laiziList = CardUtils.getLaiZiList(self.ruleDao, cardStack:getCardList());
		local maxCardIdx = queue == 1 and i+lineLen-1 or i;
		local findByte = getMapListItemByte(mapList[maxCardIdx]);

		-- 从比目标牌型大的位置开始连接
		if (not params.tarCardByte) or (self.byteToSize[findByte] - self.byteToSize[tarCardByte] == 1)  then
			local needLaiziCount = getSubSeqNeedLaiziCount(mapList, i, i+lineLen-1);
			if #laiziList - needLaiziCount >= 0 then
				for j=i, i+lineLen-1 do
					local ret, mapCards = fulfillOneMapItem(self, {mapItem = mapList[j], cardStack = cardStack});
					if ret then
						for _,card in ipairs(mapCards) do
							table.insert(result, card);
						end
					else
						result = {};
						break;
					end
				end

				if #result >= self.minLength then
					maxIdx = i+lineLen-1;
					break;
				end
			end
		end
	end
	-- 首出连张，得到最短长度后，继续拼接直到达到能连的最大长度
	if not params.tarCardByte and maxIdx > 0 and #result >= self.minLength then
		for i=maxIdx+1, #mapList do
			local ret, mapCards = fulfillOneMapItem(self, {mapItem = mapList[i], cardStack = cardStack});
			if ret then
				for _,card in ipairs(mapCards) do
					table.insert(result, card);
				end
			else
				break;
			end
		end
	end

	if #result >= self.minLength then
		return sortResult(self, result), cardStack;
	end
end




--找到value在序列中的位置
local function getLineMapIndex(lineMap,value,minLength)
	for i, v in ipairs(lineMap) do
		if v.curValue == value and i >= minLength then 
			return i
		end
	end
end

local function compareValueIndex(lineMap, targetCardByte, length, minLength)
	local targetCard = Card.new(targetCardByte)
	local findIndex = nil
	for i,cardMap in ipairs(lineMap) do
		local cardValue = Card.ValueMap:getKeyByValue(cardMap.curValue)
		if cardValue == targetCard.value and i >= minLength then
			if lineMap[i+1] then
				findIndex  =  i+1;
				break
			end
		end
	end
	if findIndex then
		if findIndex <= length then
			return 1
		else
			return findIndex
		end
	end
	return
end

---找到序列大于targetCardByte的起始下标
local function getBeginIndex(self, lineMap,targetCardByte,length, minLength)
	local length = length and length or self.minLength * self.sameCount
	if not targetCardByte then 
		return 1
	else
		local card = Card.new(targetCardByte)
		local targetIndex = getLineMapIndex(lineMap,Card.ValueMap:get(card.value),self.minLength)
		if targetIndex and targetIndex < #lineMap then
			return (targetIndex + 1) - length/self.sameCount + 1;
		else
			return compareValueIndex(lineMap, targetCardByte, length, minLength)
		end
	end
end

--统一处理返回结果
local function dealResult(self, resultList)
	if not resultList then 
		return
	end
	
	return {
		cardList = resultList,
		cardByte = resultList[1].byte,
		cardType = self.uniqueId,
	}
end

--可能存在多个可用的顺子序列，一次查找一个序列
-- map 序列表
-- targetCardByte  要压的牌值，为空则不需要压
-- length 牌的总长度
-- queue 1从小开始找，默认从大开始 
local function findFromOneMap(self, map, targetCardByte, length, queue, minLength, cardStack)
	local index = getBeginIndex(self, map, targetCardByte, length, minLength)
	if not index then 
		return
	end

	index = index<=0 and 1 or index;
	local low = queue == 1 and index or #map;
	local up = queue == 1 and #map or index;
	local step = queue == 1 and 1 or -1;

	local insertPosChange = queue == 1 and 0 or 1;
	local insertPos = 1;

	local resultList = {}
	for i=low, up, step do 
		local curValue = map[i].curValue
		local curCount = cardStack:getNumberByValue(Card.ValueMap:rget(curValue))
		if curCount >= self.sameCount then 
			local cards = cardStack:getCardsByValue(Card.ValueMap:rget(curValue))
			for j=1, self.sameCount do --找到的牌数量满足要求
				table.insert(resultList, insertPos, cards[j])
				cardStack:removeCard(cards[j]);
				insertPos = insertPos + insertPosChange
			end
			if length and #resultList == length and length >= self.minLength*self.sameCount then --判断是否已达到要求的固定长度
				return dealResult(self, resultList);
			end
		else --如果查找序列发生中断，先判断是否已经满足查找条件，满足则返回结果
			if not length and #resultList >= self.minLength*self.sameCount then
				return dealResult(self, resultList);
			end
			cardStack:addCards(resultList)
			resultList = {}
			insertPos = 1
		end
	end
	--已查找到序列终点，判断是否满足条件
	if length and #resultList == length then 
		return dealResult(self, resultList);
	elseif not length and #resultList >= self.minLength * self.sameCount then
		return dealResult(self, resultList);
	end
	if #resultList > 0 then
		cardStack:addCards(resultList)
		resultList = {}
		insertPos = 1
	end
end

function M:find(data)
	local cardStack = data.srcCardStack:clone();
	-- local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or self.minNum
	local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList
	if data.length and data.length > self.minNum then 
		length = data.length
	end
	local cardByte = data.targetCardInfo and data.targetCardInfo.cardByte or nil
	local lineMapStart = 1
	local lineMapEnd = #self.lineMap
	local step = 1
	if data.queue == 0 then
		lineMapStart, lineMapEnd = lineMapEnd, lineMapStart
		step = -1
	end

	for i=lineMapStart, lineMapEnd, step do
		local map = self.lineMap[i];
		local result = nil;
		if self.enableLaiZi == 1 then
			local lineTmp, leftCardStack = findLineWithLaizi(self, {
				srcCardStack = data.srcCardStack,
				queue = data.queue,
				map = map,
				length = length,
				tarCardByte = cardByte,
			});
			if lineTmp and #lineTmp >= self.minNum then
				result = dealResult(self, lineTmp);
				cardStack = leftCardStack or cardStack;
			end
		else
			result = findFromOneMap(self, map, cardByte, length, data.queue, self.minLength, cardStack);
		end

		if result then 
			return result, cardStack:getCardList();
		end
	end
end


return M;