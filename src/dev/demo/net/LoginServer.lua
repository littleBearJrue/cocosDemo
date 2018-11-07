local BaseServer = require "dev.demo.net.BaseServer"
local Protocol = require "dev.demo.net.Protocol"



local LoginServer = class("LoginServer",BaseServer)


LoginServer.OperationType = 
{
		OPERATION_NONE = 0,
		OPERATION_LOGIN = 1,
		OPERATION_REGISTER = 2,
		OPERATION_MODIFY_PASSWORD =3,
		OPERATION_RETAKE_PASSWORD = 4,
		OPERATION_APPEAL_PASSWORD = 5,
		OPERATION_VERSION_CHECKING = 6,
		OPERATION_PAY_PLATFORM = 7,
};



function LoginServer:ctor()
   
    self.m_nNetSocketId = XG_NET_SOCKET_LOGIN
	LogicSys:regEventHandler(LogicEvent.EVENT_NET_LOGOUT_COMPLETED, self.onEventLogoutHandler, self)
	LogicSys:regEventHandler(LogicEvent.EVENT_NET_LAUNCH_VERSION_CHECK, self.onEventLaunchVersionCheckingHandler, self)
	LogicSys:regEventHandler(LogicEvent.EVENT_NET_LAUNCH_LOGIN, self.onEventLaunchLoginHandler, self)


	NetSys:regEventHandler(Protocol.getEventType("EGMI_ACK_LOGIN"), self.onEventProtocolLoginResponseHandler, self)
	NetSys:regEventHandler(Protocol.getEventType("EGMI_ACK_VERSION"), self.onEventProtocolVersionCheckResponseHandler, self)
	NetSys:regEventHandler(Protocol.getEventType("EGMI_ACK_WORLD_LIST"), self.onEventProtocolWorldListResponseHandler, self)
	NetSys:regEventHandler(Protocol.getEventType("EGMI_ACK_CONNECT_WORLD"), self.onEventProtocolConnectWorldResponseHandler, self)
	

	self.m_nOperationType = LoginServer.OperationType.OPERATION_NONE
end

function LoginServer:dtor()
    LogicSys:unregEventHandler(LogicEvent.EVENT_NET_LOGOUT_COMPLETED, self.onEventLogoutHandler, self)
    LogicSys:unregEventHandler(LogicEvent.EVENT_NET_LAUNCH_VERSION_CHECK, self.onEventLaunchVersionCheckingHandler, self)
	LogicSys:unregEventHandler(LogicEvent.EVENT_NET_LAUNCH_LOGIN, self.onEventLaunchLoginHandler, self)

	NetSys:unregEventHandler(Protocol.getEventType("EGMI_ACK_LOGIN"), self.onEventProtocolLoginResponseHandler, self)
	NetSys:unregEventHandler(Protocol.getEventType("EGMI_ACK_VERSION"), self.onEventProtocolVersionCheckResponseHandler, self)
	NetSys:unregEventHandler(Protocol.getEventType("EGMI_ACK_WORLD_LIST"), self.onEventProtocolWorldListResponseHandler, self)
	NetSys:unregEventHandler(Protocol.getEventType("EGMI_ACK_CONNECT_WORLD"), self.onEventProtocolConnectWorldResponseHandler, self)
	
end


function LoginServer:decodeMsg(msgType,msgSize,msgData)
	local msgBase = protobuf.decode("NFMsg.MsgBase", msgData,msgSize) 

	local msgName = Protocol.getProtocolTypeName(msgType)

	local msg = protobuf.decode(msgName, msgBase.msg_data,string.len(msgBase.msg_data)) 

	return msgBase,msg
end

function LoginServer:parseMsg(msgType,msgSize,msgData)

	local msgBase = protobuf.decode("NFMsg.MsgBase", msgData,msgSize) 

	local msgName = Protocol.getProtocolTypeName(msgType)
	local len = string.len(msgBase.msg_data)
	local msg = protobuf.decode(msgName, msgBase.msg_data,len) 


    if type(msg) =='table' then
        print("NetManager:parseMsg success = " .. msgName.." msgSize="..msgSize)    
    else
         print("NetManager:parseMsg fail = " .. msgName.." msgSize="..msgSize)    
    end
		
	NetSys:onEvent(msgType,msg)
end

function LoginServer:onEventLogoutHandler()

end

function LoginServer:onEventLaunchVersionCheckingHandler()
	print("***LoginServer:onEventLaunchVersionCheckingHandler")
	self.m_nOperationType = LoginServer.OperationType.OPERATION_VERSION_CHECKING
	self:connectToLoginServer()
end


function LoginServer:onEventLaunchLoginHandler()
	print("****LoginServer:onEventLaunchLoginHandler")
	--NativeCall.lcc_connectToServer("loginServer","127.0.0.1",19841)
	self.m_nOperationType = LoginServer.OperationType.OPERATION_LOGIN
	self:connectToLoginServer()

end

function LoginServer:onEventProtocolLoginResponseHandler(msg)
	print("--onEventProtocolLoginResponseHandler="..msg.event_code)
	--[[
		EGEC_UNKOWN_ERROR							= 1;		//
	EGEC_ACCOUNT_EXIST							= 2;        //
	EGEC_ACCOUNTPWD_INVALID						= 3;        //
	EGEC_ACCOUNT_USING							= 4;        //
	EGEC_ACCOUNT_LOCKED							= 5;        //
	]]
	--NativeCall.lcc_disconnectToServer(self.m_nNetSocketId)
	if msg.event_code == 'EGEC_ACCOUNT_SUCCESS' then
		print("LoginServer login success!")	
		self:reqWorldList()
		--LogicSys:onEvent(LogicEvent.EVENT_NET_LAUNCH_ENTER_SERVER)
	else
		print("LoginServer login fail!")
	end

end

function LoginServer:onEventProtocolVersionCheckResponseHandler(msg)
	--if msg.returncode == msg.UpdateLua
	if msg.returncode == 1 then
        NativeCall.lcc_download(msg.downloadurl,"temp_update.zip",1)
    elseif msg.returncode == 3 then
    	--LogicSys:onEvent(LogicEvent.EVENT_NET_LAUNCH_LOGIN)
    	self.m_nOperationType = LoginServer.OperationType.OPERATION_LOGIN 
    	self:loginBegin()
    end
	
	print("----LoginServer:onEventProtocolVersionCheckResponseHandler="..msg.returncode)
end

function LoginServer:onEventProtocolWorldListResponseHandler(msg)

	if(msg.type == 'RSLT_WORLD_SERVER') then -- world list
		for k,v in pairs(msg.info) do
			self:reqConnectWold(v.server_id)
			break;
		end
	end
end

function LoginServer:onEventProtocolConnectWorldResponseHandler(msg)
	--self:reqServerList()
	--NativeCall.lcc_disconnectToServer(self.m_nNetSocketId)
	self.m_sServerAddr = msg.world_ip
	self.m_serverPort = msg.world_port
	--self:connect()
	--self:reqVerifyWorldKey(msg.world_key)

end

function LoginServer:reqWorldList()
	local data = self.m_protocol:plWorldList(0)
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,Protocol.getEventType("EGMI_REQ_WORLD_LIST"),data)
end

function LoginServer:reqServerList()
	local data = self.m_protocol:plServerList(1)
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,Protocol.getEventType("EGMI_REQ_WORLD_LIST"),data)
end

function LoginServer:reqConnectWold(worldId)
	local data = self.m_protocol:plConnectWorld(worldId)
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,Protocol.getEventType("EGMI_REQ_CONNECT_WORLD"),data)
end

function LoginServer:reqVerifyWorldKey(strkey)
	local account = cc.UserDefault:getInstance():getStringForKey("playerName","")
	local psw = self:getPassWord()

	local data = self.m_protocol:plVerifyWorldKey(account, psw,strkey)

	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,Protocol.getEventType("EGMI_REQ_CONNECT_KEY"),data)
end

function LoginServer:getPassWord()
	local hash = projectx.lcc_getMD5Hash( "123456" )
	return hash
end

function LoginServer:loginBegin()

	if self.m_nOperationType == LoginServer.OperationType.OPERATION_LOGIN then

		local hash = projectx.lcc_getMD5Hash( "123456" )

		local ret = cc.UserDefault:getInstance():getStringForKey("playerName","")
		if ret == "" then
			ret = 'user'..os.time()..math.random(1000)
			cc.UserDefault:getInstance():setStringForKey("playerName",ret)
		end

		local data = self.m_protocol:plLogin(ret, hash)

		print("LoginServer:loginBegin "..hash)

	--	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,Protocol.getEventType("MsgLoginRequest"),data)
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,101,data)
	
	elseif self.m_nOperationType == LoginServer.OperationType.OPERATION_VERSION_CHECKING then

		local data = self.m_protocol:plVersionChecking(10101,XGVersionUpdate.VersionCode)

		NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,Protocol.getEventType("EGMI_REQ_VERSION"),data)
	else

	end
end


function LoginServer:connectToLoginServer()

	
	self.m_sServerAddr = XG_SERVER_IP
	self.m_serverPort = XG_SERVER_PORT
	self:connect()
end


function LoginServer:onConnectBegin(pEventArg)

	BaseServer.onConnectBegin(self,pEventArg)
	--LogicSys:onEvent(LogicEvent.EVENT_NET_LOGIN_BEGIN)
end

function LoginServer:onConnectComplete( pEventArg)
	self.m_protocol = Protocol:create()
	--BaseServer.onConnectComplete(self,pEventArg)
	self:loginBegin()
end

function LoginServer:onConnectFailed(pEventArg)

	BaseServer.onConnectFailed(self,pEventArg)
	--self:onNetEventFailed(NxEventNetFailed::ERROR_NETWORK_FAILED);
end

function LoginServer:onDisconnect(pEventArg)

	BaseServer.onDisconnect(self,pEventArg)
	--self:onNetEventFailed(NxEventNetFailed::ERROR_NETWORK_FAILED);
end

return LoginServer