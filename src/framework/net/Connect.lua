local scheduler = cc.Director:getInstance():getScheduler()
local NetManager = require(".NetManager")
-- 代理回调父类{}
local function executeDelegate(delegate,func, ...)
    if delegate and func and delegate[func] and type(delegate[func]) == "function" then
        return delegate[func](delegate, ...);
    end
end

-- 对外暴露的接口
local exportInterface = {
	"requestConnect";
	"closeSocket";
	"isConnected";
	"sendMsg";
};

local BaseServer = require(".BaseServer");
local Connect = class("Connect",BaseServer)
BehaviorExtend(Connect);

function Connect:ctor(nNetSocketId,delegate)
	assert(nNetSocketId,"未设置nNetSocketId")
	BaseServer.ctor(self,nNetSocketId)
	self.nNetSocketId = nNetSocketId;
	self.delegate = delegate;
	NetManager.getInstance():addServer(self.nNetSocketId,self);

	self:bindBehavior(BehaviorMap.PublicBehavior); -- 绑定公共方法检测组件
	self:initPublicFunc(exportInterface); -- 设置公共方法

end

function Connect:requestConnect(ip,port)
	self:stopConnectScheduler();
	if g_stringLib.isEmpty(ip) or g_stringLib.isEmpty(port) then
		self:onConnectError(g_event.SOCKET_EVENT_CONNECT_ERROR);
		return;
	end
	self:connect(ip,port);
	local startTime = os.time();
	self.connectScheduler = scheduler:scheduleScriptFunc(function ( dt )
		if os.time() - startTime >= 5 then
			-- 超时
			self:onConnectTimeout(g_event.SOCKET_EVENT_CONNECT_TIMEOUT);
		end
	end,0,false)
end

-- 开始连接
function Connect:onConnectBegin(nEventId,pEventArg)
end

-- 连接完成
function Connect:onConnectComplete(nEventId,pEventArg)
	print("连接完成")
	self:notify(nEventId,pEventArg);
end

-- 连接失败
function Connect:onConnectFailed(nEventId,pEventArg)
	print("连接失败")
	self:notify(nEventId,pEventArg);
end

-- 成功关闭连接
function Connect:onDisconnect(nEventId,pEventArg)
	print("成功关闭连接")
	self:notify(nEventId,pEventArg);
end

-- 连接超时
function Connect:onConnectTimeout(nEventId,pEventArg)
	print("连接超时")
	self:notify(nEventId,pEventArg);
end

-- 连接错误
function Connect:onConnectError(nEventId,pEventArg)
	print("连接错误")
	self:notify(nEventId,pEventArg);
end

-- 关闭socket
function Connect:closeSocket()
	self:disconnect();
end

-- 停止计时器
function Connect:stopConnectScheduler()
	if self.connectScheduler then
		scheduler:unscheduleScriptEntry(self.connectScheduler)
	end
	self.connectScheduler = nil
end

-- 通知结构
function Connect:notify(nEventId,pEventArg)
	self:stopConnectScheduler();
	executeDelegate(self.delegate,"connectResult",self.nNetSocketId,nEventId,pEventArg);
end

function Connect:dtor()
	self.delegate = nil;
	NetManager.getInstance():removeServer(self.nNetSocketId,self)
	self:stopConnectScheduler();
end

return Connect;