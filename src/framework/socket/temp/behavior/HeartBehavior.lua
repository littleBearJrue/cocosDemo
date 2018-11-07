--[[
    设置心跳包轮询的时间：默认为10s，可根据业务需要调整
    设置心跳包超时时间：默认为7.5s，可根据业务需要调整
    记录心跳日志：
    记录最近50次心跳间隔时间，当网络出现异常时，每10心跳取平均值，加上最长和最短的心跳间隔共7个心跳数据上报
    登陆成功并且svr上报成功后才会启动心跳，当网络断开时需要停止心跳。
@module HeartBehavior
@author FuYao
Date   2018-8-23
Last Modified time 2018-8-23 11:55:00
]]

---对外导出接口
local exportInterface = {
    "getHeartSwitch", -- 心跳开关，是否开启
    "getHeartCmd", -- 获取心跳命令
    "getHeartTime", -- 获取心跳包轮询间隔时间
    "getHeartTimeOut", -- 获取心跳超时时间
    "recordHeartTime", -- 记录心跳收发包的间隔时间
};

local HEART_TIME = 10; -- 心跳间隔时间10s
local HEART_TIME_OUT = (10*3)/4; -- 心跳超时时间
local MAX_HEART_RECORD = 50; -- 记录最近50次的心跳情况
local HEART_TIME_NOTICE = 2*1000; -- 心跳异常提醒时间，2s没有收到心跳响应，提示网络不好
local HEART_COUNT_TIME = 10; -- 取10次心跳的平均时间
local HEART_SWITCH = true; -- 心跳开关，是否需要心跳逻辑

local HeartBehavior = class(BehaviorBase)
HeartBehavior.className_  = "HeartBehavior";

function HeartBehavior:ctor()
    HeartBehavior.super.ctor(self, "HeartBehavior", nil, 1);
    self.mRecordList = {};
end

function HeartBehavior:dtor()
    self.mRecordList = nil;
end

function HeartBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function HeartBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 获取心跳命令
function HeartBehavior:getHeartCmd()
    return g_CMD.C2S.HEART_REQUEST
end

-- 心跳开关，是否开启
function HeartBehavior:getHeartSwitch()
    return HEART_SWITCH;
end

-- 获取心跳包轮询间隔时间
function HeartBehavior:getHeartTime()
    return HEART_TIME;
end

-- 获取心跳超时时间
function HeartBehavior:getHeartTimeOut()
    return HEART_TIME_OUT;
end

-- 记录心跳间隔时间
function HeartBehavior:recordHeartTime()
    self.mStartTime = self.mStartTime or Clock.system_now();
    local skipTime = Clock.system_now() - self.mStartTime;
    table.insert(self.mRecordList, skipTime);
    self.mStartTime = nil;
    if skipTime > HEART_TIME_NOTICE then
        -- 心跳回包时间超过2s，说明网络情况不是很好
        g_UICreator:createToast({text = "当前网络状况不好，time=" .. skipTime});
    end
    -- 最多记录N条记录
    if #self.mRecordList == MAX_HEART_RECORD then
        -- 上报记录
        return self:_refreshRecord();
    end
end

-- 获取每10次心跳的平均值5次和最长、最短间隔时间
function HeartBehavior:_refreshRecord()
    if TableLib.isEmpty(self.mRecordList) then
        return {};
    end
    local arr = {};
    local minTime = 100000; -- 心跳最短时间
    local maxTime = 0; -- 心跳最长时间
    local tmp = {};
    for k,v in ipairs(self.mRecordList) do
        table.insert(tmp,v);
        if k%HEART_COUNT_TIME == 0 then
            table.insert(arr,tmp);
            tmp = {};
        end     
        if v < minTime then
            minTime = v; -- 获取最短时间
        end
        if v > maxTime then
            maxTime = v; -- 获取最长时间
        end
    end
    -- 计算每HEART_COUNT_TIME次心跳的平均回包时长
    local record = {};
    for k, v in ipairs(arr) do
        local tmp = 0;
        for _, value in ipairs(v) do
            tmp = tmp + value;
        end
        table.insert(record,tmp/#v);
    end
    table.insert(record,minTime);
    table.insert(record,maxTime);
    self.mRecordList = {};
    return record;
end

return HeartBehavior;