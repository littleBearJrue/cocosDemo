-- ProtobufManage.lua
-- Description: protobuf编解码封装

local protobuf = require('.protobuf')

local ProtobufManage = {}

ProtobufManage.protobufConfig = {
    -- 格式示例
    -- [key]   = {pb = protoPath, pkg = pkg, requestMsg = 'c2s_Message_Name', responseMsg = 's2c_Message_Name'}
    -- key          表的index，推荐使用server端对应的 包名+方法名
    -- pb           .proto文件使用工具生成的编码
    -- pkg          .proto文件中package的名称
    -- requestMsg   client传给server的protocol对应的message名称
    -- requestMsg   server传给client的protocol对应的message名称
}

ProtobufManage.MSG_TYPE = {
    REQUEST   = 'request',
    RESPONSE  = 'response',
}

-- 将buf编码成对应的protobuf格式
---@param cfgIndex string  对应配置表中的key
---@param buf string       需要解码的buffer
function ProtobufManage.encode(cfgIndex, buf)
    local proto = ProtobufManage.getProto(ProtobufManage.MSG_TYPE.REQUEST, cfgIndex);
    -- 传入消息原型和对应的table格式的数据，返回编码后的buffer。
    -- 如果编码失败，会直接报错。
    local buffer = protobuf.encode(proto, buf);
    return buffer
end

-- 解码protoBuf
---@param cfgIndex string  对应配置表中的key
---@param buf string       需要解码的buffer
function ProtobufManage.decode(cfgIndex, buf)
    local proto     = ProtobufManage.getProto(ProtobufManage.MSG_TYPE.RESPONSE, cfgIndex);
    local msg       = {};
    if proto then
        -- 传入消息原型和buffer，返回解码后的table。
        -- 如果解码失败，会直接报错。
        msg = protobuf.decode(proto,buf);
    end
    return msg
end

ProtobufManage.pbFile = {}

-- 获取对应的proto格式用于编解码
---@param msgType string   用于获取对应的message名称 编码:ProtobufManage.MSG_TYPE.REQUEST，解码:ProtobufManage.MSG_TYPE.RESPONSE
---@param cfgIndex string  对应配置表中的key
function ProtobufManage.getProto(msgType, cfgIndex)
    local message = ProtobufManage.protobufConfig[cfgIndex]
    if not message then
        error('unknow funcName :' .. cfgIndex)
        return
    end
    local config = {}
    local msg = msgType .. 'Msg'
    if type(message) == 'string' then
        config[msg] = message
    else
        config = message
    end

    if ProtobufManage.pbFile[config.pb] == nil then
        local pbFile = config.pb
        ProtobufManage.pbFile[config.pb] = {}
        ProtobufManage.pbFile[config.pb]["tab"] = protobuf.register(pbFile); -- 注册pb文件
    end

    if ProtobufManage.pbFile[config.pb]["tab"] then
        return ProtobufManage.pbFile[config.pb]["tab"][config.pkg][config[msg]];
    else
        return config.pkg .. "." .. config[msg];
    end
end

-- 注册自定义的配置表，格式请严格参考ProtobufManage.protobufConfig
---@param config table 自定义的配置表
function ProtobufManage.registerConfig(config)
    if not config then
        return
    end
    for k, v in pairs(config) do
        ProtobufManage.protobufConfig[k] = v
    end
end

return ProtobufManage