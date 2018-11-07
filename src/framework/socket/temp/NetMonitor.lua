--[[
	网络检测
@module NetMonitor
@author FuYao
Date   2018-3-22
Last Modified time 2017-12-20 16:06:43
]]

-- 代理回调父类{}
local function executeDelegate(delegate,func, ...)
    if delegate and func and delegate[func] and type(delegate[func]) == "function" then
        return delegate[func](delegate, ...);
    end
end

-- 暴露给外部的接口
local exportInterface = {
};

local NetMonitor = class();
NetMonitor.className_ = "NetMonitor";--类名
 
NetMonitor.eventFuncMap =  {
}

function NetMonitor:ctor(delegate)
	self:_init(delegate);
end

function NetMonitor:dtor()
	self.delegate = nil;
end

function NetMonitor:_init(delegate)
	self.delegate = delegate;
end

-- 响应外部调用的接口
-- funcName方法名
function NetMonitor:requestInterface(funcName,...)
    if self:_checkFunValid(funcName) then
    	if self[funcName] then
    		return self[funcName](self,...);
        else
            error("不存在接口：" .. funcName);
    	end
    else
        error("接口未开放给外部使用：" .. funcName);
    end
end

-- 检查调用的接口是否为开放给外部使用的
function NetMonitor:_checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

return NetMonitor;