--[[
    大厅的socket消息头格式
]]

local struct = import("babe.encoding.struct");

local QPHeadBehavior = class(BehaviorBase)
QPHeadBehavior.className_  = "QPHeadBehavior";

function QPHeadBehavior:ctor()
    QPHeadBehavior.super.ctor(self, "QPHeadBehavior", nil, 1)

end

function QPHeadBehavior:dtor()

end

---对外导出接口
local exportInterface = {
    "onWriteHead",
    "onReadHead",
    "getSocketHeadInfo",
}

function QPHeadBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end
end

function QPHeadBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end
end

-- 获取socket消息头配置
function QPHeadBehavior:getSocketHeadInfo(object)
    return {len = 15,gameId = 1};
end

---对外暴露的接口
function QPHeadBehavior:onWriteHead(object,cmd,bodyLen,headConfig)
    local len = headConfig.len + bodyLen - 4;
    local gameId = headConfig.gameId;
    local head = struct.pack(">I4BBBBI4HB",len,string.byte('Q'),string.byte('E'),1,0,cmd,gameId,0);
    return head;
end

---对外暴露的接口
function QPHeadBehavior:onReadHead(object,headBuf,headConfig)
    local position = 1;
    local len,b1,b2,b3,b4,cmd,gameid,code = struct.unpack('>I4BBBBI4HB',headBuf,position)
    return len + 4,cmd;
end

function QPHeadBehavior:reset(object)

end

return QPHeadBehavior;
