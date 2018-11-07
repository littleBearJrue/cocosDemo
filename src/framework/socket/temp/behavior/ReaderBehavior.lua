--[[
    socket的Reader组件，根据cmd配置，按照对应的格式解析好数据，抛出给外部使用
@module ReaderBehavior
@author FuYao
Date   2018-9-4
Last Modified time 2018-9-4 11:12:00
]]



---对外导出接口
local exportInterface = {
    "getReadLinsteners", -- 获取socket需要读包的cmd配置
    "readHeartPacket", -- 业务的消息消息
};

-- 需要接收的cmd配置
local cmdFuncMap =  {
    -- [g_CMD.S2C.HALL_RESPONSE]           = "readPbPacket"; -- 大厅和后端交互的rpc消息
    [g_CMD.S2C.HEART_RESPONSE]          = "readHeartPacket"; -- 业务的心跳消息
};

local ReaderBehavior = class(BehaviorBase)
ReaderBehavior.className_  = "ReaderBehavior";

function ReaderBehavior:ctor()
    ReaderBehavior.super.ctor(self, "ReaderBehavior", nil, 1);
    self.mRecordList = {};
end

function ReaderBehavior:dtor()
    self.mRecordList = nil;
end

function ReaderBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function ReaderBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 获取socket需要读包的cmd配置
function ReaderBehavior:getReadLinsteners(obj)
    return cmdFuncMap;
end

-- 解析心跳包
function ReaderBehavior:readHeartPacket(obj,readObj,cmd)
    local data = {cmd = cmd}
    return data;
end

return ReaderBehavior;