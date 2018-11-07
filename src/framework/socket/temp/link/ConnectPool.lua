--[[ 
    这个类只是做连接地址的记录，不做其它逻辑处理!!!
    记录server当前连接池的信息，每个尝试连接socket的地址都会加入连接池中
    连接测试的结果，成功、失败、连接时间都会记录下来
    当服务器连接地址配置刷新时，先把连接情况同步到新配置中再清空连接池队列
    一次socket连接流程结束时，清空连接池，并且把连接情况同步到CDN配置中
@module ConnectPool
@author FuYao
Date   2018-7-20
Last Modified time 2017-12-20 16:06:43
]]


-- 暴露给外部的接口
local exportInterface = {
    "addToPool"; -- 加入连接池
    "updatePool"; -- 更新连接池数据
    "getPoolList"; -- 获取连接池队列
};

local ConnectPool = class();
ConnectPool.className_ = "ConnectPool";--类名

function ConnectPool:ctor(config)
    self:_init(config);
end

function ConnectPool:dtor()

end

function ConnectPool:_init(config)
    self.socketConfig = config;
	self.poolList = {}; -- 连接池队列
end

-- 响应外部调用的接口
-- funcName方法名
function ConnectPool:requestInterface(funcName,...)
    if self:checkFunValid(funcName) then
        if self[funcName] then
            return self[funcName](self,...);
        else
            error("不存在接口：" .. funcName);
        end
    else
        error("接口未开放给外部使用：" .. funcName);
    end
end

-- 检查调用的接口是否为开放给外部使用的
function ConnectPool:checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

-- 打印日志
function ConnectPool:_showLog(...)
    if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end
----------------------------------------------------------------------------
-- 连接地址添加到连接池中
function ConnectPool:addToPool(data)
    data = checktable(data);
    for k, v in pairs(data) do
        if type(v) == "table" and v.ip and v.port then
            local key = v.ip .. v.port;
            local temp = { ip = v.ip, port = v.port};
            self.poolList[key] = temp;
        end
    end
end

-- 列表按照连接时间从小到大排序
function ConnectPool:_orderByCtime(data)
    data = checktable(data);
    local function order(a,b)
        if a and b then
            a.ctime = NumberLib.valueOf(a.ctime);
            b.ctime = NumberLib.valueOf(b.ctime);
            if a.ctime < b.ctime then
                return true;
            end
        end
    end
    table.sort(data,order);
end

-- 连接测试结果后，更新连接池的数据
function ConnectPool:updatePool(data)
    data = checktable(data);
    for k, v in pairs(data) do
        if type(v) == "table" and v.ip and v.port then
            local key = v.ip .. v.port;
            local temp = self.poolList[key];
            if temp then
                temp.ctime = v.ctime;
            else
                self.poolList[key] = v;
            end
        end
    end
    self:_orderByCtime(self.poolList);
    self:_showLog("ConnectPool:updatePool------------",self.poolList)
end

-- 获取当前的连接池数据
function ConnectPool:getPoolList(num)
    num = NumberLib.valueOf(num,1000000);
    if num > 0 then
        local temp = {};
        for k, v in pairs(self.poolList) do
            if #temp < num then
                table.insert(temp,v);
            else
                break;
            end
        end
        self.poolList = {}; -- 清空数据
        return temp;
    else
        return {};
    end
end

return ConnectPool;