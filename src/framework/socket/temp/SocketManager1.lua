--[[add desc
@module SocketManager
@author FuYao
Date   2018-3-23
Last Modified time 2017-12-20 16:06:43
]]

local BaseSocket = import("BYKit.net").BaseSocket;
local socketWrite = require("SocketWrite");
local socketReader = require("SocketReader");
local SocketHeart = require("SocketHeart");
local connectLogic = require("link.connectLogic");


-- 对外导出的接口说明
local exportInterface = {
    "openSocket"; -- 打开socket
    "closeSocket"; -- 关闭socket
    "isConnected"; -- socket是否已经连接
    "reConnectSocket"; -- 请求重连
    "sendMsg"; -- socket发包
    "addBodyWriter"; -- 导入写包模块
    "addBodyReader"; -- 导入读包模块
    "startHeart"; -- 启动心跳，登陆成功后开启心跳
    "stopHeart"; -- 停止心跳，掉线、登出、
};

local SocketManager = class(BaseSocket);
SocketManager.className_ = "SocketManager";--类名
BehaviorExtend(SocketManager);


---配置事件监听函数
SocketManager.eventFuncMap =  {
    -- [g_CMD.S2C.HALL_RESPONSE]               = "receiveMsg"; -- 监听大厅pb消息
    -- [g_CMD.S2C.HEART_RESPONSE]              = "receiveHeartMsg"; -- 监听心跳消息
}

function SocketManager:ctor(config)
    self:_init(config);
end

function SocketManager:dtor()
    self:_reset();
end

function SocketManager:_init(config)
    self:_initConfig(config);

    local behaviors = checktable(self.socketConfig.behaviorConfig);
    local bevMap = checktable(behaviors.mamager);
    -- 绑定定义的组件
    for k,v in pairs(bevMap) do
        if typeof(v,BehaviorBase) then
            self:bindBehavior(v);
        else
            g_UICreator:createToast({text = "SocketManager中组件定义错误"})
            error("SocketManager中组件定义错误")
        end
    end
    self:registerEvent();
    self:initHeadConfig(self:getSocketHeadInfo()); -- 定义socket消息头
    self.write = new(socketWrite,self.socketConfig);
    self.reader = new(socketReader,self.socketConfig);

    self:addBodyWriter(self.write);
    self:addBodyReader(self.reader);

    
    self.connectLogic = new(connectLogic,self,self.socketConfig); -- socket连接逻辑
    self.SocketHeart = new(SocketHeart,self,self.socketConfig); -- 心跳逻辑

    -- 获取需要发送的广播事件id配置
    self.socketEvent = checktable(self:getSocketEvent());
end

-- 合并自定义的socket配置
function SocketManager:_initConfig(config)
    local defaultConfig = clone(require("SocketConfig"));
    config = checktable(config);
    local behaviorConfig = checktable(config.behaviorConfig);
    local defaultbehavior = defaultConfig.behaviorConfig;
    TableLib.merge(defaultConfig,config);

    defaultConfig.behaviorConfig = defaultbehavior;
    if not TableLib.isEmpty(behaviorConfig) then
        for k,v in pairs(behaviorConfig) do
            if k and v then
                TableLib.merge(defaultConfig.behaviorConfig[k],v);
            end
        end
    end
    self.socketConfig = defaultConfig;
    self.reportType = self.socketConfig.reportType;
end

function SocketManager:_reset()
    self:unBindAllBehavior(); -- 删除绑定的组件
    self:unRegisterEvent();--解绑事件
    self:removeBodyWriter(self.write);
    self:removeBodyReader(self.reader);
    local temp = {self.connectLogic,self.SocketHeart,self.write,self.reader};
    for k,v in pairs(temp) do
        delete(v);
        v = nil;
    end
    temp = nil;
end

---注册监听事件
function SocketManager:registerEvent()
    self.eventFuncMap = checktable(self:getSocketMonitor()); -- 获取监听配置
    for k,v in pairs(self.eventFuncMap) do
        assert(self[v],"配置的回调函数不存在");
        g_EventDispatcher:register(k,self,self[v]);
    end
end

---取消事件监听
function SocketManager:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

-- 响应外部调用的接口
-- funcName方法名
function SocketManager:requestInterface(funcName,...)
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
function SocketManager:_checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

-- 打印日志
function SocketManager:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end    
    Log.d(self.socketConfig.logFlag, ...);
end

-- 切换到后台
function SocketManager:onPause()
    self:stopHeart();
    self.pauseTime = Clock.now();
end

-- 从后台回到游戏
function SocketManager:onResume()
    local sleepTime = 0;
    if self.pauseTime then
        sleepTime = Clock.now() - self.pauseTime;
    end
    if sleepTime >= 5*60*1000 then
        -- 时间超过5分钟，断开socket重连
        self:closeSocket(true);
    else
        -- 5分钟内回到游戏
        if self:isConnected() then
            -- socket连接正常，并且当前是登陆状态，重新启动心跳逻辑
            self:startHeart();
        else
            -- 重连socket
            self:reConnectSocket();
        end
    end
end
-------------------------------------------------------------------------------------------------
-- 请求打开socket，先获取服务器地址
function SocketManager:openSocket(ip,port)
    if self:isConnected() then
        -- 已经连接成功
        return true;
    end
    self.connectLogic:requestInterface("requestOpenSocket",ip,port);
    return false;
end

-- socket连接成功
function SocketManager:onSocketConnected(socket,ip,port)
    self:onMsgQueueBehavior("queryMsgQueue");-- 启动消息查询队列
    if self:isConnected() then
        -- 已经连接成功
        socket:close();
        return;
    end
    self:onConnected(socket); -- 保存socket对象
    local function socketClosed(param)
        self:onSocketClosed(param);
    end
    socket:set_on_closed(socketClosed);
    
    -- 重新发送超时消息
    local msg = checktable(self:onMsgQueueBehavior("getTimeOutMsg"));
    for k, v in pairs(msg) do
        if v.cmd and v.data then
            self:sendMsg(v.cmd,v.data);
        end
    end
	-- self:_showLog("SocketManager:onSocketConnected=",self.socketConfig.logFlag, "-广播通知socket连接成功,ip=" , ip, "--port=" , port);
 --    g_UICreator:createToast({text = self.socketConfig.logFlag .. "-广播通知socket连接成功,ip=" .. ip .. "--port=" .. port});
    -- 通知socket连接成功
    g_EventDispatcher:dispatch(self.socketEvent.SUCCESS);
end

-- socket连接失败
function SocketManager:onSocketConnectFailed()
    -- 弹框提示连接失败，需要重新登录
    local data = self:onMsgQueueBehavior("cleanQueue"); -- 清空消息队列
    if not TableLib.isEmpty(data) then
        -- 回包的响应时间上报
        self:reportData(data);
    end
    -- 通知socket连接失败
    g_EventDispatcher:dispatch(self.socketEvent.FAILED);
end

-- socket关闭成功
function SocketManager:onSocketClosed(param)
    self:_showLog("socket 关闭成功",param)
    self:setSocket(nil); -- 清空socket对象
    self:stopHeart();-- socket已经关闭，停止心跳。
    -- (加上这个是应为，socket关闭后被动关闭的情况，所以收到这条消息也需要停止心跳逻辑)
    -- 上报socket关闭日志
    local temp = {reportType = self.reportType.CLOSE;info = param};
    self:reportData(temp);
    if string.find(param,"remote") then
        -- 被动关闭socket
        self:reConnectSocket();
    else
        if self.reconnectInfo then
            -- 重连socket
            if self.reconnectInfo.reconnect == true and Clock.now() - self.reconnectInfo.time > 5000 then
                -- 重连标志为true，并且时间没有超过5s
                self:reConnectSocket();
                self.needReconnect = nil;
                return;
            end
        end
        -- 通知socket已经关闭
    end
    self.needReconnect = nil;
    g_EventDispatcher:dispatch(self.socketEvent.CLOSED);
end

-- 请求关闭socket
function SocketManager:closeSocket(needReconnect)
    self:log("=================SocketManager:closeSocket");
    self:stopHeart(); -- 关闭socket时，停止心跳
    if self:isConnected() then
        if needReconnect == true then
            -- 标记为socket断开后需要马上重连
            self.reconnectInfo = {reconnect = needReconnect, time = Clock.now()};
        end
        tasklet.spawn(function()
            local socket = self:getSocket();
            socket:close();
        end);
    else
        if needReconnect == true then
            -- 当前sokcet已经关闭，重新打开
            self:reConnectSocket();
        end
    end
end

-- socket是否已经连接成功
function SocketManager:isConnected()
    local socket = self:getSocket();
    if socket and socket:status() == "normal" then
        return true;
    end
    return false;
end

-- 请求重连socket
function SocketManager:reConnectSocket()
    self.connectLogic:requestInterface("reConnectSocket");
end

-- 发送心跳包
function SocketManager:sendHeartMsg(cmd)
    self:_showLog("SocketManager:sendHeartMsg---",cmd)
    if cmd then
        self:sendMsg(cmd);
    end
end

-- 记录日志
function SocketManager:reportData(info)
    self.connectLogic:requestInterface("reportData",info);
end


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- 发送socket消息
function SocketManager:sendMsg(cmd,data,...)
    -- socket未连接，返回
    local isConnected = self:openSocket();
    if not isConnected then
        return;
    end
    if data and data.svrName then
        ---收到socket消息息先入队列
       self:onMsgQueueBehavior("addToMsgQueue", data, cmd); -- 请求消息添加到消息队列
    end
    self:log("SocketManager---发送socket消息",NumberLib.formatToHex(cmd),data);
    dump(data,"SocketManager---发送socket消息");
    BaseSocket.sendMsg(self,cmd,data,...);
    return true;
end

-- ，监听svrName,接收socket消息
function SocketManager:receiveMsg(data)
    -- 停止心跳超时计时器
    if data and data.svrName and data.msg then
        local msg = self:_analyseData(data.msg);
        local info = {};
        if data.ext and data.ext.seq then
            -- 收到消息回复，从消息队列中删除
            info = self:onMsgQueueBehavior("removeMsgQueue",data.ext.seq);
        end
        self:log("SocketManager---收到socket消息",data.svrName,msg,info);
        g_EventDispatcher:dispatch(data.svrName,msg,info);

        -- g_UICreator:createToast({text = "收到socket消息"})
        return;
    elseif data and data.cmd then
        -- 处理socket的非pb消息
        self:log("SocketManager---收到非PB的socket消息-----",data);
        g_EventDispatcher:dispatch(data.cmd,data);
        return;
    else
        self:log("SocketManager---收到的socket的空消息",data);
    end
    -- 停止心跳超时计时器
    self:_onHeartInterface("stopHeartTimeOut");
end

-- 收到心跳回包，通知心跳模块
function SocketManager:receiveHeartMsg()
    self:_onHeartInterface("onReceiveHeartMsg");
end

-- 启动心跳逻辑
function SocketManager:startHeart()
    self:_onHeartInterface("onStartHeart");
end

-- 停止心跳逻辑
function SocketManager:stopHeart()
    self:_onHeartInterface("onStopHeart");
end

-- 调用心跳中的方法
function SocketManager:_onHeartInterface(func,...)
    if self.SocketHeart then
        return self.SocketHeart:requestInterface(func,...);
    end
end

-- 调用消息组件中的方法
function SocketManager:onMsgQueueBehavior(func,...)
    if type(self[func]) == "function" then
        self:_showLog("onMsgQueueBehavior ",func)
        return self[func](self,...)
    else
        self:_showLog("onMsgQueueBehavior is nil",func)
    end
end

-- 上报心跳日志
function SocketManager:reportHeartData(info)
    local temp = {reportType = self.reportType.HEART;info = info};
    self:reportData(temp);
end

-- 解析pb数据，过滤__message内容
function SocketManager:_analyseData(data)
    if TableLib.isTable(data) then
        data = checktable(data);
        local list = {};
        for k, v in pairs(data) do
            if v ~= nil and k~="___message" then 
                if type(v) == "table" then
                    list[k] = self:_analyseData(v);
                elseif type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                    list[k] = v;
                else
                    self:log("svr返回了异常的数据类型",data);
                    -- function, userdata, thread
                end
            end
        end
        return list;
    else
        return data;
    end
end

function SocketManager:log(tag,...)
    self:_showLog(tag,...)
end

return SocketManager;