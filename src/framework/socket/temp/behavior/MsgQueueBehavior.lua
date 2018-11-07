--[[
    处理大厅的消息队列，
    发送的消息加入队列，并且给每条消息标记一个唯一的id
    没隔100毫秒，刷新一下队列，发现超过5s未处理的消息，当做异常消息，标记为重发消息。

    socket连接正常时，每次轮询后把标记为重发的消息重新再推送一下，如果还是失败就告知业务消息处理超时了
    如果socket异常，重连成功后如果没有触发重新登录就，把队列中阻塞的消息一次推送出现，否则就清空队列
@module messageQueue
@author FuYao
Date   2018-8-21
Last Modified time 2018-8-21 17:39:43
]]


---对外导出接口
local exportInterface = {
    "queryMsgQueue"; -- 启动消息队列轮询
    "addToMsgQueue"; -- 请求消息，加入消息队列
    "removeMsgQueue"; -- 收到响应消息，移除消息队列
    "getTimeOutMsg"; -- 获取消息队列中超时的消息
    "cleanQueue"; -- 清理消息队列，返回当前队列中超时的消息
};

local MAX_RSP_NUM = 50; -- 记录最近50个包的响应时间

local index = 1;
local function getId()
    index = index + 1
    return index;
end

local MsgQueueBehavior = class(BehaviorBase)
MsgQueueBehavior.className_  = "MsgQueueBehavior";

function MsgQueueBehavior:ctor()
    MsgQueueBehavior.super.ctor(self, "MsgQueueBehavior", nil, 1);
    self.mCmdSendQueue = {}; -- 消息队列
    self.msgMonitor = {}; -- 消息检测，记录每个包的响应时间
end

function MsgQueueBehavior:dtor()
    
end

function MsgQueueBehavior:bind(object)
    self.socketConfig = object.socketConfig;
    self.reportType = self.socketConfig.reportType; -- 上报标记
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function MsgQueueBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-- 打印日志
function MsgQueueBehavior:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 停止消息监听队列的计时
function MsgQueueBehavior:_stopMsgQueueHandler()
    if self.mHandler then
        self.mHandler:cancel();
        self.mHandler = nil;
    end
end

-- 检查消息队列中是否有超时响应的消息
function MsgQueueBehavior:queryMsgQueue()
    self:_stopMsgQueueHandler();
    self.mHandler = RunLoop.schedule(function()
        -- 检查队列中是否有超过5s还没有处理的消息
        local i = 1
        while i <= #self.mCmdSendQueue do
            local v = self.mCmdSendQueue[i];
            if (os.time() - v.time >= self.socketConfig.SVR_RCV_TIME_OUT) then
                v.resendNum = NumberLib.valueOf(v.resendNum);
                v.resendNum = v.resendNum + 1;
                if v.resendNum > 1 then
                    local info = table.remove(self.mCmdSendQueue,i);
                    local data = info.data;
                    if data and data.svrName then
                        self:_showLog("消息处理超时",data.svrName);
                        local errorInfo = {errorType = self.reportType.RECEIVE, errorMsg = "消息请求超时"}
                        g_EventDispatcher:dispatch(data.svrName,{},data.param,errorInfo);
                    end
                else
                    v.time = os.time(); -- 修改发送时间
                    -- 重发消息
                    i = i + 1;
                end
            else
                i = i + 1;
            end
        end
    end, 1, 0.5);
end

-- 记录发送消息的状态
function MsgQueueBehavior:addToMsgQueue(obj,data,cmd)
    local result = true;
    -- for k,v in pairs(self.mCmdSendQueue) do
    --     if (os.time() - v.time <= MsgQueueBehavior.MSGTIMEOUT) and v.data == data then
    --         -- 1s内的并且请求参数相同的请求，当做重复请求处理
    --         result = false;
    --         break;
    --     end
    -- end
    if result then
        local temp = clone(data);
        -- 给每个发送的消息加上序号
        local seq = getId();
        local tmp = {seq = seq};
        data.ext = json.encode(tmp);
        -- 记录发送消息队列
        table.insert(self.mCmdSendQueue, {data = data, time = os.time(), seq = seq, resendNum = 0, cmd = cmd, svrName = data.svrName});
    end
    return result;
end

-- 消息从队列中删除
function MsgQueueBehavior:removeMsgQueue(obj,seq)
    seq = NumberLib.valueOf(seq,0);
    local info = {};
    local msg = self.mCmdSendQueue[seq];
    for k,v in pairs(self.mCmdSendQueue) do
        if v and v.seq == seq then
            if v.time and v.svrName and v.cmd then
                local time = os.time() - v.time;
                table.insert(self.msgMonitor,{time = time, svrName = v.svrName, cmd = v.cmd});
                if #self.msgMonitor > MAX_RSP_NUM then
                    -- 最多记录多少条回包响应时间
                    table.remove(self.msgMonitor,1);
                end
            end
            info = table.remove(self.mCmdSendQueue,k);
            break;
        end
    end
    if info and info.data and info.data.param then
        return info.data.param;
    end
end

-- 获取超时的消息
function MsgQueueBehavior:getTimeOutMsg()
    local temp = {};
    for k,v in pairs(self.mCmdSendQueue) do
        v.resendNum = NumberLib.valueOf(v.resendNum);
        if v.resendNum == 1 then
            local info = table.remove(self.mCmdSendQueue,k);
            table.insert(temp,info);
        end
    end
    self:_showLog("-----------------------------------")
    return temp;
end

-- 清空数据
function MsgQueueBehavior:cleanQueue()
    self:_stopMsgQueueHandler();
    self.mCmdSendQueue = {};

    local temp = {
        reportType = self.reportType.RECEIVE;
        info = self.msgMonitor;
    };
    -- 回包的响应时间上报
    self.msgMonitor = {};
    return temp;
end

return MsgQueueBehavior;