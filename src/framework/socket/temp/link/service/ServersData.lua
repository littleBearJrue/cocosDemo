--[[
服务器连接地址数据管理，配置永久存储、获取、更新
@module ServersData
@author FuYao
Date   2018-3-22
Last Modified time 2017-12-20 16:06:43
]]

-- 代理回调父类{"reportData","cdnDownCallBack","getPoolList"}
local function executeDelegate(delegate,func, ...)
    if delegate and func and delegate[func] and type(delegate[func]) == "function" then
    	return delegate[func](delegate, ...);
    end
end

local data = import("BYKit.data");
local Dict = data.Dict;
local DataBase = data.DataBase;

local tableinsert = table.insert;


local serversDownload = require("link.service.serversDownload");

local ServersData = class(DataBase);

ServersData.className_ = "ServersData";--类名
BehaviorExtend(ServersData);

local exportInterface = {
	"downloadCdn"; -- {isForce}下载cnd配置
	"updateConfig"; -- {config}更新cdn配置
	"getBestDomain"; -- {num}获取最优地址
	"getDomains"; -- {num}获取域名地址
	"getIPs"; -- {num}获取ip地址
	"getHostUrl"; -- 获取业务主机地址
	"finishCurConnect"; -- 结束当前的连接操作
	"hasUpdate"; -- cdn是否已经更新过了
};

function ServersData:ctor(delegate,config)
	self:_init(delegate,config);
end

function ServersData:dtor()
	self.delegate = nil;
	delete(self.download);
	self.download = nil;
	
end

function ServersData:_init(delegate,config)
	self.socketConfig = config;
	assert(delegate.reportData,"父类必须实现reportData函数");
	assert(delegate.cdnDownCallBack,"父类必须实现cdnDownCallBack函数");
	assert(delegate.getPoolList,"父类必须实现getPoolList函数");

	self:_setLocalDictName(config.cdnFileName or ServersData.className_);
	self.reportType = self.socketConfig.reportType;

	self.delegate = delegate;
	self.download = new(serversDownload,self,self.socketConfig);
	
	local behaviors = checktable(self.socketConfig.behaviorConfig);
    local bevMap = checktable(behaviors.cdndata);
    for k,v in pairs(bevMap) do
        if typeof(v,BehaviorBase) then
            self:bindBehavior(v);
        else
            g_UICreator:createToast({text = "ServersData中组件定义错误"})
            error("ServersData中组件定义错误")
        end
    end

	self:_initData();
	self:_startTasklet("_loadDictData");
end

-- 获取dict对象
function ServersData:getDict()
	local dictName = self:_getLocalDictName();
	if not dictName then
		return;
	end
	if not self.dictData then
		self.dictData = new(Dict,dictName);
	end
	return self.dictData;
end

-- 设置持久化存储的文件名
function ServersData:_setLocalDictName(name)
	self.m_localDictName = name;
end

function ServersData:_getLocalDictName()
	return self.m_localDictName;
end

-- 读取文件内容
function ServersData:_loadDictData()
	local dict = self:getDict();
	if dict then
		dict:load();
	    self.socketAdd = dict.socketAdd or {};
	    self.httpAdd = dict.httpAdd or {};
	    self.cdnAdd = dict.cdnAdd or {};
	    self.bestDomain = dict.best;
	    self.version = dict.version or -1;
	end
	-- 读取默认配置
	self:_showLog("ServersData._loadDictData-------------------",self.socketAdd)
	if TableLib.isEmpty(self.socketAdd) then
		self:_initDefaultData();
	end
end

-- 默认数据
function ServersData:_initDefaultData()
	local default = self:getDefaultConfig(); -- 调用组件的方法
	local data = default;
	self:_showLog("ServersData._initDefaultData-------------------",default)
    if not TableLib.isEmpty(data) then
    	self:_analysis(data);
    end
end

-- 保存内容到文件
function ServersData:_saveDictData()
	local dict = self:getDict();
	if dict then
		dict:clear(); -- 先清空文件
	    dict.socketAdd = self.socketAdd;
	    dict.httpAdd = self.httpAdd;
	    dict.cdnAdd = self.cdnAdd;
	    dict.best = self.bestDomain;
	    dict.version = self.version;
	    self:_showLog("ServersData._saveDictData-------------------",self.socketAdd)
	    dict:save();
	end
end

-- 调用协程去处理某个方法
function ServersData:_startTasklet(func)
	tasklet.spawn(function()
		if self[func] then
			self[func](self);
		end
	end);
end

-- 响应外部调用的接口
-- funcName方法名
function ServersData:requestInterface(funcName,...)
	if self:_checkFunValid(funcName) then
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
function ServersData:_checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

-- 打印日志
function ServersData:_showLog(...)
	if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end

-- socket地址、http地址、配置下载地址
function ServersData:_initData()
	self.socketAdd = {}; -- socket 地址，按照连接时倒序排列
	self.httpAdd = {}; -- 业务的http的连接地址	
	self.cdnAdd = {}; -- cdn的下载地址
	self.best = {}; -- 最优链路
	self.version = -1; -- 版本号
	self:log("ServersData---------------_initData")
end

-- 列表按照连接时间从小到大排序
function ServersData:_orderByCtime(data)
	data = checktable(data);
	local function order(a,b)
		if a and b then
			a.ctime = NumberLib.valueOf(a.ctime,self.socketConfig.CONNECT_DEFAULT_TIME);
			b.ctime = NumberLib.valueOf(b.ctime,self.socketConfig.CONNECT_DEFAULT_TIME);
			if a.ctime < b.ctime then
				return true;
			end
		end
	end
	table.sort(data,order);
end

-- 解析cdn配置
function ServersData:_analysis(config)
	self:getAnalysisData(config);
	local main = self:_checkDomainValid(config.main);
    local backup = self:_checkDomainValid(config.backup); 
	local php = checktable(config.http); 
	local cdn = checktable(config.cdn);
	self.version = NumberLib.valueOf(config.version,-1); -- cdn版本号
	if not TableLib.isEmpty(main) then
		-- 解析地址 {main,backup, php, cdn}
		self:_merge(main,backup); -- 数据合并
		self.socketAdd = main;
		self.socketAdd = self:__generateRandomIpSequence(self.socketAdd); -- 随机打乱顺序，这样每个用户连接的地址就能尽量平均，不会大部分的用户都连接到同一个地址上，增加服务器处理压力
		self:_synPoolInfo(); -- 同步连接池的数据
		self:_orderByCtime(self.socketAdd); -- 按照连接的时间倒序排列，上一次连接失败的数据排在最后
	end
	if not TableLib.isEmpty(php) then
		-- 更新业务的主机地址
		self.httpAdd = php;
	end
	if not TableLib.isEmpty(cdn) then
		-- 更新cdn的下载地址
		self.cdnAdd = cdn;
	end
	-- 保存数据
	self:_startTasklet("_saveDictData");
	self:_showLog("ServersData._analysis-------------------CDN更新成功")
end

-- 校验域名信息是否合法
function ServersData:_checkDomainValid(info)
	info = checktable(info);
    local temp = {};
    for k,v in pairs(info) do 
        if v.ip and v.port then
            tableinsert(temp,v);
        end
    end
    return temp;
end

-- 同步连接池的数据
function ServersData:_synPoolInfo()
	local poolList = executeDelegate(self.delegate,"getPoolList");
	self:_showLog("ServersData:_synPoolInfo-----",poolList)
	for k,v in ipairs(self.socketAdd) do
	    -- 同步连接队列中的测速时间
		for _, val in pairs(poolList) do
			if v and val and v.ip == val.ip and v.port == val.port then
				v.ctime = val.ctime;
				break;
			end
		end
	end
end

--@brief 生成随机序列
function ServersData:__generateRandomIpSequence(config)
    if TableLib.isEmpty(config) then
        return {};
    end
    local newConfig = {};
    local count = #config;
    for i = 1, count do
    	local index = math.random(#config);
        local temp = table.remove(config, index);
        table.insert(newConfig,temp)
    end
    return newConfig;
end

-- 获取cdn的下载地址
function ServersData:_getCdnUrl()
	if TableLib.size(self.cdnAdd) > 0 then
		local data = table.remove(self.cdnAdd,1);
		table.insert(self.cdnAdd,data);
		return data.url;
	else
		return "http://192.168.200.21/dfqp_cdn/hall.json";
	end
end

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- 获取业务主机地址
function ServersData:getHostUrl()
	if TableLib.size(self.httpAdd) > 0 then
		local config = table.remove(self.httpAdd,1);
		table.insert(self.httpAdd,config);
		return config.url;
	else
		return ""
	end
end

-- 获取最优选择链路地址
function ServersData:getBestDomain(num)
	num = NumberLib.valueOf(num,1);
	local temp = {};
	self:_showLog("ServersData-----------------------getBestDomain",num)
	-- 优先重连接池中获取已经连接过的最优地址
	if self.bestDomain and self.bestDomain.ip and self.bestDomain.port then
		table.insert(temp,self.bestDomain);
		local size = #temp;
		if size < num then -- 补充数据
			local data = self:_getAddress(num - size);
			self:_merge(temp,data);
		end
	else
		-- 没有最优链路，顺序获取num个域名地址
		temp = self:_getAddress(num);
	end
	return temp;
end

-- 获取num个域名地址
function ServersData:getDomains(num)
	num = NumberLib.valueOf(num,1);
	self:_showLog("ServersData-----------------------getDomains",num)
	return self:_getAddress(num,true);
end

-- 获取num个ip地址
function ServersData:getIPs(num)
	num = NumberLib.valueOf(num,1);
	self:_showLog("ServersData-----------------------getIPs",num)
	return self:_getAddress(num,false);
end

--[[
	获取需要连接的地址
	num：需要获取的数量
	isDomain: true：获取域名地址；false：获取ip地址，nil：顺序获取num个地址
]]
function ServersData:_getAddress(num,isDomain)
	local function getAddress(num,isDomain)
		local temp = {};
		local i = 1
		while i <= #self.socketAdd do
			if #temp < num then
				local isAdd = false;
			    if self.socketAdd[i] then
					local data = self.socketAdd[i];
					local curIsDomain = self:__isDomain(data.ip)
					if isDomain == true and curIsDomain then
						isAdd = true; -- 获取域名地址
					elseif isDomain == false and (not curIsDomain) then
						isAdd = true; -- 获取ip地址
					elseif isDomain == nil then
						-- 顺序获取num个地址
						isAdd = true;								
					end
					if isAdd then
						table.insert(temp,table.remove(self.socketAdd,i));
					else
						i = i + 1;
					end
				else
					break;
				end
			else
				break;
			end
		end
		return temp;
	end	
	
	local data = getAddress(num,isDomain);
	if #data < num then
		-- 地址不够，其它类型补充
		local info = {};
		if isDomain == nil then
			info = getAddress(num);
		else
			info = getAddress(num,(not isDomain));
		end
		
		self:_merge(data,info);
	end
	return data;
end

-- ip是否为域名
function ServersData:__isDomain(ip)
	local domain = string.gsub(ip,"%.","");
	local arr = StringLib.toCharArray(StringLib.trim(domain));
	local value = table.concat(arr);	
	local isDomain = true;
	if tonumber(value) then
		isDomain = false;
	end
	return isDomain;
end

-- tb2的数据合并到tb1中
function ServersData:_merge(tb1,tb2)
	if tb1 and tb2 then
		for k,v in ipairs(tb2) do 
			table.insert(tb1,v);
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- 结束当前的连接操作
function ServersData:finishCurConnect()
	-- 连接池数据更新
	local poolList = executeDelegate(self.delegate,"getPoolList");
	if not TableLib.isEmpty(poolList) then
		self:_orderByCtime(poolList);
		local data = poolList[1];
		if data and data.ctime and data.ctime < self.socketConfig.CONNECT_TIME_OUT then
		    -- 保存最优连接记录
			self.bestDomain = data;
		end
		self:_merge(self.socketAdd,poolList);
		self:_orderByCtime(self.socketAdd);
		self:_startTasklet("_saveDictData");
	end

	self.download:requestInterface("resetStatus");
end

-- cnd配置是否已经更新过了
function ServersData:hasUpdate()
	return self.download:requestInterface("hasUpdate");
end

-- 下载cdn配置
function ServersData:downloadCdn(isForce)
	self.isHttpDownload = false;
	local url = self:_getCdnUrl();
	self.download:requestInterface("startDownload",url,isForce);
end

-- cdn配置更新结果
function ServersData:cdnDownCallBack(result,data,url)
	
	if result == true then
		self.isHttpDownload = false;
		-- 上报cdn下载的日志
		local msg = {
			result = result;
			data = {url = url};
		};
		local temp = {reportType = self.reportType.CDN; info = msg};
		executeDelegate(self.delegate,"reportData",temp);
		
		-- 更新成功，刷新数据
		self:_analysis(data);
		-- 通知调用层，重新打开socket
		executeDelegate(self.delegate,"cdnDownCallBack",result,data);
	else
		-- g_UICreator:createToast({text = "cdn更新失败1"})
		local msg = { result = result; data = data; };
		local temp = {reportType = self.reportType.CDN; info = msg};
		executeDelegate(self.delegate,"reportData",temp); -- 上报cdn下载的日志
		if self.isHttpDownload then
			self:_showLog("ServersData:cdnDownCallBack----------------------");
			-- cnd和http更新都失败了，通知调用层，更新失败。弹框提示掉线
			executeDelegate(self.delegate,"cdnDownCallBack",result,data);
			self.isHttpDownload = false;
			return;
		end
		-- cdn更新失败，调用http地址直接下载
		self.isHttpDownload = true;
		local url = self:getHostUrl();
		self.download:requestInterface("startDownload",url);
	end
end

-- 更新cdn配置
function ServersData:updateConfig(config)
	self:_analysis(config);
end

-- 获取配置版本号
function ServersData:getVersion()
	return self.version or -1;
end

function ServersData:log(tag,...)
	-- self:_showLog(self.sType,tag,...)
end

return ServersData;