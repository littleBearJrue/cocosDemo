
local NetManager = class("NetManager")

function NetManager.getInstance()
	if not NetManager.s_instance then
		NetManager.s_instance = NetManager.create()
	end
	return NetManager.s_instance
end

function NetManager.release()

end

function NetManager:ctor()
	self.m_netServers = {}
end

function NetManager:dtor()
end

-- 监听socket连接状态
function NetManager:onNetEventHandler(nNetSocketId,nEventId, pEventArg)
	if self.m_netServers[nNetSocketId] then
		self.m_netServers[nNetSocketId]:onNetEventHandler(nEventId, pEventArg)
	end
end

-- 接收socket消息，通知对象处理
function NetManager:parseMsg(nNetSocketId,msgType,msgSize,msgData)
	if self.m_netServers[nNetSocketId] then
		self.m_netServers[nNetSocketId]:parseMsg(msgType,msgSize,msgData)
	end
end

-- 发送socket消息
function NetManager:sendMsgToCurServer(nNetSocketId,msgType,msgData)
	if self.m_netServers[nNetSocketId] then
		NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,msgType,msgData)
	end
end

-- 记录socket对象
function NetManager:addServer(nNetSocketId,server)
	self.m_netServers[nNetSocketId] = server
end

-- 是否socket对象
function NetManager:removeServer(nNetSocketId,server)
	self.m_netServers[nNetSocketId] = nil
end

return NetManager