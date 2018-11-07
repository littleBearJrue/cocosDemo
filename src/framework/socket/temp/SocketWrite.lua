--[[
    发送socket消息
]]
local OutLuaPacket = import("BYKit.net").OutLuaPacket;


local SocketWriter = class();
BehaviorExtend(SocketWriter);

function SocketWriter:ctor(config)
    self.mOutPacket = new(OutLuaPacket);
    self.socketConfig = config;
    -- 绑定自定义组件
    local behaviors = checktable(config.behaviorConfig);
    local bevMap = checktable(behaviors.socketWrite);
    for k,v in pairs(bevMap) do
        if typeof(v,BehaviorBase) then
            self:bindBehavior(v);
        else
            g_UICreator:createToast({text = "SocketWriter中组件定义错误"})
            error("SocketWriter中组件定义错误")
        end
    end
end

function SocketWriter:dtor()
    self:unBindAllBehavior(); -- 删除绑定的组件
    delete(self.mOutPacket);
    self.mOutPacket = nil;
end

-- 打印日志
function SocketWriter:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end

-- 数据加密
local function encrypt_buffer(buffer)
    return PacketStream.encrypt_buffer(buffer, 0)
end

-- 组装发送的socket消息
function SocketWriter:writePacket(cmd,info)
    self:_showLog("SocketWriter:onWritePBMsg====",NumberLib.formatToHex(cmd));
    self.mOutPacket:reset();
    info = checktable(info);
    local result,data;
    local listeners = checktable(self:getWriteLinsteners());
    local func = listeners[cmd];
    if func and self[func] then
        data = self[func](self,cmd,self.mOutPacket,info);
    else
        if _DEBUG then
            data = self:writePbPacket(info);
        else
            result,data = pcall(self.writePbPacket,self,info);
        end
    end
    return data or "";
end


-- 解析pb协议
function SocketWriter:writePbPacket(info)
    local data;
    if info.svrName and info.param then
        local body_buf = {};
        local svrName = info.svrName;
        local param = info.param;
        local ext = tostring(info.ext) or "";
        -- local proto = PBConfig.getProto("C2S",svrName);
        -- local buffer = protobuf.encode(proto, param);
        local buffer = protobuf.encode(svrName, param);
        self.mOutPacket:writeString(svrName);-- 第一位：svr方法名
        self.mOutPacket:writeString("");-- 第二位：pb方法名
        self.mOutPacket:writeBinary(buffer);-- 第三位：pb的buffer
        self.mOutPacket:writeString(ext);-- 第四位：扩展字段
        local buf = TableLib.clone(self.mOutPacket:packetToBuf());
        data = encrypt_buffer(buf); -- 数据加密
    else
        error("发送的socket消息格式错误");
    end
    return data or "";
end

return SocketWriter;
