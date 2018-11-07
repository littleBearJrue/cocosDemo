--[[--
下载cdn配置，一次socket连接的流程中，cdn只会更新一次。
优先通过CDN下载，如果失败再调用http地址直接下载一次，尽量保证配置能更新成功
这个类只处理下载逻辑，下载成功并且数据合法时，会通知数据刷新成功，否则会通知数据更新失败
@module serversDownload
@author FuYao
Date   2018-3-22
Last Modified time 2017-12-20 16:06:43
]]

-- 代理回调父类{"cdnDownCallBack"}
local function executeDelegate(delegate,func, ...)
    if delegate and func and delegate[func] and type(delegate[func]) == "function" then
    	return delegate[func](delegate, ...);
    end
end

-- 对外暴露的接口
local exportInterface = {
	"startDownload"; -- {url:下载地址,isForce:是否强制刷新} 下载cdn配置
	"resetStatus"; -- 重置状态
	"hasUpdate"; -- 当前cdn是否已经更新过了
};

local serversDownload = class();
serversDownload.className_ = "serversDownload"; --类名

function serversDownload:ctor(delegate,config)
	self:_init(delegate,config);
end

function serversDownload:dtor()
	self:_stopTask();
	self.delegate = nil;
end

function serversDownload:_init(delegate,config)
	self.delegate = delegate;
	self.socketConfig = config;
	assert(delegate.cdnDownCallBack,"父类必须实现cdnDownCallBack函数");
end

-- 响应外部调用的接口
-- funcName方法名
function serversDownload:requestInterface(funcName,...)
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
function serversDownload:_checkFunValid(funcName)
    for k, v in ipairs(exportInterface) do
        if v == funcName then
            return true;
        end
    end
end

-- 打印日志
function serversDownload:_showLog(...)
	if not self.socketConfig.debug then
        return;
    end
    Log.d(self.socketConfig.logFlag, ...);
end

-- 重置状态
function serversDownload:resetStatus()
	self.isNew = false;
end

-- 当前是否已经更新过了
function serversDownload:hasUpdate()
	return self.isNew;
end

-- 检查cnd是否可以下载
function serversDownload:_checkValid(url,isForce)
	local info = {url = url};
	if StringLib.isEmpty(url) then
		info.err = "download url is nil";
		self:_notifyResult(false,info,url);
		return false;
	end
	self:_showLog("================downloadConfig=========下载cdn配置：",url);
	-- 下载次数
	if self.isNew then
		-- cdn当前已经是最新的了，直接返回
		-- self.isNew = false;
		info.err = "cdn is new";
		self:_notifyResult(false,info,url);
		self:_showLog("================downloadConfig===============cdn当前已经是最新的了");
		return false;
	end
	if self.isDownloadIng then
		-- 防止重复请求
		self:_showLog("================downloadConfig===============防止重复请求");
		if (os.time() - self.downloadTime > self.socketConfig.HTTP_TIME_OUT) then
			-- 异常情况重置标记
			self.isDownloadIng = false;
		end
		info.err = "cdn is downloading";
		self:_notifyResult(false,info,url);
		return false;
	end
	return true;
end

-- 获取cdn的临时存储文件路径
function serversDownload:_getFilePath()
	local function checkeFolderValid(folder)
	    if not os.isexist(folder) then
	        os.mkdir(folder)
	    end
	end
	local inner_root = Application.instance():inner_root();
    local tmp = inner_root .. "cdn/"
    checkeFolderValid(tmp);
	tmp = tmp .. "json/";
	checkeFolderValid(tmp);
	-- 先删除本地文件
	tmp = tmp .. "hall_cdnConfig.json";
	return tmp;
end

-- 读取cdn文件
function serversDownload:_readFile(path,isRemove)
	local err = "";
	local result = false;
	local data = {};
	if os.isexist(path) then
		local hFile, err = io.open(path, "r");
	    if hFile and (not err) then
	        local josnText = hFile:read("*a");
	        io.close(hFile);
	        if not StringLib.isEmpty(josnText) then
	        	self:_showLog("serversDownload:startDownload---------josnText=",josnText)
	            local cdnConfig = json.decode(josnText);
	            if not TableLib.isEmpty(cdnConfig) then
	                -- 解析cdn配置
	                local fileVersion = NumberLib.valueOf(cdnConfig.version);
	                self:_showLog("CdnData:downloadConfig==========success");
	                local version = NumberLib.valueOf(executeDelegate(self.delegate,"getVersion"),-1);
	                if fileVersion > version then
	                	result = true;
	                	data = cdnConfig;
	                end
	            else
	            	-- 格式错误
	            	err = "下载的cdn格式错误";
	            end
	        else
	            -- 内容为空
	            err = "下载的cdn内容为空";
	        end
	    else
	    	-- 文件读取失败
	    	err = "下载的cdn文件读取失败";
	    end
	end

	-- 删除文件
	if isRemove and os.isexist(path) then
		os.remove(path); 
	end
    return result,data,err;
end

-- 下载cdn配置
-- @isForce：是否需要强制更新
function serversDownload:startDownload(url,isForce)
	if not self:_checkValid(url,isForce) then
		return;
	end
	local filePath = self:_getFilePath();
	local result,data,err = self:_readFile(filePath,true);
	if result then
		self:_notifyResult(result,data,url);
		return;
	end

	self.isDownloadIng = true;
	self.downloadTime = os.time(); -- 下载时间
	local onComplete = function(requestInfo,result,rsp)
			httpObj = nil;
			self.isDownloadIng = false;
			self:_stopTask();
			local info = requestInfo;
			local isSucc = false;
			self:_showLog("serversDownload:startDownload---------",rsp)
		    if result and rsp.code == 200 then
		    	-- 读取cdn文件
		    	local result,data,err = self:_readFile(filePath);
				if result then
					self.isNew = true;
					isSucc = true;
		            self:_notifyResult(isSucc,data,requestInfo.url);
					return;
				else
					info.err = err or "下载的cdn读取异常";
				end
		    else
		    	-- 下载失败
		    	info.err = rsp;
		    end
		    self:_notifyResult(isSucc,info,url);
		end
	local httpObj = HttpManager:downloadFile(url,filePath,
		onComplete,{
			timeout = self.socketConfig.HTTP_TIME_OUT;
			progressCallBack = function(progress,requestInfo)
				-- 进度
			end
		});
	
	-- 启动下载超时计时器
	self:_stopTask();
	self.task = tasklet.spawn(function( ... )
		tasklet.sleep(self.socketConfig.HTTP_TIME_OUT);
		self:_showLog("cdn下载超时");
		if httpObj and type(httpObj.cancel) == "function" then
			-- 停止http服务
			httpObj:cancel();
			httpObj = nil;
		end
		local info = {url = url,err = "下载超时"};
        self:_notifyResult(false,info);
    end);
end

-- 停止http下载的超时计时器
function serversDownload:_stopTask()
	if self.task then
		tasklet.cancel(self.task);
		self.task = nil;
	end
end

-- cdn更新结果通知
function serversDownload:_notifyResult(result,info,url)
	self:_stopTask();
	self.isDownloadIng = false;
	executeDelegate(self.delegate,"cdnDownCallBack",result,info,url);
end

return serversDownload;