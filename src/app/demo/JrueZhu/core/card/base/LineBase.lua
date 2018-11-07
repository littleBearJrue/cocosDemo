--[[--ldoc desc
@module LineBase
@author KevinZhang

Date   2018-05-16 18:03:15
Last Modified by   EricHuang
Last Modified time 2018-08-08 11:47:11
]]-- @Author: EricHuang
-- @Date:   2017-11-27 12:17:26
-- @Last Modified by   LucasZhen
-- @Last Modified time 2018-05-04 17:22:11

--[[
sameCount=同牌的张数，
minLength=相邻牌的最短数量,
lineArgs=可连接的牌序列，多个序列用/分割，A-2-3-4-5-6-7-8/10-J-Q-K-A
]]

local CardBase = import('.CardBase')
local LineBase = class(CardBase)

function LineBase:ctor(data, ruleDao)
end

------------初始化函数，初始化顺子序列,子类需自己调用完成初始化
function LineBase:init(data)
	local lineArgs = data.lineArgs  -----可配参数
	if lineArgs and lineArgs ~= "" then
		self.lineMap = g_ParseUtils.parseLineMap(lineArgs)
	else
	end
	self.sameCount = data.sameCount -----可配参数
	self.minLength = data.minLength or 0 -----可配参数
	self.minNum = self.sameCount * self.minLength
	self.offset = self.sameCount
end

local function checkOneMap(params) ----检查一个序列里是否有满足的
	local self 		 = params.obj;
	local outCardInfo = params.outCardInfo;
	local cardList 	 = params.cardList;
	local map		 = params.map;

	local cardStack = new(CardStack, {cards = cardList})

	local totalCount = 0 ---记录已使用的牌数
	local curCount = 0   --当前牌在牌列表中有多少张
	local lastCard = nil  --记录下找到序列的最后一张牌
	for _, v in ipairs(map) do 
		curCount = cardStack:getNumberByValue(Card.ValueMap:rget(v.curValue))
		if curCount == self.sameCount then 
			totalCount = totalCount + curCount
			lastCard =  cardStack:getCardsByValue(Card.ValueMap:rget(v.curValue))[1]
		elseif curCount > 0 then
			return false
		elseif curCount == 0 then 
			if totalCount > 0 then 
				break
			end
		end
	end
	if totalCount == #cardList then 
		outCardInfo.cardByte = lastCard.byte;
		outCardInfo.groupLenght = totalCount / self.sameCount
		return true;
	else	
		return false
	end
end

-- 创建一张虚牌（癞子牌模板）
local function getVirtualCard(val, laizi)
	local color, value = 0, Card.ValueMap:rget(val);
	local targetCard = CardUtils.getCardFromAttr(value, color);
	return targetCard;
end

local function divideLaiziFromList(ruleDao, cardList, otherList)
	local i = 1;
	while i <= #cardList do
		if CardUtils.isLaizi(ruleDao, cardList[i]) then
			table.insert(otherList, table.remove(cardList, i));
		else
			i = i + 1;
		end
	end
end

local function checkOneMapWithLaizi(params) -- 带癞子检查
	local self 		 = params.obj;
	local outCardInfo = params.outCardInfo;
	local cardList 	 = params.cardList;
	local otherList  = params.otherList;
	local map		 = params.map;
	-- 把 cardList 里的癞子先转移到 otherList 中
	divideLaiziFromList(self.ruleDao, cardList, otherList);

	local dict = {}
	for i,v in ipairs(cardList) do
		local k = Card.ValueMap:get(v.value);
		dict[k] = dict[k] or {};
		table.insert(dict[k], v);

		if #dict[k] > self.sameCount then
			return false;
		end
	end

	local lackCount = 0;	-- 组成连张所缺的牌数
	local lackVal = {};		-- 组成连张所缺的牌
	local totalCount = 0;
	local lessValIdx, largeValIdx = 0, 0;	-- 当前可组成连张的最小值，最大值
	local lastCard = nil;
	for i,v in ipairs(map) do
		if dict[v.curValue] then
			if lessValIdx == 0 then lessValIdx = i end;

			local lack = self.sameCount - #dict[v.curValue];
			lackCount = lackCount + lack;
			if lack > 0 then
				table.insert(lackVal, {count = lack, val = v.curValue});
			end
			totalCount = totalCount + #dict[v.curValue];
		elseif totalCount > 0 and totalCount ~= #cardList then
			lackCount = lackCount + self.sameCount;
			table.insert(lackVal, {count = self.sameCount, val = v.curValue});
		end

		if totalCount == #cardList then
			Log.v("linebase -----------",dict,v.curValue)
			lastCard = dict[v.curValue][1];
			if largeValIdx == 0 then largeValIdx = i end;
			break;
		end
	end
	
	-- 检查癞子是否可以替用 或者 当作原生牌插入中间
	local i = 1;
	while i <= #lackVal do
		if #otherList > 0 then
			local bOri = false;
			-- 是否能当癞子替用
			if not CardUtils.isTargetLaizi(self.ruleDao, otherList[#otherList], getVirtualCard(lackVal[i].val)) then
				for j,laizi in ipairs(otherList) do
					-- 是否能当原生牌插入中间
					if Card.ValueMap:get(laizi.value) == lackVal[i].val then
						bOri = true;
						lackCount = lackCount-lackVal[i].count;
						table.remove(lackVal, i);
						table.remove(otherList, j);
						break;
					end
				end
				-- 有牌不能当癞子，又不能当原牌接入
				if not bOri then return false; end
			end
			if not bOri then i = i + 1; end
		else
			break;
		end
	end

	-- 在连张中间凑够癞子
	if lackCount == #otherList then	-- 刚好可以在中间凑
		outCardInfo.cardByte = lastCard.byte;
		outCardInfo.groupLenght = largeValIdx - lessValIdx + 1;
		return true;
	elseif lackCount > #otherList then	-- 癞子数不够凑
		return false;
	end

	-- 把已经插到中间的癞子移除
	for i=1,lackCount do
		table.remove(otherList, #otherList);
	end

	-- 癞子数凑完连张中间还有剩，在头尾凑癞子
	local appendCount = 0;
	for i=largeValIdx + 1, #map do	-- 验证能否在序列后面当癞子
		local virCard = getVirtualCard(map[i].curValue);
		if #otherList > 0 and #otherList % self.sameCount == 0 and CardUtils.isTargetLaizi(self.ruleDao, otherList[#otherList], virCard) then
			lastCard = CardUtils.getLaiziCard(self.ruleDao, otherList[#otherList], virCard);
			appendCount = appendCount + 1;
			for i=1,self.sameCount do
				table.remove(otherList, #otherList);
			end
			if #otherList == 0 then break; end
		else
			return false;
		end
	end

	while #otherList > 0 do	-- 验证能否在序列前面当癞子
		lessValIdx = lessValIdx - 1;
		if lessValIdx > 0 then
			local virCard = getVirtualCard(map[lessValIdx].curValue);
			if #otherList > 0 and #otherList % self.sameCount == 0 and CardUtils.isTargetLaizi(self.ruleDao, otherList[#otherList], virCard) then
				appendCount = appendCount + 1;
				for i=1,self.sameCount do
					table.remove(otherList, #otherList);
				end
				if #otherList == 0 then break; end
			else			
				return false;
			end
		end
	end
	
	if #otherList == 0 then
		outCardInfo.cardByte = lastCard.byte;
		outCardInfo.groupLenght = largeValIdx - lessValIdx + 1 + appendCount;
		return true;
	end

	return false;
end

function LineBase:check(data)
	if #data.outCardInfo.cardList < self.minNum then
		return false
	end
	local cardList, otherList = self:getValidCard(data.outCardInfo.cardList)

	if self.enableLaiZi == 0 and #cardList ~= #data.outCardInfo.cardList then
		return false
	end

	local flag = 0
	for _,card in ipairs(data.outCardInfo.cardList) do 
		if Card.isLaizi(card) then 
			flag = flag + 1 
		end 
	end
	if flag == #data.outCardInfo.cardList then --全是癞子牌
		return false
	end

	-- other 里有不是癞子的牌
	for _,card in ipairs(otherList) do
		if not CardUtils.isLaizi(self.ruleDao, card) then
			return false;
		end
	end

	if #cardList + #otherList < self.sameCount * self.minLength then 
		return false 
	end

	for _, map in ipairs(self.lineMap) do  ---可循环匹配多个顺子序列
		local params = {
			obj = self,
			outCardInfo = data.outCardInfo,
			cardList = cardList,
			otherList = otherList,
			map = map,
		}
		local checkFunc = self.enableLaiZi == 1 and checkOneMapWithLaizi or checkOneMap;
		Log.v("check params",outCardInfo,cardList,otherList,map)
		local result = checkFunc(params);
		if result then
			Log.i("outCardInfo", data.outCardInfo)
			return result
		end
	end
	return false
end

function LineBase:compare(data)
	local outCardList = data.outCardInfo.cardList
	local targetCardList = data.targetCardInfo.cardList
	if #outCardList ~= #targetCardList then 
		return false
	end
	local outCardByte = data.outCardInfo.cardByte
	local tagetCardByte = data.targetCardInfo.cardByte
	Log.i("比较",outCardByte,targetCardByte)
	return self.byteToSize[outCardByte] > self.byteToSize[tagetCardByte]
end

-------------------------------- 癞子find ---------------------------------------

-- 构建连张初始序列
--[[
	例如：
	{		  -- 手牌		  组成连张缺的牌
		[1] = {cards = {3,3}, lack = {}},
		[2] = {cards = {4}	, lack = {4}},
		[3] = {cards = {5,5}, lack = {}},
		[4] = {cards = {}	, lack = {6,6}},
	}
]]
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
		if self.byteToSize[tarCardByte] < self.byteToSize[findByte] then
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

-------------------------------- 常规find ---------------------------------------

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

function LineBase:find(data)
	local cardStack = data.srcCardStack:clone();
	-- local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList or self.minNum
	local length  = data.targetCardInfo and data.targetCardInfo.cardList and #data.targetCardInfo.cardList
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

return LineBase