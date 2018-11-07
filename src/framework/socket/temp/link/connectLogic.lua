--[[
	socket连接逻辑，处理socket的连接的逻辑
	1. 如果本地没有最优纪录，随机一个域名
	2. 如果域名连上了，则继续，后台测速剩下4个域名，然后记录下来，第二次连的时候用最优的，如果剩下的4个域名都没连上，则测速剩下的5个IP，记录下来。
	3. 如果域名没有连上，5s超时了。那么后台起独立线程，随机2个域名，3个IP，连上哪个算哪个，连上了再回到2。
	4. 如果3没有连上，这个时候过去了10s，去http服务器上取一份新的配置下来。去掉之前3中上一次不可达的域名，IP,（剩下的list中至少还有一个域名或IP）更新配置继续走 1
	5. 每次启动后，都去http服务器拉下时间戳看看是否有新的配置，如果有了更新本地
	6. 每次连上后，svr端都有一个校验请求，校验是否立刻马上更新最新配置，如果有，马上更新配置再走1
	7. 每次连上后，上报连上clientIP，server域名或IP，测速结果，方便分析
	8. 所有的域名和IP均是后台lvs虚拟ip，不再是真实access IP，方便运维切换流量
@module ConnectLogic
@author FuYao
Date   2018-7-20
Last Modified time 2018-7-20 16:06:43
]]

-- 代理回调父类{"onSocketConnected","onSocketConnectFailed","isConnected"}
local function executeDelegate(delegate,func, ...)
    if delegate and func and delegate[func] and type(delegate[func]) == "function" then
    	return delegate[func](delegate, ...);
    end
end

local ServersData = require("link.service.ServersData"); -- cdn接口类
local connectPool = require("link.ConnectPool"); -- 连接池

-- 暴露给外部的接口
local exportInterface = {
    "requestOpenSocket"; -- 请求打开socket，
    "reConnectSocket"; -- 重连socket，掉线或心跳超时调用
    "reportData"; -- 数据上报
};

local ConnectLogic = class();
ConnectLogic.className_ = "ConnectLogic";--类名
BehaviorExtend(ConnectLogic);

local FIRST_CONNECT_NUM = 1; -- 当前首次连接时，用1个域名连接

local FIRST_CONNECT_SUC_DOMAIN_NUM = 4; -- 当前首次连接成功后，用4个域名测速

local FIRST_CONNECT_SUC_VEL_FAIL_IP_NUM = 5; -- 当前首次连接成功后，用4个域名测速失败，再次用5个IP测速

local FIRST_CONNECT_FAIL_DOMAIN_NUM = 2; -- 当前首次连接失败后，用2个域名测速
local FIRST_CONNECT_FAIL_IP_NUM = 3; -- 当前首次连接失败后，用3个IP测速

local RECONNECT_DOMAIN_NUM = 3; -- 静默重连。获取3个最优地址连接

function ConnectLogic:ctor(delegate,config)
	self:_init(delegate,config);
end

function ConnectLogic:dtor(delegate)
	self:unBindAllBehavior(); -- 删除绑定的组件
	self.delegate = nil;
	local tb = {self.serversData,self.connectPool};
	for k,v in pairs(tb) do 
		if v then
			delete(v);
			v = nil;
		end
	end
	tb = nil;
end

function ConnectLogic:_init(delegate,config)
	self.socketConfig = config;
	assert(delegate.onSocketConnected,"父类必须实现onSocketConnected函数");
	assert(delegate.onSocketConnectFailed,"父类必须实现onSocketConnectFailed函数");
	self.delegate = delegate;
	self.reportType = self.socketConfig.reportType;
	self.connectPool = new(connectPool,self,self.socketConfig);
	self.serversData = new(ServersData,self,self.socketConfig);

    -- 绑定定义的组件
	local behaviors = checktable(self.socketConfig.behaviorConfig);
    local bevMap = checktable(behaviors.connect);
    for k,v in pairs(bevMap) do
        if typeof(v,BehaviorBase) then
            self:bindBehavior(v);
        else
            g_UICreator:createToast({text = "ConnectLogic中组件定义错误"})
            error("ConnectLogic中组件定义错误")
        end
    end
end

-- 响应外部调用的接口
-- funcName方法名
function ConnectLogic:requestInterface(funcName,...)
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
function ConnectLogic:_checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

-- 打印日志
function ConnectLogic:_showLog(...)
	if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end

-- 检查网络是否可用
function ConnectLogic:_checkNetValid()
    if DevicePlugin:isNetworkConnected() then -- 有网络
    	return true;
    else
    	self:_openNetworkSetting();
    	return false;
    end
end

-- 打开网络设置
function ConnectLogic:_openNetworkSetting()
	local isConnected = executeDelegate(self.delegate,"isConnected");
	if isConnected then
		-- 当前socket已经连接，return
	else
		-- socket未连接，提示掉线，重新登录
		g_UICreator:createToast({text = "网络未连接，请检查您的网络"})
 		-- self:_finishCurConnect();
		-- executeDelegate(self.delegate,"onSocketConnectFailed");
	end
end

-- 获取最优地址
function ConnectLogic:_getBestDomain(num)
	num = NumberLib.valueOf(num,1);
	-- 从cdn配置中获取地址，没有最优时，随机获取一个域名
	return self.serversData:requestInterface("getBestDomain",num);
end

-- 获取num个域名地址
function ConnectLogic:_getDomains(num)
	num = NumberLib.valueOf(num,1);
	return self.serversData:requestInterface("getDomains",num);
end

-- 获取num个ip地址
function ConnectLogic:_getIPs(num)
	num = NumberLib.valueOf(num,1);
	return self.serversData:requestInterface("getIPs",num);
end

-- tb2的数据合并到tb1中
function ConnectLogic:_merge(tb1,tb2)
	if tb1 and tb2 then
		for k,v in ipairs(tb2) do 
			table.insert(tb1,v);
		end
	end
end

-- 当前连接流程结束
function ConnectLogic:_finishCurConnect()
	self:_showLog("ConnectLogic:_finishCurConnect--------------当前连接流程结束")
	self:_onVelocityBehavior("finishCurConnect"); -- 通知连接池流程结束，停止当前所有的连接请求
	self.serversData:requestInterface("finishCurConnect"); -- 重置cdn相关状态信息

	-- 当前流程测试结束时，获取配置的特殊域名进行速度验证
	self:_onVelocityBehavior("specialConnect",self.socketConfig.specialDaomain,"specialConnectCallBack");
end

-- 调用网络测速类的组件接口
function ConnectLogic:_onVelocityBehavior(func,domains,...)
	if self:_checkNetValid() then
		self.connectPool:requestInterface("addToPool",domains); -- 记录到连接队列中
		if type(self[func]) == "function" then
	        self[func](self,domains,...)
	        return true;
	    else
	    	error("socket的链路连接组件不存在方法:" .. func)
	    end
	end
	return false;
end

-- 调用数据上报组件的方法
function ConnectLogic:_onReportBehavior(func,...)
	if type(self[func]) == "function" then
        self[func](self, ...);
    else
    	error("socket的数据组件不存在方法:" .. func)
    end
end

-- 更新cdn配置
function ConnectLogic:_updateCdnConfig(isForce)
	if self:_checkNetValid() then
		if isForce then
			self:_showLog("ConnectLogic---------------更新CDN配置");
			self.serversData:requestInterface("downloadCdn",isForce);
		else
			if self.serversData:requestInterface("hasUpdate") then
				-- cdn已经是最新的，停止当前流程
				self:_finishCurConnect();
				if not executeDelegate(self.delegate,"isConnected") then
					-- socket未连接，提示连接失败
					executeDelegate(self.delegate,"onSocketConnectFailed");
				end
			else
				self:_showLog("ConnectLogic---------------更新CDN配置");
				-- 更新CDN配置
				self.serversData:requestInterface("downloadCdn",isForce);
			end
		end
	else
		-- 当前没有网络
		self:cdnDownCallBack(false,{});
	end
end
--------------------------------------------------------------------------------------------------------
-------------------------------------------- socket连接 start------------------------------------------------------------
--[[
	连接流程中的首次打开socket
	num：连接的域名数量，默认为1
]]
function ConnectLogic:requestOpenSocket(ip,port)
	local domains = self:_getBestDomain(FIRST_CONNECT_NUM);
	if ip and port then
		domains = {
			[1] = {ip = ip,port = port};
		};
	end
	if TableLib.isEmpty(domains) then
		-- 请求cdn配置
		local temp = {reportType = self.reportType.ERROR;info = "domains is nil";};		
		self:reportData(temp);
		if self.serversData:requestInterface("hasUpdate") then
			-- cdn已经是最新配置
			if executeDelegate(self.delegate,"isConnected") then
				-- 当前连接成功
			else
				-- 提示连接失败
				executeDelegate(self.delegate,"onSocketConnectFailed");
			end
			-- 结束流程
			self:_finishCurConnect();
		else
			-- cdn更新成功后重新连接
			self:_updateCdnConfig();
		end
	else
		-- 连接
		self:_showLog("ConnectLogic:requestOpenSocket--------",domains)
		local result = self:_onVelocityBehavior("linkVelocity",domains,"firstConnect");
		if not result then
			-- 结束流程
			self:_finishCurConnect();
			-- 发送连接请求失败，提示网络连接失败
			executeDelegate(self.delegate,"onSocketConnectFailed");
		end
	end
end

-- 当前首次连接结果
function ConnectLogic:firstConnect(result,data)
	-- 记录连接日志
	local temp = {reportType = self.reportType.CONNECT;info = data};
	self:reportData(temp);
	self:_showLog("ConnectLogic:firstConnect",result)
	if result == true then
		-- socket已经连接成功，再获取4个域名进行网络测速
		local domains = self:_getDomains(FIRST_CONNECT_SUC_DOMAIN_NUM);
		self:_showLog("ConnectLogic:firstConnect-----------",domains)
		if TableLib.isEmpty(domains) then
			-- 本地配置不够，结束本次连接操作，后台请求cdn配置、
			self:_finishCurConnect();
			-- 请求cdn配置
			self:_updateCdnConfig();
		else
			-- 测速
			local result = self:_onVelocityBehavior("linkVelocity",domains,"firstConnectSucVelResult");
			if not result then
				-- 没有网络了，结束流程
				self:_finishCurConnect();
			end
		end
	else
		-- socket连接失败，获取2个域名+3个IP进行连接
		g_UICreator:createToast({text = "socket连接失败，正在努力尝试中..."})
		local domains = self:_getDomains(FIRST_CONNECT_FAIL_DOMAIN_NUM);
		local ips = self:_getIPs(FIRST_CONNECT_FAIL_IP_NUM);
		self:_merge(domains,ips);
		self:_showLog("ConnectLogic:firstConnect-首次连接失败，再次请求2个域名+3个IP进行连接----------",domains)
		if TableLib.isEmpty(domains) then
			-- 请求cdn配置
			self:_updateCdnConfig();
		else
			-- 连接
			local result = self:_onVelocityBehavior("linkVelocity",domains,"firstConnectFailVelResult");
			if not result then
				-- 没有网络了，结束流程
				self:_finishCurConnect();
				-- 发送连接请求失败，提示网络连接失败
				executeDelegate(self.delegate,"onSocketConnectFailed");
			end
		end
	end
end

-- 首次连接成功后，4个域名的网络测速结果
function ConnectLogic:firstConnectSucVelResult(result,data)
	-- 测试结果,记录连接日志		
	local temp = {reportType = self.reportType.CONNECT;info = data};
	self:reportData(temp);
	if result == true then
		-- 4个域名测速成功，结束流程
		self:_finishCurConnect();
	else
		-- 测速失败，再获取5个IP进行网络测速
		local domains = self:_getIPs(FIRST_CONNECT_SUC_VEL_FAIL_IP_NUM);
		if TableLib.isEmpty(domains) then
			-- 本地配置不够，结束本次连接操作
			self:_finishCurConnect();
			-- 请求更新cdn配置
			self:_updateCdnConfig();
		else
			-- 测速
			local result = self:_onVelocityBehavior("linkVelocity",domains,"firstConnectSucReVelResult");
			if not result then
				-- 没有网络了，结束流程
				self:_finishCurConnect();
			end
		end
	end
end

-- 测速失败，再获取5个IP进行网络测速
function ConnectLogic:firstConnectSucReVelResult(result,data)
	-- 记录连接日志
	local temp = {reportType = self.reportType.CONNECT;info = data};
	self:reportData(temp);
	-- 结束流程
	self:_finishCurConnect();
end


-- 首次连接失败后，获取2个域名+3个IP进行连接
function ConnectLogic:firstConnectFailVelResult(result,data)
	-- 记录连接日志
	self:_showLog("ConnectLogic:firstConnectFailVelResult","首次连接失败后，获取2个域名+3个IP进行连接",result)
	local temp = {reportType = self.reportType.CONNECT;info = data};
	self:reportData(temp);
	if result == true then
		-- socket连接成功，结束流程
		self:_finishCurConnect();
	else
		-- socket连接失败
		if self.serversData:requestInterface("hasUpdate") then
			-- cdn已经是最新配置，提示socket连接失败，等待用户下次操作
			self:_finishCurConnect();
			self:_showLog("ConnectLogic:firstConnectFailVelResult-----------连接失败");
			g_UICreator:createToast({text = "socket连接失败，请重新连接"})
		else
			self:_showLog("ConnectLogic:firstConnectFailVelResult---------------更新CDN配置");
			-- 更新CDN配置
			self:_updateCdnConfig();
		end
	end
end
--------------------------------------------------------------------------------------------------------
---------------------------------------------------socket连接 end-----------------------------------------------------

-----------------------------------------------------------------------------------------
-------------------------------------重连逻辑 start---------------------------------------------
--[[
	静默重连socket
	从最优队列中获取3个地址进行连接
]]
function ConnectLogic:reConnectSocket()
	local domains = self:_getBestDomain(RECONNECT_DOMAIN_NUM);
	if TableLib.isEmpty(domains) then
		-- 上报异常
		g_UICreator:createToast({text = "socket正在重连......"})
		local temp = {reportType = self.reportType.ERROR;info = "reconnect domains is nil";};		
		self:reportData(temp);
		-- 请求cdn配置，更新后重新连接
		self:_updateCdnConfig(true);
	else
		-- 连接
		local result = self:_onVelocityBehavior("linkVelocity",domains,"reConnectResult");
		if not result then
			-- 没有网络了，结束流程
			self:_finishCurConnect();
			-- 发送连接请求失败，提示网络连接失败
			executeDelegate(self.delegate,"onSocketConnectFailed");
		end
	end
end

-- 静默重连测试结果
function ConnectLogic:reConnectResult(result,data)
	-- 记录日志
	local temp = {reportType = self.reportType.CONNECT;info = data};
	self:reportData(temp);
	if result == true then
		-- 静默重连成功
		g_UICreator:createToast({text = "socket静默重连成功"});
		-- 结束当前流程
		self:_finishCurConnect();
	else
		-- 重连失败，提示正在重连中，重新请求连接
		g_UICreator:createToast({text = "socket正在重连......"})
		-- 请求cdn配置，更新后重新连接
		self:_updateCdnConfig(true);
	end
end
-----------------------------------------------------------------------------------------
--------------------------------------重连逻辑 end---------------------------------------------------


---------------------------------------------------------------------------------------------------
----------------------------------------- 回调方法 start----------------------------------------------------------

-- 链路测试成功的回调
function ConnectLogic:connectSuccess(connect,ip,port)
	if executeDelegate(self.delegate,"isConnected") then
		-- 当前socket已经连接
		connect:close();
		connect = nil;
	else
		-- 保存连接成功的socket		
		executeDelegate(self.delegate,"onSocketConnected",connect,ip,port);
	end
end

-- 记录特殊域名的测速结果
function ConnectLogic:specialConnectCallBack(result,data)
	local temp = {reportType = self.reportType.CONNECT;info = data};
	self:reportData(temp);
	self:_showLog("ConnectLogic:specialConnectCallBack",result,data)
end

-- cnd更新结果回调
function ConnectLogic:cdnDownCallBack(result,data)
	self:_showLog("ConnectLogic:cdnDownCallBack----------------------",result);
	local isConnected = executeDelegate(self.delegate,"isConnected");
	if result == true then
		if isConnected then
			-- cdn更新成功
		else
			-- 请求重新打开socket
			self:requestOpenSocket();
		end
	else
		g_UICreator:createToast({text = "cdn更新失败"})
		-- cdn更新失败
		if not isConnected then
			-- socket未连接，提示掉线，重新登录
			self:_finishCurConnect();
			executeDelegate(self.delegate,"onSocketConnectFailed");
			g_UICreator:createToast({text = "socket未连接，重新登录"})
		end
	end
end

-- 记录日志
function ConnectLogic:reportData(data,...)
	data = checktable(data);
	local info = data.info;
	if info then
		local conType = data.reportType or self.reportType.CONNECT;
		-- 调用数据上报组件的方法
		self:_onReportBehavior("addReportData",conType, info, ...);
		self.connectPool:requestInterface("updatePool", info, ...); -- 刷新地址的连接状态信息
	end
end

-- 获取连接池队列的数据
function ConnectLogic:getPoolList()
	return self.connectPool:requestInterface("getPoolList");
end

---------------------------------------------------------------------------------------------------
----------------------------------------- 回调方法 end----------------------------------------------------------
-- 重置
function ConnectLogic:reset()
	self:_finishCurConnect();
end

return ConnectLogic;