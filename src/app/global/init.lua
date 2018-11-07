--[[--ldoc desc
    业务自定义的全局管理类
]]


---------------------------------------------------------------------------------------------

local Global = {}

-- local globals = {};

-- -- 保护global中定义的全局变量不被修改
-- local protectEnv = function(env)
-- 	local mt  = getmetatable(env);
-- 	local cache = {};
-- 	mt.__newindex = function( t,k,v )
-- 		if cache[k] == nil then
-- 			cache[k] = v;
-- 		else
-- 			if cache[k] ~= v and globals[k] then
-- 				error("不允修改global中定义的：" .. k)
-- 			end
-- 		end
-- 		rawset(mt.__index, k, v)
-- 	end
-- end

-- --[[
-- 把map和globals的环境导入envG中
-- @envG：当前环境
-- @map：需要导入的环境
-- ]]
-- function Global:exportGlobalsToPKG(envG, map)
--     if map then
--         for k, v in pairs(map) do
--             envG[k] = v;
--         end
--         return;
--     end
-- 	-- protectEnv(envG);
--     for k, v in pairs(globals) do
--         envG[k] = v;
--     end
-- end

-- -- 大厅开放给外部的全局对象定义
-- local initData = require(".GlobalMap");
-- -- 大厅自定义的全局对象，导入globals
-- Global:exportGlobalsToPKG(globals,data.GlobalMap);

-- -- 禁止GlobalMap随意添加方法
-- setmetatable(data.GlobalMap,{
--         __newindex = function(t,k,v)
--             if type(v) == "function" then
--                 error("global不支持保新增函数");
--             end
--             globals[k] = v;
--         end,
--         __index = function(_,name)
--             return rawget(globals, name);
--         end
--     });


local function StringStartWith(str, chars)
    return chars == '' or string.sub(str, 1, string.len(chars)) == chars
end

local function StringEndsWith(str, chars)
    return chars == '' or string.sub(str, -string.len(chars)) == chars
end


local pakMap = {};

-- 获取相对包的路径
local function getRelativelyPath(str)
    -- 去掉最后一个"/"或"\"后面的内容
    local function dirname(str)
        if str:match(".-/.-") then
            local name = string.gsub(str, "(.*/)(.+)", "%1")
            return name
        elseif str:match(".-\\.-") then
            local name = string.gsub(str, "(.*\\)(.+)", "%1")
            return name
        else
            return ''
        end
    end
    -- "/"和"\"转换为"."
    local function getRelPath(str)
        if str:match("/") then
            str = string.gsub(str,"/","%.")
        end
        if str:match("\\") then
            str = string.gsub(str,"\\","%.")
        end
        -- 去掉首尾所有的"."
        str = string.gsub(str, "^%.*(.-)%.*$", "%1");
        return str;
    end
    local path = dirname(str);
    return getRelPath(path);
end

-- 获取相对路径
local function getCurPath(moduleName)
    if string.byte(moduleName, 1) ~= 46 then
        return moduleName;
    end
    local path = debug.getinfo(3,'S').source;
    path = getRelativelyPath(path);
    local file = path;
    for k,v in pairs(pakMap) do
        if StringStartWith(path,v)  then
            file = k;
            break;
        end
    end
    -- 防止 .. 的异常路径
    file = string.gsub(file, "(%.%.+)", "%.");
    path = file .. moduleName;
    return path;
end

-- 自定义require，修改为支持加载相对路径
local _require = require;
function require(moduleName)
    local path = getCurPath(moduleName);
    return _require(path)
end

-- 自定义import
local _import = import;
function import(path)
    if string.byte(path, 1) ~= 46 then
        pakMap[path] = path;
        if not StringEndsWith(path,".init") then
            path = path .. ".init"
        end
    end
    return _import(path);
end

local initData = require(".GlobalMap");
-- 启动时调用，初始化global
function Global:initData()
    initData();
end

return Global;