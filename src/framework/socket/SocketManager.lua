
local socket = require "socket"
local net = import('framework.net');
local Connect = net.Connect;

-- 对外暴露的接口
local exportInterface = {
	"openSocket",
	"closeSocket",
	"sendMsg",
	"isConnected",
};

local SocketManager = class("SocketManager")
BehaviorExtend(SocketManager);


function SocketManager:ctor(netType)
   
    self.m_nNetSocketId = netType or NET_SOCKET_COMMON;
	self.socket = Connect:create(self.m_nNetSocketId,self);
	self:bindBehavior(BehaviorMap.PublicBehavior); -- 绑定公共方法检测组件
	self:initPublicFunc(exportInterface); -- 设置公共方法
end

function SocketManager:dtor()
	self:closeSocket()
end

-- 解析socket消息
function SocketManager:parseMsg(msgType,msgSize,msgData)

	-- local msgName = XGGameProtocol.getProtocolTypeName(msgType)
	-- local msg = protobuf.decode(msgName, msgData, msgSize) 


 --    if type(msg) =='table' then
 --        print("SocketManager:parseMsg success = " .. msgName.." msgSize="..msgSize)    
 --    else
 --        print("SocketManager:parseMsg fail = " .. msgName.." msgSize="..msgSize)    
 --    end
		
	-- XGNetSys.onEvent(msgType,msg)
end

-- 打开socket
function SocketManager:openSocket(ip,port)
	
	if not self:isConnected() then
		self.socket:requestInterface("requestConnect",ip,port);
	end
end

-- 关闭socket
function SocketManager:closeSocket()
	self.socket:requestInterface("closeSocket");
end

-- socket连接结果
function SocketManager:connectResult(type,eventId,info)
	dump("socket连接结束",eventId)
	g_eventDispatcher:dispatch(eventId,info);
end


-- 是否已经连接成功
function SocketManager:isConnected()
	return self.socket:requestInterface("isConnected")
end

-- 发送socket消息
function SocketManager:sendMsg(cmd,data)
	self.socket:requestInterface("sendMsg",cmd,data);
end


return SocketManager
