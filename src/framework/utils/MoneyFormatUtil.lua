local NumberLib = require(".NumberLib");
local StringLib = require(".StringLib");
local M = {};

--@brief 将money拆分成每3位用逗号隔开
--@eg 123,456,789
function M.skipMoney(money)
    return M.skipMoneyAfterThreshold(money, 3, nil);
end

--@brief 将money以万、亿作为单位, 并保留一位小数点
function M.skipMoney2(money)
    return M.skipMoneyWithDecimals(money, 1, false);
end

--@brief 将money以万、亿作为单位，不保留小数点
function M.skipMoney3(money)
    return M.skipMoneyWithDecimals(money, 0, false);
end

--@brief 格式化金钱（四舍五入，不显示小数最后的0） curMoney：当前金钱 decimal:要显示的小数位 places：最多显示的整数位数
function M.skipMoney4(money, decimal, places)
    return M.skipMoneyWithDecimals(money, decimal, true,places)
end

function M.skipMoneyAfterThreshold(money, interval, threshold)
    money = NumberLib.valueOf(money);
    local strMoney = StringLib.valueOf( math.abs(money) );

    if threshold and math.abs(money) < threshold then
        --小于阀值
        return money;
    end

    local len = #strMoney;
    local count = 1;
    local ret = nil;
    for i = len, 0, -interval do
        local s = len - count*interval + 1;
        s = s < 1 and 1 or s;
        local e = len - (count-1)*interval;

        if not ret then
            ret = string.sub(strMoney, s, e);
        else
            ret = string.sub(strMoney, s, e) .. "," .. ret;
        end
        count = count + 1;
    end

    if string.sub(ret, 1, 1) == "," then
        ret = string.sub(ret, 2, #ret);
    end

    if money < 0 then
        ret = "-" .. ret;
    end

    if not ret then
        ret = money;
    end

    return ret;
end

local placesStr = {"个","十","百","千","万","十万","百万","千万","亿","十亿","百亿"};
function M.skipMoneyWithDecimals(money, decimal, isRounding, places)
    money = NumberLib.valueOf(money);
    decimal = NumberLib.valueOf(decimal);
    print(decimal)

    local strMoney = StringLib.valueOf( math.abs(money) );
    local len = #strMoney;
    places = NumberLib.valueOf(places,-1);-- 显示位数
    if (places > 0 and len < places) then
        -- 需要拆分的位数大于当前数值，直接返回
        return M.skipMoney(money);
    elseif places < 0 and len <= 5 then
        -- 没有定义拆分位数时，超过万才拆分
        return M.skipMoney(money);
    else
        local step = (len<=8) and 5 or 9;
        local unit = (len<=8) and "万" or "亿";
        if places > 0 then
            places = places > 11 and 11 or places;
            step = places;
            unit = placesStr[places]; -- 单位

        end
        decimal = (decimal>=step) and (step-1) or decimal;
        local leftStr = string.sub(strMoney, 1, len-step+1);
        local rightStr = "";
        if decimal and decimal > 0 then
            --计算小数点右边的
            rightStr = string.sub(strMoney, -step+1, -step+decimal);
        end
        if isRounding then
            local rounding = string.sub(strMoney, -step+1+decimal, -step+1+decimal);
            if NumberLib.valueOf(rounding) >= 5 then
                --进行四舍五入
                if decimal <= 0 and leftStr ~= "" then
                    leftStr = string.valueOf( NumberLib.valueOf(leftStr) + 1 );
                elseif decimal > 0 and rightStr ~= "" then
                    rightStr = string.valueOf( NumberLib.valueOf(rightStr) + 1 );
                end
            end
        end
        local ret = "";
        if rightStr ~= "" then
            rightStr = tostring(tonumber(rightStr) / (10 ^ decimal))
            if rightStr == "0" then
                ret = leftStr .. unit
            elseif rightStr == "1" then
                ret = (tonumber(leftStr) + 1) .. unit
            else
                if string.find(rightStr, "0.") then
                    rightStr = string.sub(rightStr, 3, 3+decimal-1)
                end
                ret = leftStr .. "." .. rightStr .. unit
            end
        else
            ret = leftStr .. unit
        end
        if tonumber(money) < 0 then
            ret = "-" .. ret;
        end
        if not ret then
            ret = ret;
        end
        return ret;
    end
end

return M;