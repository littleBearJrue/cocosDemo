local PaiXingUtil = class("PaiXingUtil")

local paixingConfig = {
	{name = "皇家同花顺",func = "paixingHJTHS",sortId = 10},
	{name = "同花顺",func = "paixingTHS",sortId = 9},
	{name = "四条",func = "paixingSIT",sortId = 8},
	{name = "葫芦",func = "paixingHL",sortId = 7},
	{name = "同花",func = "paixingTH",sortId = 6},
	{name = "顺子",func = "paixingSZ",sortId = 5},
	{name = "两对",func = "paixingLD",sortId = 4},
	{name = "三条",func = "paixingSANT",sortId = 3},
	{name = "对子",func = "paixingDZ",sortId = 2},
	{name = "高牌",func = "paixingGP", sortId = 1},
}

local function sort(cardByteGroup)
    table.sort(cardByteGroup, function (c1, c2)
        return c1 < c2
    end)
    return cardByteGroup
end

local function valueAndType(cardByteGroup)
    local newValueGroup = {}
    for i, cardByte in ipairs(cardByteGroup) do
        local cardType = math.floor( cardByte / 16) + 1
        local cardValue = cardByte % 16 
        if not newValueGroup[cardValue] then
			newValueGroup[cardValue] = {}
			table.insert(newValueGroup[cardValue],cardByte)
		else
			table.insert(newValueGroup[cardValue],cardByte)
		end
    end
    return newValueGroup
end

local function dui(sortNum,duiNum,isHuLu,cardByteGroup)
    local data = {}
    local duiCount = 0;
    local newValueGroup = valueAndType(cardByteGroup)

    if isHuLu == false then
        for _, cardByteNewGroup in pairs(newValueGroup) do
            if #cardByteNewGroup == sortNum then
                duiCount = duiCount + 1
                for i, cardByte in ipairs(cardByteNewGroup) do
                    table.insert(data,cardByte)
                end 
            end 
        end
        if #data > 1 then 
            sort(data)
        end
        if duiCount == duiNum then 
            return data
        end
    else   
        for _, cardByteNewGroup in pairs(newValueGroup) do
            duiCount = duiCount + 1
        end
        if duiCount == duiNum then       
            return cardByteGroup
        end   
    end
end

function PaiXingUtil:GetCheckResult(group1,group2)	
	if group1.sortId == group2.sortId then 
		if group1.card[#group1.card] % 16 < group2.card[#group2.card] % 16 then
			return true
		end
	elseif group1.sortId < group2.sortId then
	    return true
	end
	return false
end

function PaiXingUtil:find(cardByteGroup)
    local start = nil
    if #cardByteGroup == 3 then
        start = 8  
    else
        start = 1
    end
    for i = start, #paixingConfig do
        local data = {}
        if self[paixingConfig[i].func] then
            data.card = self[paixingConfig[i].func](self,cardByteGroup)
            if data.card and #data.card > 0 then
                data.sortId = paixingConfig[i].sortId
                data.name = paixingConfig[i].name
                return data
            end
        end
    end
end

function PaiXingUtil:paixingGP(cardByteGroup)
    local data = {}
    local maxCardByte = 0
    for _, cardByte in ipairs(cardByteGroup) do
        if maxCardByte < cardByte then 
            maxCardByte = cardByte
        end
    end
    table.insert(data,maxCardByte)
    return data
end

function PaiXingUtil:paixingDZ(cardByteGroup)
    return dui(2,1,false,cardByteGroup)
end

function PaiXingUtil:paixingSANT(cardByteGroup)
    return dui(3,1,false,cardByteGroup)
end

function PaiXingUtil:paixingSIT(cardByteGroup)
    return dui(4,1,false,cardByteGroup)
end

function PaiXingUtil:paixingLD(cardByteGroup)
    return dui(2,2,false,cardByteGroup)
end

function PaiXingUtil:paixingSZ(cardByteGroup)
    local sunZiFalg = true
    local newCardByte ={}
    for i, cardByte in ipairs(cardByteGroup) do
        table.insert(newCardByte,cardByte % 16 )
    end
    sort(newCardByte)

    for i = 1, #newCardByte - 1 do
        if newCardByte[i] == newCardByte[i + 1] - 1 then 
        else
            sunZiFalg = false
        end 
    end
    if sunZiFalg == true then
        return cardByteGroup
    end
end

function PaiXingUtil:paixingTH(cardByteGroup)
    local tongHuaFalg = true
    local newCardType ={}
    for i, cardByte in ipairs(cardByteGroup) do
        table.insert(newCardType,math.floor( cardByte / 16))
    end
    for i = 1, #newCardType - 1 do
        if newCardType[i] == newCardType[i + 1] then 
        else
            tongHuaFalg = false
        end 
    end
    if tongHuaFalg == true then
        return cardByteGroup
    end
end

function PaiXingUtil:paixingTHS(cardByteGroup)
    if self:paixingTH(cardByteGroup) and self:paixingSZ(cardByteGroup) then
        return cardByteGroup
    end
end

function PaiXingUtil:paixingHL(cardByteGroup)
    return dui(3,2,true,cardByteGroup)
end

return PaiXingUtil
