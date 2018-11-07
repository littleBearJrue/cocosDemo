--[[
    cdn组件，配置默认的cdn连接地址信息
@module CdnDataBehavior
@author FuYao
Date   2018-9-3
Last Modified time 2018-9-4 11:55:00
]]

---对外导出接口
local exportInterface = {
    "getDefaultConfig", -- 获取默认的cdn配置
    "getAnalysisData", -- 获取需要解析是cdn数据
};


local defaultConfig = {
    version = 1;
    cdn = {
        {url = "http://console.oa.com:8080/site.json"};
    };
    hall = {
        main = {
            {ip="dfaccess.oa.com", port=7000};
            {ip="dfaccess.oa.com", port=7001};
            {ip="dfaccess.oa.com", port=7002};
            {ip="dfaccess.oa.com", port=7003};
            {ip="dfaccess.oa.com", port=7004};
            {ip="192.168.201.77", port=7000};
            {ip="192.168.201.77", port=7001};
            {ip="192.168.201.77", port=7002};
            {ip="192.168.201.77", port=7003};
            {ip="192.168.201.77", port=7004};
        };
        -- 备用地址
        backup = {

        };
    };
    http_url = {
        {url = "http://dfqptest01.oa.com/dfqp/"};
    };
};


local CdnDataBehavior = class(BehaviorBase)
CdnDataBehavior.className_  = "CdnDataBehavior";

function CdnDataBehavior:ctor()
    CdnDataBehavior.super.ctor(self, "CdnDataBehavior", nil, 1);
    self.mRecordList = {};
end

function CdnDataBehavior:dtor()
    self.mRecordList = nil;
end

function CdnDataBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function CdnDataBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 获取默认的cdn配置
function CdnDataBehavior:getDefaultConfig()
    return defaultConfig;
end

-- 获取需要解析是cdn数据
function CdnDataBehavior:getAnalysisData(obj,data)
    if data.hall then
        local hall = checktable(data.hall);
        data.main = checktable(hall.main);
        data.backup = checktable(hall.backup);
        data.hall = nil;
    end
end

return CdnDataBehavior;