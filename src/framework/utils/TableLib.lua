--[[--tableLib 常用表处理接口
@module TableLib
]]

local tableConcat = table.concat
local tableInsert = table.insert

local type = type
local pairs = pairs
local tostring = tostring
local next = next
local TableLib = {}

--[[--
计算表格包含的字段数量

Lua table 的 "#" 操作只对依次排序的数值下标数组有效，TableLib.nums() 则计算 table 中所有不为 nil 的值的个数。

@param t 要计算的表格
@return integer
]]
function TableLib.nums(t)
    local temp = TableLib.verify(t)
    local count = 0
    for k, v in pairs(temp) do
        count = count + 1
    end
    return count
end


--[[--
将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
@usage
local dest = {a = 1,2,3,b = 4}
local src  = {a = 2,5,d = 4,e = 5}
TableLib.merge(dest, src)
-- dest = {[1] = 5,[2] = 3,a = 2, b = 4, d = 4,e = 5}

@param dest 目标表格
@param src  来源表格
]]
function TableLib.merge(dest, src)
    if not src or not dest then
        return;
    end
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[--
合并两个表格的内容

@usage
local src1 = {a = 1, b = 2}
local src2  = {c = 3, d = 4}
local temp = TableLib.merge2(src1, src2)
-- src1 = {a = 1, b = 2}
-- temp = {1,2,3,4}

@param src1 来源表格1
@param src2 来源表格2
]]
function TableLib.merge2(src1, src2)
    local tb ={}
    if src1 and next(src1) then
        for k, v in pairs(src1) do
            tableInsert(tb,v);
        end
    end
    if src2 and next(src2) then
        for k, v in pairs(src2) do
            tableInsert(tb,v);
        end
    end
    return tb;
end

--[[--
合并两个表格的以数字开头的内容

@usage
local src1 = {a = 1, b = 2, 3}
local src2  = {c = 3, d = 4, 4}
local temp = TableLib.merge3(src1, src2)
return {3, 4}

@param src1 来源表格1
@param src2 来源表格2
]]
function TableLib.merge3(src1, src2)
    local tb ={}
    if src1 and next(src1) then
        for k, v in pairs(src1) do
            if type(k) == "number" then 
                tableInsert(tb,v);
            end
        end
    end
    if src2 and next(src2) then
        for k, v in pairs(src2) do
            if type(k) == "number" then 
                tableInsert(tb,v);
            end
        end
    end
    return tb;
end

--[[--
合并两个表格的内容

@usage
local src1 = {a = 1, b = 2,e = 1}
local src2  = {c = 3, d = 4,e = 5}
local temp = TableLib.merge4(src1, src2)
-- src1 = {a = 1, b = 2,e = 1}
-- temp = {a = 1,b = 2,c = 3, d = 4,e = 5}
@param src2 来源表格2
]]
function TableLib.merge4(src1, src2)
    local tb ={}
    if src1 and next(src1) then
        for k, v in pairs(src1) do
            tb[k] = v
        end
    end
    if src2 and next(src1) then
        for k, v in pairs(src2) do
            tb[k] = v
        end
    end
    return tb;
end

--[[--
同步数据,把tab2 的数据同步到 tab1（不是合并）

@usage
local tab1 = {c = 1, b = 2,g=9}
local tab2  = {c = 3, d = 4}
TableLib.sync(tab1, tab2)
-- tab1  = {c = 3, b = 2,g=9}
-- tab2  = {c = 3, d = 4}
@param tab1 来源表格1
@param tab2 来源表格2
]]
function TableLib.sync(tab1, tab2)
    for k, v in pairs(tab2) do
        if tab1[k] ~= nil then
            tab1[k] = v;
        end
    end
end

--[[--
同步数据,把tab2 的数据同步到 tab1（不是合并）

@usage
local tab1 = {c = 1, b = 2,g=9}
local tab2  = {c = 3, d = 4}
TableLib.sync2(tab1, tab2)
-- tab1  = {c = 3, b = 2,d = 4,g=9}
-- tab2  = {c = 3, d = 4}
@param tab1 来源表格1
@param tab2 来源表格2
]]
function TableLib.sync2(tab1, tab2)
    for k, v in pairs(tab2) do
        tab1[k] = v;
    end
end 

--[[--
从表格中查找指定值，返回其 key，如果没找到返回 nil

@usage
local hashtable = {name = "dualface", comp = "chukong"}
print(TableLib.keyof(hashtable, "chukong")) -- 输出 comp

@param table hashtable 表格
@param mixed value 要查找的值
@return string 该值对应的 key

]]
function TableLib.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

--[[--
从表格中查找指定值，返回其索引，如果没找到返回 false
@function [parent=#table] indexof
@param table array 表格
@param mixed value 要查找的值
@param integer begin 起始索引值
@return integer#integer 

从表格中查找指定值，返回其索引，如果没找到返回 false

]]

function TableLib.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

--[[--
从表格中删除指定值，返回删除的值的个数

@param table array 表格
@param mixed value 要删除的值
@param [boolean removeall] 是否删除所有相同的值

@usage 
local array = {"a", "b", "c", "c"}
print(TableLib.removebyvalue(array, "c", true)) -- 输出 2

@return integer
]]
function TableLib.removeByValue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

--[[--
    判断table是否为空
]]
function TableLib.isEmpty(t)
    if t and type(t)=="table" then --FIXME 此句可以判空，为何还要循环表内元素？
        return next(t)==nil;
    end
    return true;
end

--[[--
    判断table是否有效
]]
function TableLib.isValid(t)
    if t and type(t)=="table" then
        return next(t) ~= nil;  
    end
    return false;            
end

--[[--
    判断table是否为table
]]
function TableLib.isTable(t)
    if type(t)=="table" then
        return true;
    end
    return false;
end

--[[--
    复制table，只复制数据，对table内的function无效
]]
function TableLib.copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = TableLib.copyTab(v)
        end
    end
    return tab
end

function TableLib.copyTo(target, source)
    for _,v in ipairs(source or {}) do
        table.insert(target, v)
    end
end

function TableLib.copyTo2(target, source)
    for _,v in pairs(source or {}) do
        table.insert(target, v)
    end
end

--[[--
    table校验，返回自身或者{}
]]
function TableLib.checktable(t)
    return TableLib.verify(t)
end

--[[--
    table校验，返回自身或者{}
]]
function TableLib.verify(t)
    if t and type(t)=="table" then
        return t;
    end
    return {};
end


--[[--
    table 元素数量
]]
function TableLib.size(t)
    if type(t) ~= "table" then
        return 0;
    end

    local count = 0;
    for _,v in pairs(t) do
        count = count + 1;
    end

    return count;
end

---比较两个table的内容是否相同
function TableLib.equal(t1,t2)
    if type(t1) ~= type(t2) then
        return false;
    else
        if type(t1) ~= "table" then
            return t1 == t2;
        else
            local len1 = TableLib.size(t1);
            local len2 = TableLib.size(t2);
            if len1 ~= len2 then
                return false;
            else
                local isEqual = true;
                for k,v in pairs(t1) do
                    if t2[k]  == nil then
                        isEqual = false;
                        break;
                    else
                        if type(t2[k]) ~= type(v) then
                            isEqual = false;
                            break;
                        else
                            if type(v) ~= "table" then
                                if t2[k] ~= v then
                                    isEqual = false;
                                    break;
                                end
                            else
                                isEqual = TableLib.equal(v,t2[k]);
                                if not isEqual then
                                    break;
                                end
                            end
                        end
                    end
                end

                return isEqual;
            end
        end
    end
end


--[[--
    从表里获取n个随机值
]]
function TableLib.random(t, num)
    assert(type(t) == "table", "invalid arg");
    local randomList = { }

    if not num or num > #t then
        num = #t;
    end

    local rangeList = { };
    for i,v in ipairs(t) do
        rangeList[i] = v;
    end

    for i = 1, num do
        local index = math.random(i, #rangeList);--生成一个随机数
        rangeList[i], rangeList[index] = rangeList[index], rangeList[i];--交换
        randomList[i] = rangeList[i];--交换以后把i位置的牌放到要返回的函数中
    end

    return randomList;
end

--[[--
    序列化table
]]
function TableLib.tostring(root)
    if not root then return end
    local cache = {  [root] = "root" }
    local flag = {};
    local function _dump(t,name)
        local mt = getmetatable(t)
        if mt and mt.__tostring then
            return tostring(t)
        end
        local temp = {}
        for i,v in ipairs(t) do
            flag[i] = true;
            if cache[v] then
                tableInsert(temp, cache[v])
            elseif type(v) == "table" then
                cache[v] = string.format("%s[%d]", name, i)
                tableInsert(temp, string.format("%s", _dump(v, cache[v])))
            else
                tableInsert(temp, tostring(v))
            end
        end
        for k,v in pairs(t) do
            if not flag[k] then
                local key = tostring(k)
                if cache[v] then
                    tableInsert(temp, string.format("%s=%s", key, cache[v]))
                elseif type(v) == "table" then
                    cache[v] = string.format("%s.%s", name, key)
                    tableInsert(temp, string.format("%s=%s", key, _dump(v, cache[v])))
                else
                    tableInsert(temp, string.format("%s=%s", key, tostring(v)))
                end
            end
        end
        return string.format("{%s}", tableConcat(temp,","));
    end
    return _dump(root, "root");
end

--[[--
   合并多个表
]]
function TableLib.deepMerge( src, ... )
    local arg = {...};
    for i,v in ipairs(arg) do
        for k,v in pairs(v) do
            if type(v) == "table" and type(src[k]) == "table" then
                TableLib.deepMerge(src[k], v);
            else
                src[k] = v;
            end
        end
    end
end

--[[--
   遍历表，返回true 终止
]]
function TableLib.select(t, func)
    if type(t) ~= "table" then 
        return;
    end 

    for i,v in pairs(t) do
        if func and func(i,v) == true then
            return i, v;
        end
    end
end

function TableLib.select2(t, func)
    if type(t) ~= "table" then 
        return;
    end 

    for i,v in ipairs(t) do
        if func and func(i,v) == true then
            return i, v;
        end
    end
end

function TableLib.selectall(t, func)
    local temp = {};
    for i,v in pairs(t) do
        if func and func(i,v) == true then
            temp[#temp+1] = v;
        end
    end
    return temp;
end

function TableLib.selectall2(t, func)
    local temp = {};
    for i,v in pairs(t) do
        if func and func(i,v) == true then
            temp[#temp+1] = v;
        end
    end
    return temp;
end

function TableLib.retrive(t, ...)
    if not t then
        return
    end
    local arg = {...}
    local tmp = t;
    for _,v in ipairs( arg ) do
        if tmp[v] then
            tmp = tmp[v];
        else
            return;
        end
    end
    return tmp;
end

--[[--
   只读表--不能新增元素，旧的可以修改
]]
function TableLib.lockWrite(t)
    local mt = getmetatable(t) or {};
    mt.__newindex = function(t,k,v)
        error(string.format("can't write [%s] into table",k))
    end;
    if not getmetatable(t) then
        setmetatable(t, mt);
    end
end

function TableLib.releaseLockWrite(t)
    local mt = getmetatable(t);
    if not (mt and mt.__newindex) then
        return
    end
    mt.__newindex = nil
end

function TableLib.getSubset(t, from, to)
    assert(from > 0 and from <= to and to <= #t, string.format("invalid range : %d, %d", from, to));
    local sub = {}
    for i=from,to do
        sub[#sub + 1] = t[i]
    end
    return sub
end

--[[--
   克隆一份表数据
]]
function TableLib.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--[[--
-- test
   克隆一份表数据
   支持过滤key
]]
local function infilter( filter, key, value )
    if filter.key then
        for i,v in ipairs(filter.key) do
            if v == key then return i end
        end
    end
    if filter.class then
        for i,v in ipairs(filter.class) do
            if typeof and typeof(value, v) then return i end
        end
    end
    return false
end
function TableLib.clone2(object, filter)
    local lookup_table = {}
    filter = filter or {}
    local function _copy(object, filter)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            if not infilter(filter, key, value) then
                new_table[_copy(key, filter)] = _copy(value, filter)
            end
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object, filter)
end

function TableLib.loadStrTab(strTab)
    if string.match(strTab, "^%s*%{.*%}%s*$") then
        return loadstring("return " .. strTab)()
    end
    return strTab;
end

function TableLib.allKeys( tab )
    if next(tab) == nil then
        print("nilTab")
        return
    end

    local keys = {}
    for k,_ in pairs(tab) do
        table.insert(keys, k)
    end
    return keys
end

function TableLib.keys(t)
    local r = {}
    for k, _ in pairs(t) do
        table.insert(r, k)
    end
    return r
end

function TableLib.values(t)
    local r = {}
    for _, v in pairs(t) do
        table.insert(r, v)
    end
    return r
end

function TableLib.default(src, default)
    if default and src and next(default) and type(src) == "table" then
        for k, v in pairs(default) do
            if src[k] == nil then
                src[k] = v;
            end
        end
    end
    return src;
end

return TableLib;
