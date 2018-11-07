--[[--ldoc desc
@Module PaiXingUtils.lua
@Author JasonLiu

Date: 2018-10-31 15:55:42
Last Modified by: JasonLiu
Last Modified time: 2018-10-31 16:15:21
]]

local Bit = require("app.demo.JasonLiu.utils.Bit");
local PaiXingUtils = {}

local PaiXingConfig = {
    [1] = { func = "paixing_0010", paixing = "皇家同花顺", weight = 10 },
    [2] = { func = "paixing_009", paixing = "同花顺", weight = 9 },
    [3] = { func = "paixing_008", paixing = "铁支", weight = 8 },
    [4] = { func = "paixing_007", paixing = "葫芦", weight = 7 },
    [5] = { func = "paixing_006", paixing = "同花", weight = 6 },
    [6] = { func = "paixing_005", paixing = "顺子", weight = 5 },
    [7] = { func = "paixing_004", paixing = "三条", weight = 4 },
    [8] = { func = "paixing_003", paixing = "两对", weight = 3 },
    [9] = { func = "paixing_002", paixing = "一对", weight = 2 },
    [10] = { func = "paixing_001", paixing = "高牌", weight = 1 },
}

PaiXingUtils.sort = function (cards)
    table.sort(cards, function (c1, c2)
        return c1 < c2
    end)
    return cards
end

PaiXingUtils.getMatrix = function (cards)
    local matrix = {}
    for i, cardByte in ipairs(cards) do
        local cardType = Bit:brShift(cardByte, 4);
        local value = Bit:band(cardByte, 0x0f);
        if not matrix[cardType] then
            matrix[cardType] = {}
        end
        matrix[cardType][value] = (matrix[cardType][value] or 0) + 1
    end
    return matrix
end

PaiXingUtils.check = function (cards)
    local cards = PaiXingUtils.sort(cards)
    local matrix = PaiXingUtils.getMatrix(cards)

    for i, config in ipairs(PaiXingConfig) do
        local flag, cards = PaiXingUtils[config.func](cards, matrix)
        if flag then
            return config.paixing, cards, config.weight
        end
    end
end

--皇家同花顺
PaiXingUtils.paixing_0010 = function (cards, matrix)
    return PaiXingUtils.paixing_009(cards, matrix) and Bit:band(cards[1], 0x0f) == 1, cards
end

--同花顺
PaiXingUtils.paixing_009 = function (cards, matrix)
    return PaiXingUtils.paixing_005(cards, matrix) and PaiXingUtils.paixing_006(cards, matrix), cards
end

--铁支
PaiXingUtils.paixing_008 = function (cards, matrix)
    if #cards < 5 then return false end
    for _, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v > 0 then
                local n = 0 
                for i, item in pairs(matrix) do
                    n = n + (item[k] or 0)
                end
                if n == 4 then
                    return true, cards
                end
            end
        end
    end

    return false
end

--葫芦
PaiXingUtils.paixing_007 = function (cards, matrix)
    if #cards < 5 then return false end
    local s, d = false, false
    for _, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v > 0 then
                local n = 0 
                for i, item in pairs(matrix) do
                    n = n + (item[k] or 0)
                end
                if n == 3 then
                    s = true
                elseif n == 2 then
                    d = true
                end
            end
        end
    end

    return s and d, cards
end

--同花
PaiXingUtils.paixing_006 = function (cards, matrix)
    if #cards < 5 then return false end
    return table.nums(matrix) == 1, cards
end

--顺子
PaiXingUtils.paixing_005 = function (cards, matrix)
    if #cards < 5 then return false end
    for _, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v == 1 then
                local n = 1 
                for i = k + 1, 4 + k do
                    for _, item in pairs(matrix) do
                        if item[i] == 1 then
                            n = n + 1
                            break
                        end
                    end
                end
                if n == 5 then
                    return true, cards
                elseif n == 4 and k == 10 then
                    for _, item in pairs(matrix) do
                        if item[1] == 1 then
                            return true, cards
                        end
                    end
                end
            else 
                return false
            end
        end
    end

    return false
end

--三条
PaiXingUtils.paixing_004 = function (cards, matrix)
    if #cards < 3 then return false end
    local pxCards = {}
    for _, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v > 0 then
                local n = 0 
                for i, item in pairs(matrix) do
                    if item[k] then
                        n = n + item[k]
                        for n = 1, item[k] do
                            table.insert(pxCards, i * 16 + k)
                        end
                    end
                end
                if n == 3 then
                    return true, pxCards
                end
                pxCards = {}
            end
        end
    end

    return false
end

--两对
PaiXingUtils.paixing_003 = function (cards, matrix)
    if #cards < 4 then return false end
    local d = 0
    local pxCards = {}
    for i, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v > 0 then
                local n = v 
                local tempCards = {}
                for n = 1, n do
                    table.insert(tempCards, i * 16 + k)
                end
                for j, item in pairs(matrix) do
                    if j > i and item[k] then
                        n = n + item[k]
                        for n = 1, item[k] do
                            table.insert(tempCards, j * 16 + k)
                        end
                    end
                end
                if n == 2 then
                    d = d + 1
                    for i, v in ipairs(tempCards) do
                        table.insert(pxCards, v)
                    end
                end
            end
        end
    end
    return d == 2, pxCards
end

--一对
PaiXingUtils.paixing_002 = function (cards, matrix)
    if #cards < 2 then return false end
    local d = 0
    local pxCards = {}
    for i, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v > 0 then
                local n = v 
                local tempCards = {}
                for n = 1, n do
                    table.insert(tempCards, i * 16 + k)
                end
                for j, item in pairs(matrix) do
                    if j > i and item[k] then
                        n = n + item[k]
                        for n = 1, item[k] do
                            table.insert(tempCards, j * 16 + k)
                        end
                    end
                end
                if n == 2 then
                    d = d + 1
                    for i, v in ipairs(tempCards) do
                        table.insert(pxCards, v)
                    end
                end
            end
        end
    end

    return d == 1, pxCards
end

--高牌
PaiXingUtils.paixing_001 = function (cards, matrix)
    for i, item in pairs(matrix) do
        for k, v in pairs(item) do
            if v == 1  then
                for j, item in pairs(matrix) do
                    if j > i and item[k] then
                        return false
                    end
                end
            else
                return false  
            end
        end
    end

    local max = 0
    for i, v in ipairs(cards) do
        if Bit:brShift(v, 4) >= Bit:brShift(max, 4) and Bit:band(v, 0x0f) > Bit:band(max, 0x0f) then
            max = v
        end
    end

    return not PaiXingUtils.paixing_005(cards, matrix), {max}
end

return PaiXingUtils