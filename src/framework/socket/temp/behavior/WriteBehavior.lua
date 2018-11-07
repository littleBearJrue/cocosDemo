--[[
    socket的write组件，定义需要监听的cmd，按照cmd的配置封装好数据
@module WriteBehavior
@author FuYao
Date   2018-9-4
Last Modified time 2018-9-4 11:13:00
]]

---对外导出接口
local exportInterface = {
    "getWriteLinsteners", -- 获取socket需要写包的cmd配置
    "writeHeartPacket", -- 业务的心跳消息
};

-- 需要发送的cmd配置
local cmdFuncMap =  {
    -- [g_CMD.C2S.HALL_REQUEST]     = "writePbPacket"; -- 大厅和后端交互的rpc消息
    [g_CMD.C2S.HEART_REQUEST]    = "writeHeartPacket"; -- 业务的心跳消息
};

local WriteBehavior = class(BehaviorBase)
WriteBehavior.className_  = "WriteBehavior";

function WriteBehavior:ctor()
    WriteBehavior.super.ctor(self, "WriteBehavior", nil, 1);
    self.mRecordList = {};
end

function WriteBehavior:dtor()
    self.mRecordList = nil;
end

function WriteBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function WriteBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 获取socket需要写包的cmd配置
function WriteBehavior:getWriteLinsteners(obj)
    return cmdFuncMap;
end

-- 心跳消息
function WriteBehavior:writeHeartPacket(obj,cmd,writeObj,info)
    return "";
end

return WriteBehavior;