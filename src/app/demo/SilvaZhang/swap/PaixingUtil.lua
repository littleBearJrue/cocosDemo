local PaixingUtil = {}

local paixingConfig1 = {
	{name = "三条",func = "paixingSANT",sort = 3},
	{name = "对子",func = "paixingDZ",sort = 2},
	{name = "高牌",func = "paixingGP",sort = 1},
}

local paixingConfig2 = {
	{name = "皇家同花顺",func = "paixingHJTHS",sort = 10},
	{name = "同花顺",func = "paixingTHS",sort = 9},
	{name = "四条",func = "paixingSIT",sort = 8},
	{name = "葫芦",func = "paixingHL",sort = 7},
	{name = "同花",func = "paixingTH",sort = 6},
	{name = "顺子",func = "paixingSZ",sort = 5},
	{name = "三条",func = "paixingSANT",sort = 4},
	{name = "两对",func = "paixingLD",sort = 3},
	{name = "对子",func = "paixingDZ",sort = 2},
	{name = "高牌",func = "paixingGP",sort = 1},
}

function PaixingUtil:checkPaixing( cardList )
	for i,cardByte in ipairs(cardList) do
		local cardType = math.floor(cardByte/16)
		local cardValue = cardByte%16
		if cardValue == 1 then
			cardList[i] = cardByte + 13
		end
	end
	local judgeData
	if #cardList == 3 then
		for i, paixingConfig in ipairs(paixingConfig1) do
			if self[paixingConfig.func] then
				judgeData = self[paixingConfig.func](self,cardList)
				if judgeData.result then
					judgeData.name = paixingConfig.name
					judgeData.sort = paixingConfig.sort
					break
				end
			end
		end
	elseif #cardList == 5 then
		for i, paixingConfig in ipairs(paixingConfig2) do
			if self[paixingConfig.func] then
				judgeData = self[paixingConfig.func](self,cardList)
				if judgeData.result then
					judgeData.name = paixingConfig.name
					judgeData.sort = paixingConfig.sort
					break
				end
			end
		end
	end
	for i,cardByte in ipairs(cardList) do
		local cardType = math.floor(cardByte/16)
		local cardValue = cardByte%16
		if cardValue == 14 then
			cardList[i] = cardByte - 13
		end
	end
	if judgeData.result then
		for i,cardByte in ipairs(judgeData.card) do
			local cardType = math.floor(cardByte/16)
			local cardValue = cardByte%16
			if cardValue == 14 then
				judgeData.card[i] = cardByte - 13
			end
		end
	end
	return judgeData
end

function PaixingUtil:checkPaixingSort( judgePaixingData )
	local judge = function ( data1,data2 )
		if data1.sort > data2.sort then
			return true
		elseif data1.sort == data2.sort then
			local groupData1 = self:paixingGP(data1.card)
			local groupData2 = self:paixingGP(data2.card)
			if groupData1.card[1] > groupData2.card[1] then
				return true
			else
				return false
			end
		else
			return false
		end
	end
	for i = 1,3 do
		if i == 1 then
			judgePaixingData[1].result = judge(judgePaixingData[2],judgePaixingData[1])
		elseif i == 2 then
			judgePaixingData[2].result = judge(judgePaixingData[2],judgePaixingData[1]) and judge(judgePaixingData[3],judgePaixingData[2])
		elseif i == 3 then
			judgePaixingData[3].result = judge(judgePaixingData[3],judgePaixingData[2])
		end
	end
end

local function getGroupCardNum( cardList )
	local groupData = {}
	for i,cardByte in ipairs(cardList) do
		local cardType = math.floor(cardByte/16)
		local cardValue = cardByte%16
		if not groupData[cardValue] then
			groupData[cardValue] = {}
			table.insert(groupData[cardValue],cardByte)
		else
			table.insert(groupData[cardValue],cardByte)
		end
	end
	return groupData
end

function PaixingUtil:paixingHJTHS( cardList )
	local judgeData = {result = false,card = {}}
	local thsJudgeData = self:paixingTHS(cardList)
	local maxByte = 0
	if thsJudgeData.result then
		for i,cardByte in ipairs(thsJudgeData.card) do
			if cardByte > maxByte then
				maxByte = cardByte
			end
		end
	end
	if maxByte then
		local cardType = math.floor(maxByte/16)
		local cardValue = maxByte%16
		if cardValue == 14 then
			judgeData.result = true
			judgeData.card = thsJudgeData.card
		end
	end
	return judgeData
end

function PaixingUtil:paixingTHS( cardList )
	local judgeData = {result = false,card = {}}
	local thJudgeData = self:paixingTH(cardList) 
	local szJudgeData = self:paixingSZ(cardList)
	if thJudgeData.result and szJudgeData.result then
		judgeData.result = true
		judgeData.card = szJudgeData.card
	end
	return judgeData
end

function PaixingUtil:paixingSIT( cardList )
	local judgeData = {result = false,card = {}}
	local groupData = getGroupCardNum(cardList)
	for cardValue,groupItem in pairs(groupData) do
		if #groupItem == 4 then
			judgeData.result = true
			judgeData.card = groupItem
		end
	end
	return judgeData
end

function PaixingUtil:paixingHL( cardList )
	local judgeData = {result = false,card = {}}
	local duiZiCount = 0
	local sanTiaoCount = 0
	local allCard = {}
	local groupData = getGroupCardNum(cardList)
	for cardValue,groupItem in pairs(groupData) do
		if #groupItem == 2 then
			duiZiCount = duiZiCount + 1
			for i,v in ipairs(groupItem) do
				table.insert(allCard,v)
			end
		end
		if #groupItem == 3 then
			sanTiaoCount = sanTiaoCount + 1
			for i,v in ipairs(groupItem) do
				table.insert(allCard,v)
			end
		end
	end
	if duiZiCount == 1 and sanTiaoCount == 1 then
		judgeData.result = true
		judgeData.card = allCard
	end
	return judgeData
end

function PaixingUtil:paixingTH( cardList )
	local judgeData = {result = false,card = {}}
	local tongData = {}
	for i,cardByte in ipairs(cardList) do
		local cardType = math.floor(cardByte/16)
		local cardValue = cardByte%16
		if not tongData[cardType] then
			tongData[cardType] = {}
			table.insert(tongData[cardType],cardByte)
		else
			table.insert(tongData[cardType],cardByte)
		end
	end
	for i,tongDataItem in pairs(tongData) do
		if #tongDataItem == 5 then
			judgeData.result = true
			judgeData.card = tongDataItem
			break
		end
	end
	return judgeData
end

function PaixingUtil:paixingSZ( cardList )
	local judgeData = {result = false,card = {}}
	local groupData = getGroupCardNum(cardList)
	local minValue = 16
	local allCard = {}
	for cardValue,groupItem in pairs(groupData) do
		if #groupItem ~= 1 then
			return judgeData
		else
			if minValue > cardValue then
				minValue = cardValue
			end
		end
	end
	for i = 0,4 do
		if groupData[minValue+i] then
			table.insert(allCard,groupData[minValue+i][1])
		else
			return judgeData
		end
	end
	if #allCard == 5 then
		judgeData.result = true
		judgeData.card = allCard
	end
	return judgeData
end

function PaixingUtil:paixingSANT( cardList )
	local judgeData = {result = false,card = {}}
	local groupData = getGroupCardNum(cardList)
	for cardValue,groupItem in pairs(groupData) do
		if #groupItem == 3 then
			judgeData.result = true
			judgeData.card = groupItem
		end
	end
	return judgeData
end

function PaixingUtil:paixingLD( cardList )
	local judgeData = {result = false,card = {}}
	local duiZiCount = 0
	local allCard = {}
	local groupData = getGroupCardNum(cardList)
	for cardValue,groupItem in pairs(groupData) do
		if #groupItem == 2 then
			duiZiCount = duiZiCount + 1
			for i,v in ipairs(groupItem) do
				table.insert(allCard,v)
			end
		end
	end
	if duiZiCount == 2 then
		judgeData.result = true
		judgeData.card = allCard
	end
	return judgeData
end

function PaixingUtil:paixingDZ( cardList )
	local judgeData = {result = false,card = {}}
	local maxValue = 0
	local groupData = getGroupCardNum(cardList)
	for cardValue,groupItem in pairs(groupData) do
		if #groupItem == 2 and cardValue > maxValue then
			judgeData.result = true
			judgeData.card = groupItem
		end
	end
	return judgeData
end

function PaixingUtil:paixingGP( cardList )
	local judgeData = {result = true,card = {}}
	local maxCard = 0
	local maxType = 0
	local maxValue = 0
	for i,cardByte in ipairs(cardList) do
		local cardType = math.floor(cardByte/16)
		local cardValue = cardByte%16
		if cardValue > maxValue then
			maxValue = cardValue
			maxCard = cardByte
		elseif cardValue == maxValue then
			if cardType > maxType then
				maxType = cardType
				maxCard = cardByte
			end
		end
	end
	judgeData.card[1] = maxCard
	return judgeData
end

return PaixingUtil