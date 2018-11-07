--[[
     socket管理对象的组件，当前主要处理的是定义socket需要监听的svr事件。 
     IM和业务socket监听的svr命令不一样，可通过定义多个组件的方式来实现差异
@module ManagerBehavior
@author FuYao
Date   2018-3-22
Last Modified time 2018-8-21 17:33:43
]]


---对外导出接口
local exportInterface = {
    "getSocketMonitor"; -- 获取需要监听的svr消息
    "getSocketEvent"; -- 获取socket广播事件的id定义
};

-- socket的消息监听
local eventFuncMap =  {
    [g_CMD.S2C.HALL_RESPONSE]               = "receiveMsg"; -- 监听大厅pb消息
    [g_CMD.S2C.MATCH_RESPONSE]              = "receiveMsg"; -- 监听大厅比赛pb消息
    [g_CMD.S2C.HEART_RESPONSE]              = "receiveHeartMsg"; -- 监听心跳消息
    [g_Event.Resume]                        = "onResume"; -- 从后台回到游戏
    [g_Event.Pause]                         = "onPause"; -- 切换到后台
};

-- socket广播事件的id定义
local dispatchEvent = {
    SUCCESS = g_Event.SOCKET_CONNECT_SUCCESS; -- socket连接成功
    FAILED = g_Event.SOCKET_CONNECT_FAILED; -- socket连接失败
    CLOSED = g_Event.SOCKET_CLOSED; -- socket关闭
};

local ManagerBehavior = class(BehaviorBase)
ManagerBehavior.className_  = "ManagerBehavior";

function ManagerBehavior:ctor()
    ManagerBehavior.super.ctor(self, "ManagerBehavior", nil, 1);
end

function ManagerBehavior:dtor()
	
end

function ManagerBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function ManagerBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 停止消息监听队列的计时
function ManagerBehavior:getSocketMonitor()
    return eventFuncMap;
end

-- 获取socket广播事件的id定义
function ManagerBehavior:getSocketEvent()
    return dispatchEvent;
end

-- 回调父类的方法
function ManagerBehavior:callBackParent(obj,func,...)
    if obj and type(obj[func]) == "function" then
        obj[func](obj,...)
    end
end
return ManagerBehavior;