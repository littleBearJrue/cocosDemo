
--require "dev.demo.include.XGConst"


local BaseServer = class("BaseServer")

function BaseServer:ctor(nNetSocketId,  sServerAddr ,nServerPort)
	self.m_sServerAddr = sServerAddr
	self.m_serverPort = nServerPort
end

function BaseServer:decodeMsg(msgType,msgSize,msgData)

end

function BaseServer:parseMsg(msgType,msgSize,msgData)

end

function BaseServer:onNetEventHandler(nEventId, pEventArg)

    print("BaseServer:onNetEventHandler")
	
	if VXSOCKET_EVENT_CONNECT_BEGIN == nEventId then
		--{
			self.m_nServerStatus = XG_SERVER_STATUS_CONNECTING;
			self:onConnectBegin(pEventArg);
		--}
		--break;
	elseif VXSOCKET_EVENT_CONNECT_FAILED == nEventId then
		
			self.m_nServerStatus = XG_SERVER_STATUS_DISCONNECT
			self:onConnectFailed(pEventArg);
	elseif VXSOCKET_EVENT_CLOSED == nEventId then

			self.m_nServerStatus = XG_SERVER_STATUS_DISCONNECT
			self:onDisconnect(pEventArg)
	elseif VXSOCKET_EVENT_CONNECT_COMPLETE == nEventId then

			self.m_nServerStatus = XG_SERVER_STATUS_CONNECTED
			self:onConnectComplete(pEventArg)
    end

	LogicSys:onEvent(LogicEvent.EVENT_SERVER_STATUS,self.m_nNetSocketId,self.m_nServerStatus)
end

function BaseServer:connect()
	NativeCall.lcc_connectToServer(self.m_nNetSocketId,self.m_sServerAddr,self.m_serverPort)
end

function BaseServer:disconnect()

	NativeCall.lcc_disconnectToServer(self.m_nNetSocketId)
	
	self.m_protocol = nil
end

function BaseServer:onConnectBegin(pEventArg)
end

function BaseServer:onConnectComplete(pEventArg)
	self.m_protocol = Protocol:create()
end

function BaseServer:onConnectFailed(pEventArg)
	--LogicSys:onEvent(LogicEvent.EVENT_SERVER_CLOSE,self.m_nNetSocketId,self)
end

function BaseServer:onDisconnect(pEventArg)
	LogicSys:onEvent(LogicEvent.EVENT_SERVER_CLOSE,self.m_nNetSocketId,self)
end

local function _netEventAsyncCallback(pThis, nEventId, pEventArg)
end


function BaseServer:isDisconnect()

	return self.m_nServerStatus == XG_SERVER_STATUS_DISCONNECT
end

function BaseServer:isConnected()

	return self.m_nServerStatus == XG_SERVER_STATUS_CONNECTED
end

function BaseServer:isConnecting()

	return self.m_nServerStatus == XG_SERVER_STATUS_CONNECTING
end


return BaseServer