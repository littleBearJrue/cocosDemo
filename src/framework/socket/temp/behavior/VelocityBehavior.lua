--[[
    网络测速接口；可同时打开多个ip，并且记录每个IP的连接情况
    这个类只处理socket连接操作，连接队列中首次连接上的socket对象通过代理connectSuccess回调通知父类
    队列的所有连接结果，通过接口的回调方法通知调用方
@module VelocityBehavior
@author FuYao
Date   2018-8-1
Last Modified time 2018-8-1 16:06:43
]]

local Socket = import("babe.network.socket");
---对外导出接口
local exportInterface = {
    "linkVelocity", --> config,callBack
    "specialConnect", --> config,callBack 特殊域名连接测试
    "finishCurConnect", --> 停止当前正在测速的所有请求
};

local SVR_LINK_TIME_OUT = 5; -- socke连接超时时间
local CONNECT_TIME_OUT = 75000; -- 默认的连接失败时间

local VelocityBehavior = class(BehaviorBase)
VelocityBehavior.className_  = "VelocityBehavior";

function VelocityBehavior:ctor()
    VelocityBehavior.super.ctor(self, "VelocityBehavior", nil, 1);
    self.taskList = {};
end

function VelocityBehavior:dtor()
	self:_stopAllTask();
end

function VelocityBehavior:bind(object)
    self.socketConfig = object.socketConfig;
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function VelocityBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-- 检查网络是否可用
function VelocityBehavior:checkNetValid()
    -- 判断是否有网络
    local flag = DevicePlugin:isNetworkConnected();
    return flag;
end

-- 打印日志
function VelocityBehavior:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--[[
    链路测速，返回连接最快的链接
    @config：测试连接的配置{{ip,port},{ip,port},...}
    @callBack：测速结果回调，代理方法
]]
function VelocityBehavior:linkVelocity(obj,config,callBack)
    if TableLib.isEmpty(config) or (not self:checkNetValid()) then
        -- 测速的地址配置为空或网络未连接，返回失败
        self:_notifyConnectResult(obj,callBack,false,{});
        return;
    end
    -- 测速前，先停止测速队列中正在进行的
    self:_stopAllTask();
    local temp = {};
    local isSucc;
    local index = 0;
    local size = #config;
    for k,v in ipairs(config) do
        if type(v) == "table" and v.ip and v.port then
            local task = tasklet.spawn(function(ip,port)
                local data = {ip = ip, port = port, ctime = Clock.system_now()}; -- ctime:毫秒
                local curSocket = Socket.connect(ip,port,{ timeout = SVR_LINK_TIME_OUT }); -- 设置连接超时时间5s
                index = index + 1;
                if curSocket then
                    if not isSucc then
                        -- 记录连接成功的状态
                        isSucc = true; 
                        -- 广播通知连接成功，当前有socket连接，直接关闭
                        self:_notifyConnected(obj,curSocket,ip,port);
                    else
                        curSocket:close();
                        curSocket = nil;
                    end
                    -- 记录socket的连接时间
                    data.ctime = Clock.system_now() - data.ctime;
                else
                    -- socket连接失败
                    data.ctime = CONNECT_TIME_OUT;
                end
                table.insert(temp,data); -- 记录测试结果
                if index == size then
                   self:_stopAllTask(); -- 停止协程队列
                    -- 链路测速完成，广播测速结果
                    self:_notifyConnectResult(obj,callBack,isSucc,temp);
                end
            end,v.ip,v.port);
            -- 记录队列
            local key = v.ip .. v.port;
            self.taskList[key] = {task = task, time = os.time()};
        end
    end
end

-- 测试特殊域名的连接
function VelocityBehavior:specialConnect(obj,config,callBack)
    if type(config) == "table" and config.ip and config.port then
        local task = tasklet.spawn(function(ip,port)
            local data = {ip = ip, port = port, ctime = Clock.system_now()};
            local curSocket = Socket.connect(ip,port,{ timeout = SVR_LINK_TIME_OUT }); -- 设置连接超时时间5s
            local isSucc = false;
            if curSocket then
                -- 连接成功
                curSocket:close();
                isSucc = true;
                data.ctime = Clock.system_now() - data.ctime;
            else
                data.ctime = CONNECT_TIME_OUT;
            end
            self:_notifyConnectResult(obj,callBack,isSucc,data);
        end,config.ip,config.port);
    end
end

-- 停止当前ip、port的协程
function VelocityBehavior:_stopTask(ip,port)
    local k = ip .. port;
    -- 每次测速后，删除无效的协程
    local _temp = {};
    for key,val in pairs(self.taskList) do
        if val then
            if key == k or os.time() - val.time > SVR_LINK_TIME_OUT then
                tasklet.cancel(val.task);
                val = nil;
            else
                _temp[key] = val;
            end
        end
    end
    self.taskList = _temp;
end

-- 停止所以有的协程队列
function VelocityBehavior:_stopAllTask()
    for k,v in pairs(self.taskList) do
        if v and v.task then
            tasklet.cancel(v.task);
        end
    end
    self.taskList = {};
end

-- 停止当前正在测速的所有请求
function VelocityBehavior:finishCurConnect()
    self:_stopAllTask();
end

-- 链路测试连接成功的广播通知
function VelocityBehavior:_notifyConnected(obj,curSocket,...)
    self:_showLog("VelocityBehavior:_notifyConnected----------");
    self:callBackParent(obj,"connectSuccess",curSocket,...);
end

-- 链路连接结果，回调
function VelocityBehavior:_notifyConnectResult(obj,func,result,data)
    self:_showLog("VelocityBehavior:_notifyConnectResult----------",func,result,data);
    self:callBackParent(obj,func,result,data);
end

-- 回调父类的方法
function VelocityBehavior:callBackParent(obj,func,...)
    if obj then
        if type(obj[func]) == "function" then
            obj[func](obj,...);
        else
            assert(obj.func,"父类必须实现函数:" .. func);
        end
    end
end

return VelocityBehavior;