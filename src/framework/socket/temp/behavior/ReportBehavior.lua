--[[
    记录socket相关的日志,
    日志记录(心跳、测速、重连、关闭、收发包频率、cdn下载等日志)
@module ReportBehavior
@author FuYao
Date   2018-8-1
Last Modified time 2018-8-1 16:06:43
]]


---对外导出接口
local exportInterface = {
    "addReportData", -- 记录信息
    "reportInfo", -- 上报记录信息
};


local ReportBehavior = class(BehaviorBase)
ReportBehavior.className_  = "ReportBehavior";

function ReportBehavior:ctor()
    ReportBehavior.super.ctor(self, "ReportBehavior", nil, 1);
    self.recordList = {}; -- 日志记录列表(心跳、测速、重连、关闭、收发包频率、cdn日志)
end

function ReportBehavior:dtor()
    self.recordList = {};
end

function ReportBehavior:bind(object)
    self.socketConfig = object.socketConfig;
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function ReportBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-- 打印日志
function ReportBehavior:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--[[
    记录日志
    type：日志类型
    info：日志信息
]]
function ReportBehavior:addReportData(obj,type,info)
    local temp = checktable(self.recordList[type]);
    table.insert(temp,info);
    self:_showLog("ReportBehavior:addReportData-------------",type,info);
end

-- 上报服务器
function ReportBehavior:reportInfo(obj,url)
    if StringLib.isEmpty(url) then
        return;
    end
    local action = "report.clientErrUp"
    url = url .. "?action=%s&app=%s&mid=%s&type=%s";
    url = string.format(url,action,appid,mid,type);
    local param = {
        post = {
            {
                type = "content",               -- post 发送的变量
                name = "content",               -- 服务器接受此内容的变量名称
                contents = info,                -- 发送的内容
                content_type = "text/plain",    -- 发送的类型
            };
        };
    };
    self:_showLog("=============url=",url);
    --g_QPHttp:requestInterface("upload",url, param, self, self.uploadResult);
end

function ReportBehavior:uploadResult(result, info)
    -- self:_showLog("************************",result,info);
end

return ReportBehavior;