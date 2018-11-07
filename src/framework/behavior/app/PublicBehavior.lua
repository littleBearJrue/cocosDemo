--[[
	检查被调用的接口是否为公共方法
@module PublicBehavior
@author FuYao

Date   2018-9-13
Last Modified by   FuYao
Last Modified time 2018-9-13
]]

local BehaviorBase = require("framework.behavior.BehaviorBase");
local PublicBehavior = class("PublicBehavior",BehaviorBase)
PublicBehavior.className_  = "PublicBehavior";

function PublicBehavior:ctor()
    PublicBehavior.super.ctor(self, "PublicBehavior", nil, 1);
    self.publicFuncMap = {}; -- 公共方法配置
end

function PublicBehavior:dtor()
	
end

---对外导出接口
local exportInterface = {
    "registerEvent"; ---注册监听事件
    "unRegisterEvent"; ---取消事件监听
	"initPublicFunc"; -- 初始化公共接口配置
	"requestInterface"; -- 请求调用接口
};

-- 组件的方法绑定到object
function PublicBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]));
    end 
end

-- object解绑组件的方法
function PublicBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-- 组件重置
function PublicBehavior:reset(object)

end

---注册监听事件
function PublicBehavior:registerEvent(obj)
    obj.eventFuncMap = checktable(obj.eventFuncMap);
    for k,v in pairs(obj.eventFuncMap) do
        assert(obj[v],"配置的回调函数不存在")
        g_EventDispatcher:register(k,obj,obj[v])
    end
end

---取消事件监听
function PublicBehavior:unRegisterEvent(obj)
    if g_EventDispatcher then
        g_EventDispatcher:unRegisterAllEventByTarget(obj)
    end 
end

-- 初始化公共方法配置
function PublicBehavior:initPublicFunc(obj,config)
	self.publicFuncMap = checktable(config);
end

-- 调用接口
function PublicBehavior:requestInterface(obj,funcName,...)
	if self:_checkPrivate(funcName) then
        if obj[funcName] then
            return obj[funcName](obj,...);
        else
            error("不存在接口：" .. funcName);
        end
    else
        error("接口未开放给外部使用：" .. funcName);
    end
end

function PublicBehavior:_checkPrivate(funcName)
	for k, v in ipairs(self.publicFuncMap) do
        if v == funcName then
            return true;
        end
    end
end

return PublicBehavior;