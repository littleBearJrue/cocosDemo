--[[
    socket连接后，开启心跳
    心跳正常，记录日志
    心跳超时，重连socket
    登陆成功并且svr上报成功后才会启动心跳，当网络断开时需要停止心跳。
    游戏切换到后台时停止心跳，回到游戏界面时，根据网络状态来决定是否需要重新启用心跳
@module SocketHeart
@author FuYao
Date   2018-8-23
Last Modified time 2018-8-23 11:21
]]

---对外导出接口
local exportInterface = {
    "onReceiveHeartMsg", -- 收到心跳包
    "stopHeartTimeOut", -- 停止心跳超时的计时器
    "onStopHeart", -- 停止心跳
    "onStartHeart", -- 开启心跳
};

local SocketHeart = class()
SocketHeart.className_  = "SocketHeart";
BehaviorExtend(SocketHeart);

function SocketHeart:ctor(delegate,config)
    self:_init(delegate,config);
end

function SocketHeart:dtor()
    self:unBindAllBehavior(); -- 删除绑定的组件
	self.delegate = nil;
    self:onStopHeart();
end

function SocketHeart:_init(delegate,config)
    assert(delegate.sendHeartMsg,"父类必须实现sendHeartMsg函数");
    assert(delegate.reConnectSocket,"父类必须实现reConnectSocket函数");
    assert(delegate.reportHeartData,"父类必须实现reportHeartData函数");
    self.delegate = delegate;
    self.socketConfig = config;
    local behaviors = checktable(config.behaviorConfig);
    local bevMap = checktable(behaviors.heart);
    for k,v in pairs(bevMap) do
        if typeof(v,BehaviorBase) then
            self:bindBehavior(v);
        else
            g_UICreator:createToast({text = "SocketHeart中组件定义错误"})
            error("SocketHeart中组件定义错误")
        end
    end
end

-- 响应外部调用的接口
-- funcName方法名
function SocketHeart:requestInterface(funcName,...)
    local isSwitch = self:_onReqHeartBehavior("getHeartSwitch",true); -- 获取心跳开关
    if not isSwitch then
        -- 心跳开关关闭，直接返回
        return;
    end
    if self:checkFunValid(funcName) then
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
function SocketHeart:checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

-- 打印日志
function SocketHeart:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 发送心跳包
function SocketHeart:onStartHeart()
    self:_showLog("SocketHeart:onStartHeart-------");
    self:onStopHeart(); -- 先停止心跳轮询计时器，重新启动  
    self.mHeartLoop = RunLoop.schedule(function()
        self.mStartTime = Clock.system_now(); -- 记录心跳发包时间
        self:_executeDelegate("sendHeartMsg",self:_onReqHeartBehavior("getHeartCmd")); -- 通知加载改组件的类，发送心跳包
        self:stopHeartTimeOut(); -- 先停止心跳超时计时器
        -- 3/4的心跳时间还没有收到心跳回包就认为心跳超时，停止心跳，触发重连逻辑
        self.mTimeOut = RunLoop.schedule(function()
            self:_showLog("-------心跳超时");
            self:_addHeartLog(); -- 上报记录
            self:onStopHeart(); -- 心跳超时，停止心跳
            self:_executeDelegate("reConnectSocket"); -- 心跳超时，通知加载改组件的类，关闭socket重连连接
        end, self:_onReqHeartBehavior("getHeartTimeOut",7.5), -1);
    end, 1, self:_onReqHeartBehavior("getHeartTime",10));
    -- 1s后启动心跳
end

-- 停止心跳计时器和心跳查询的超时计时器
function SocketHeart:onStopHeart()
    if self.mHeartLoop then
        self.mHeartLoop:cancel();
        self.mHeartLoop = nil;
    end
    self:stopHeartTimeOut();
end

-- 停止心跳超时计时器
function SocketHeart:stopHeartTimeOut()
    if self.mTimeOut then
        self.mTimeOut:cancel();
        self.mTimeOut = nil;
    end
end

-- 收到svr的心跳回包，停止心跳超时计时器
function SocketHeart:onReceiveHeartMsg()
    self:_showLog("SocketHeart:onReceiveHeartMsg--------收到svr的心跳回包，停止心跳超时计时器")
    self:stopHeartTimeOut();
    self:_addHeartLog();
end

-- 记录心跳日志
function SocketHeart:_addHeartLog()
    local data = self:_onReqHeartBehavior("recordHeartTime");
    if not TableLib.isEmpty(data) then
        self:_executeDelegate("reportHeartData",data);
    end
end

-- 回调父类的方法
function SocketHeart:_executeDelegate(func,...)
    if self.delegate and func and self.delegate[func] and type(self.delegate[func]) == "function" then
        self.delegate[func](self.delegate, ...);
    end
end

-- 调用心跳组件中的方法
function SocketHeart:_onReqHeartBehavior(func,default,...)
    if type(self[func]) == "function" then
        return self[func](self,...);
    end
    return default;
end

return SocketHeart;