local Paixing = class("Paixing",cc.load("boyaa").mvc.BoyaaView)

local maxCard --每种牌型对应的值如34567的同花顺，值为903
local data1 = {}--传输过来的牌的Type值
local isTongHua, isShunZi = nil
function  Paixing:check(byteData)
    maxCard = 0
    local data = {}--通过Byte获得的牌的value值
    data1 = {}
    isTongHua, isShunZi = nil
    for k, v in pairs(byteData) do
         table.insert(data, v)
         table.insert(data1, v)
    end
    --通过Byte值获得牌的value值
    for i = 1, #data do
        if data[i] >16 and data[i] <32 then
            data[i] = data[i] -16
        elseif data[i] >32 and data[i] <48 then
            data[i] = data[i] -32
        elseif data[i] >48 and data[i] <64 then
            data[i] = data[i] -48
        elseif data[i] >64  then
            data[i] = data[i] -64      
        end
    end
    maxCard = self:royalTongHuaShun(data)
    return maxCard
end


-------------------单牌-------------------
function  Paixing:singleCard(data)
    local maxCard = data[1]
	for i = 1, #data do
        if data[i] > maxCard then
            maxCard = data[i]
        end
    end
    return maxCard
end

-------------------一对-------------------
function  Paixing:yiDui(data)
    local cardSum = 0
    local cardType
    for i = 1, #data do
        cardSum = 0
        cardType = data[i]
        for j = i, #data do
            if data[j] == cardType then
                cardSum = cardSum + 1
            end
        end
        if cardSum == 2 then
            maxCard = 200 + cardType
            return maxCard
        end
    end
    if maxCard < 200 then
        maxCard = self:singleCard(data)
    end
    return maxCard
end

-------------------两对-------------------
function  Paixing:liangDui(data)
    local cardSum = 0
    local cardType
    -- dump(data)
    for i = 1, #data do
        cardSum = 0
        cardType = data[i]
        for j = i, #data do
            if data[j] == cardType then
                cardSum = cardSum + 1
            end
        end
        -- dump(cardSum)
        local cardTwo = cardType
        if cardSum == 2 then
            for i_ = 1, #data do
                cardSum = 0
                cardType = data[i_]
                for j_ = i_, #data do
                    if data[j_] == cardType then
                        cardSum = cardSum + 1
                    end
                end
                -- dump(cardSum)
                -- dump(cardType)
                if cardSum == 2 and cardType ~= cardTwo then
                    maxCard = 300 + cardType
                    return maxCard
                end
            end
        end
    end
    if maxCard < 300 then
        maxCard = self:yiDui(data)
    end
    return maxCard
end

-------------------三条-------------------
function  Paixing:sanTiao(data)
    local cardSum = 0
    local cardType
    for i = 1, #data do
        cardSum = 0
        cardType = data[i]
        for j = i, #data do
            if data[j] == cardType then
                cardSum = cardSum + 1
            end
        end
        if cardSum == 3 then
            maxCard = 400 + cardType
            return maxCard
        end
    end
    if maxCard < 400 then
        maxCard = self:liangDui(data)
    end
    return maxCard
end

-------------------顺子-------------------
function  Paixing:shunZi(data)
    local minNum = data[1]
	for i = 1, #data do
        if data[i] < minNum then
            minNum = data[i]
        end
    end
    if isShunZi then
        maxCard = minNum + 500
    end
    if maxCard < 500 then
        maxCard = self:sanTiao(data)
    end
    return maxCard     
end
-- function  Paixing:shunZi(data)
--     dump(data)
--     local max_ = data[1]
-- 	for i = 1, #data do
--         if data[i] > max_ then
--             max_ = data[i]
--         end
--     end
--    local min_ = max_- 4
--     dump(max_)
--     dump(min_)
--     local function findShunZi(max)
--         local maxCard_
--         if max - 1 and max > min_ then
--             max = max - 1
--             findShunZi(max)
--         end
--         if max == min_ then
--             maxCard_ = max + 500
--             return maxCard_
--         else maxCard_ = max
--             return maxCard_
--         end
--     end
--     maxCard = findShunZi(max_)
--     dump(maxCard)
--     if maxCard < 500 then
--         maxCard = self:sanTiao(data)
--     end
--     return maxCard
-- end

-------------------同花-------------------
function  Paixing:tongHua(data)
    local minNum = data[1]
	for i = 1, #data do
        if data[i] < minNum then
            minNum = data[i]
        end
    end
    if isTongHua then
        maxCard = minNum + 600
    end
    if maxCard < 600 then
        maxCard = self:shunZi(data)
    end
    return maxCard
end

-------------------葫芦-------------------
function  Paixing:huLu(data)
    local cardSum
    local cardType
    -- dump(data)
    for i = 1, #data do
        cardSum = 0
        cardType = data[i]
        for j = i, #data do
            if data[j] == cardType then
                cardSum = cardSum + 1
            end
        end
        local cardThree = cardType
        -- dump("cardSumcardSum="..cardSum)
        if cardSum == 3 then
            for i_ = 1, #data do
                cardSum = 0
                cardType = data[i_]
                for j_ = i_, #data do
                    if data[j_] == cardType then
                        cardSum = cardSum + 1
                    end
                end
                -- dump("cardSumcardSum="..cardSum)
                if cardSum == 2 and cardType ~= cardThree then    
                    maxCard = 700 + cardType
                    return maxCard
                end
            end
        end
    end
    if maxCard < 700 then
        maxCard = self:tongHua(data)
    end
    return maxCard
end

-------------------铁支-------------------
function  Paixing:tieZhi(data)
    local cardSum = 0
    local cardOne = data[1]
	for i = 1, #data do
        if data[i] == cardOne then
            cardSum = cardSum + 1
        end
    end
    if cardSum > 3 then
        maxCard = 800 + cardOne
    else 
        cardSum = 0
        local cardTwo = data[2]
        for i = 2, #data do
            if data[i] == cardTwo then
                cardSum = cardSum + 1
            end
        end
        if cardSum > 3 then
            maxCard = 800 + cardTwo
        end
    end
    if maxCard < 800 then
        maxCard = self:huLu(data)
    end
    return maxCard
end

-------------------同花顺-------------------
function  Paixing:tongHuaShun(data)
    dump(data)
    local max_ = data[1]
	for i = 1, #data do
        if data[i] > max_ then
            max_ = data[i]
        end
    end
    local function maxShunZi(num)
        for i = 1, #data do
            if data[i] == num then
                return true
            end
        end
    end
    for i = 1, #data do
        if maxShunZi(max_-1) then
            if maxShunZi(max_-2) then
                if maxShunZi(max_-3) then
                    if maxShunZi(max_-4) then
                        isShunZi = true
                        if isTongHua then
                            maxCard = data[i] + 900
                        end  
                    end
                end
            end
        end
    end
    if maxCard > 900 then
        return maxCard
    else maxCard = self:tieZhi(data)
        return maxCard
    end
   
end

-------------------皇家同花顺-------------------
function  Paixing:royalTongHuaShun(data)
    local tongHuaColor = {0, 0, 0, 0}
    if #data == 5 then
        --判断同花
        for i = 1, #data1 do
            if data1[i] >16 and data1[i] <32 then
                tongHuaColor[1] = tongHuaColor[1] + 1
            elseif data1[i] >32 and data1[i] <48 then
                tongHuaColor[2] = tongHuaColor[2] + 1
            elseif data1[i] >48 and data1[i] <64 then
                tongHuaColor[3] = tongHuaColor[3] + 1
            elseif data1[i] >64  then
                tongHuaColor[4] = tongHuaColor[4] + 1    
            end
        end
        for i = 1, #tongHuaColor do
            if tongHuaColor[i] == 5 then
                isTongHua = true
            end
        end
        --判断顺子
        local function maxShunZi(num)
            for i = 1, #data do
                if data[i] == num then
                    return true
                end
            end
        end
        dump(data)
        for i = 1, #data do
            if data[i] == 1 then
                if maxShunZi(13) then
                    if maxShunZi(12) then
                        if maxShunZi(11) then
                            if maxShunZi(10) then
                                isShunZi = true
                                if isTongHua then
                                    maxCard = data[i] + 1000
                                end    
                            end
                        end
                    end
                end
            end
        end
        if maxCard > 1000 then
            return maxCard
        else maxCard = self:tongHuaShun(data)
            return maxCard
        end
    else maxCard = self:tongHuaShun(data)
        return maxCard
    end
end

function Paixing:ctor()
	print("SingleCard")
end
return Paixing