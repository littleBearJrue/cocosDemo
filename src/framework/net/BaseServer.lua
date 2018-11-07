
local BaseServer = class("BaseServer")

function BaseServer:ctor(nNetSocketId)
	self.m_nNetSocketId = nNetSocketId; -- 服务id
	self.m_nServerStatus = SERVER_STATUS_NON; -- 初始状态
end

-- 请求连接socket
function BaseServer:connect(ip,port)
	NativeCall.lcc_connectToServer(self.m_nNetSocketId,ip,port)
end

-- 断开连接
function BaseServer:disconnect()
	-- print(self.m_nNetSocketId,"BaseServer:disconnect")
	NativeCall.lcc_disconnectToServer(self.m_nNetSocketId)
end

-- socket连接状态回调
function BaseServer:onNetEventHandler(nEventId, pEventArg)
    print(nEventId,"socket连接状态回调--BaseServer:onNetEventHandlernEventId=")
	if SERVER_STATUS_CONNECTING == nEventId then -- 0
		-- 开始连接socket
		self.m_nServerStatus = SERVER_STATUS_CONNECTING;
		self:onConnectBegin(g_event.SOCKET_EVENT_CONNECT_BEGIN,pEventArg);
	elseif SERVER_STATUS_CONNECTFAIL == nEventId then -- 2
		-- socket连接失败
		self.m_nServerStatus = SERVER_STATUS_CONNECTFAIL
		self:onConnectFailed(g_event.SOCKET_EVENT_CONNECT_FAILED,pEventArg);
	elseif SERVER_STATUS_DISCONNECT == nEventId then -- 3
		-- 关闭socket
		self.m_nServerStatus = SERVER_STATUS_DISCONNECT
		self:onDisconnect(g_event.SOCKET_EVENT_CLOSED,pEventArg);
	elseif SERVER_STATUS_CONNECTED == nEventId then -- 1
		-- socket连接成功
		self.m_nServerStatus = SERVER_STATUS_CONNECTED
		self:onConnectComplete(g_event.SOCKET_EVENT_CONNECT_COMPLETE,pEventArg);
    end
end

-- 开始连接
function BaseServer:onConnectBegin(nEventId,pEventArg)
end

-- 连接完成
function BaseServer:onConnectComplete(nEventId,pEventArg)
end

-- 连接失败
function BaseServer:onConnectFailed(nEventId,pEventArg)
	--LogicSys.onEvent(LogicEvent.EVENT_SERVER_CLOSE,self.m_nNetSocketId,self)
end

-- 关闭连接
function BaseServer:onDisconnect(nEventId,pEventArg)
	-- LogicSys.onEvent(LogicEvent.EVENT_SERVER_CLOSE,self.m_nNetSocketId,self)
end

-- 连接是否失败
function BaseServer:isConnectFail()
	return self.m_nServerStatus == SERVER_STATUS_CONNECTFAIL
end

-- 连接是否关闭
function BaseServer:isDisconnect()
	return self.m_nServerStatus == SERVER_STATUS_DISCONNECT
end

-- 是否已经连接成功
function BaseServer:isConnected()
	dump(self.m_nServerStatus,"self.m_nServerStatus")
	return self.m_nServerStatus == SERVER_STATUS_CONNECTED
end

-- 是否正在连接中
function BaseServer:isConnecting()
	return self.m_nServerStatus == SERVER_STATUS_CONNECTING
end

-- 获取连接状态
function BaseServer:getStatus()
	return self.m_nServerStatus
end

-- 封装数据包
function BaseServer:decodeMsg(msgType,msgSize,msgData)

end

-- 发送socket消息
function BaseServer:sendMsg(cmd,data)
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,cmd,data)
end

--[[
解析数据包，C++回调
	@msgType：消息类型，等同命令字
	@msgSize：消息长度
	@msgData：消息内容
]]
function BaseServer:parseMsg(msgType,msgSize,msgData)

end

return BaseServer