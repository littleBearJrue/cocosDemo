--[[
    接收socket消息
]]
local InLuaPacket = import("BYKit.net").InLuaPacket;
local zip = import('babe.compress.zip');

local SocketReader = class();
BehaviorExtend(SocketReader);

function SocketReader:ctor(config)
    self.mReadPacket = new(InLuaPacket);
    self.socketConfig = config;
    local behaviors = checktable(config.behaviorConfig);
    -- 绑定自定义组件
    local bevMap = checktable(behaviors.socketReader);
    for k,v in pairs(bevMap) do
        if typeof(v,BehaviorBase) then
            self:bindBehavior(v);
        else
            g_UICreator:createToast({text = "SocketReader中组件定义错误"})
            error("SocketReader中组件定义错误")
        end
    end
end

-- 打印日志
function SocketReader:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end

function SocketReader:dtor()
    self:unBindAllBehavior(); -- 删除绑定的组件
    delete(self.mReadPacket);
    self.mReadPacket = nil;
end


-- 读取socket数据包
function SocketReader:readPacket(cmd,bodyBuf)
    local temp = PacketStream.decrypt_buffer(bodyBuf,0); -- 数据解密
    self.mReadPacket:copy(temp);
    self:_showLog("SocketReader:readPacket--",NumberLib.formatToHex(cmd));
    local result,data;
    local listeners = checktable(self:getReadLinsteners());
    local func = listeners[cmd];
    if func and self[func] then
        data = self[func](self, self.mReadPacket, cmd);
    else
        if _DEBUG then
            data = self:readPbPacket();
        else
            result,data = pcall(self.readPbPacket,self);
        end
    end
    data = checktable(data);
    data.cmd = cmd;
    self.mReadPacket:reset();
    return data;
end

-- 解析pb协议
--[[
    第一位：svr方法名
    第二位：pb方法名
    第三位：pb的buffer
    第三位：ext，table格式
]]
function SocketReader:readPbPacket()
    local svrName   = self.mReadPacket:readString();
    local param     = self.mReadPacket:readString();
    local buffer    = self.mReadPacket:readBinary();
    local ext       = self.mReadPacket:readString() or "{}";
    local pb_buf    = zip.decompress(buffer); -- 所有的pb数据svr都会zlib压缩，客户端需要先加压再pb反序列化
    -- local proto     = PBConfig.getProto("S2C", svrName);
    -- if proto then
        -- msg = protobuf.decode(proto,pb_buf);
    -- end
    local msg       = protobuf.decode(svrName,pb_buf);
    local data = {svrName = svrName, msg = msg, ext = json.decode(ext)};
    return data;
end

return SocketReader;