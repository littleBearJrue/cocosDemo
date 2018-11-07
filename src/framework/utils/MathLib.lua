--[[
    数学库
]]
local BitUtil = require(".BitUtil");
local MathLib = {};

---根据系统时间初始化随机数种子，让后续的 math.random() 返回更随机的值
function MathLib.newrandomseed()
    local seed = tostring(os.time()):reverse():sub(1, 7)
    math.randomseed(seed)
    math.random()
    math.random()
    math.random()
    math.random()
    return seed;
end

---
---对数值进行四舍五入，如果不是数值则返回 0
-- @param value 输入值
-- @return number
function MathLib.round(value)
    value = MathLib.checknumber(value)
    return math.floor(value + 0.5)
end

---
-- 角度转弧度
-- @param angle 角度值
-- @return number 弧度值
function MathLib.angle2radian(angle)
    return angle*math.pi/180
end

---
-- 弧度转角度
-- @param angle 弧度
-- @return number 角度
function MathLib.radian2angle(radian)
    return radian/math.pi*180
end

--[[--
取整
]]
function MathLib.checkint(value)
    return MathLib.round(MathLib.checknumber(value))
end

--[[--
检查是否是数字
]]
function MathLib.checknumber(value, base)
    return tonumber(value, base) or 0
end

--[[
取数字整数部分
]]
function MathLib.getIntPart(x)
    if x <= 0 then
        return math.ceil(x);
    end

    if math.ceil(x) == x then
        x = math.ceil(x);
    else
        x = math.ceil(x) - 1;
    end
    return x;
end

--[[
    取余数
]]
function MathLib.getRemainder( x, y )
    if y == 0 then return nil end
    local tem = x / y
    local tem1 = tem - MathLib.getIntPart(tem)
    return tem1 * y
end


--[[
    获取一个2进制数第几位的值 例如
    8 其二进制为 1000
    MathLib.getBinIndexValue(8,4) == 1;

]]
function MathLib.getBinIndexValue(num, index)
    local a = BitUtil:_lshift(1,index - 1);
    if BitUtil:_and(a,num) == a then
        return 1
    else
        return 0
    end
end

return MathLib;
