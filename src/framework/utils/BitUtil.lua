--[[
    字符的位运算
]]
local BitUtil={
    data32={}
}

BitUtil.tag = "|";

local tostring = tostring;

for i=1,32 do
    BitUtil.data32[i] = 2^(32-i);
end

-- 字符转换为二进制
function BitUtil:d2b(arg)
    local tr={}
    for i=1,32 do
        if arg >= self.data32[i] then
            tr[i] = 1;
            arg = arg - self.data32[i];
        else
            tr[i] = 0;
        end
    end
    return tr;
end

-- 二进制转换为字符
function BitUtil:b2d(arg)
    local nr=0
    for i = 1, 32 do
        if arg[i] == 1 then
            nr = nr + 2^(32-i);
        end
    end
    return nr;
end

-- 与操作
function BitUtil:_and(a,b)
    local op1 = self:d2b(a);
    local op2 = self:d2b(b);
    local r = {};    
    for i = 1,32 do
        if op1[i] == 1 and op2[i] == 1 then
            r[i] = 1;
        else
            r[i] = 0;
        end
    end
    return self:b2d(r);
end

-- 或操作
function BitUtil:_or(a,b)
    local op1 = self:d2b(a);
    local op2 = self:d2b(b);
    local r = {};
    for i=1,32 do
        if op1[i] == 1 or op2[i] == 1 then
            r[i] = 1;
        else
            r[i] = 0;
        end
    end
    return self:b2d(r);
end

-- 异或操作
function BitUtil:_xor(a,b)
    local op1 = self:d2b(a);
    local op2 = self:d2b(b);
    local r = {};
    for i = 1,32 do
        if op1[i] == op2[i] then
            r[i] = 0;
        else
            r[i] = 1;
        end
    end
    return self:b2d(r);
end

-- 非参数
function BitUtil:_not(a)
    local op1 = self:d2b(a);
    local r = {};
    for i = 1,32 do
        if op1[i] == 1 then
            r[i] = 0;
        else
            r[i] = 1;
        end
    end
    return self:b2d(r);
end

-- 右移操作
function BitUtil:_rshift(a,n)
    local op1 = self:d2b(a);
    local r = self:d2b(0);
    if n < 32 and n > 0 then
        for i = 1,n do
            for i = 31,1,-1 do
                op1[i+1] = op1[i];
            end
            op1[1] = 0;
        end
        r = op1;
    end
    return self:b2d(r);
end

-- 左移操作
function BitUtil:_lshift(a,n)
    local op1 = self:d2b(a);
    local r = self:d2b(0);
    if n < 32 and n > 0 then
        for i = 1,n   do
            for i = 1,31 do
                op1[i] = op1[i+1];
            end
            op1[32] = 0;
        end
        r = op1;
    end
    return self:b2d(r);
end

-- 把string转换为二进制数据，进行左移位操作
function BitUtil:encrypt(str,offset)
    local bytes = {}
    for i = 1, string.len(str), 1 do
        bytes[i] = string.byte(str, i)
    end
    local temp = {};
    for k,v in ipairs(bytes) do
        local ls = self:_lshift(v,offset);
        table.insert(temp,ls);
    end
    return table.concat(temp,BitUtil.tag);
end

-- 对加密数据，进行ungzip加压，再右移位操作，转换为string输出
function BitUtil:decrypt(str,offset)
    local data = tostring(str);
    local info = self:split(data,BitUtil.tag);
    local result = {};
    for k,v in ipairs(info) do
        local rs = self:_rshift(v,offset);
        table.insert(result,rs);
    end
    return string.char(unpack(result));
end

-- 分割字字符串
function BitUtil:split(str, delimiter)
    if (delimiter == '') then return false end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, tonumber(string.sub(str, pos, st - 1)))
        pos = sp + 1
    end
    table.insert(arr, tonumber(string.sub(str, pos)))
    return arr
end

return BitUtil;