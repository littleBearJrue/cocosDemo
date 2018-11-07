local BaseServer = require "dev.demo.net.BaseServer"
local GameProtocol = require "dev.demo.net.GameProtocol"

local GameServer = class("GameServer",BaseServer)


function GameServer.getInstance()
	if not GameServer.s_instance then
		GameServer.s_instance = GameServer:create()
	end
	return GameServer.s_instance
end

function GameServer.release()
	if  GameServer.s_instance then
		
		delete(GameServer.s_instance)
		GameServer.s_instance = nil
	end
end

function GameServer:ctor()
   
    self.m_nNetSocketId = XG_NET_SOCKET_GAME
	
    self.m_worldKey = "test"
	--NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_LOGIN"), self.onEventProtocolConnectWorldResponseHandler, self)


	--self.m_nOperationType = LoginServer.OperationType.OPERATION_NONE 

	LogicSys:onEvent(LogicEvent.EVENT_SERVER_CREATE,self.m_nNetSocketId,self)
	
end

function GameServer:dtor()
	
	self:disconnect()
	--NetSys:unregEventHandler(GameProtocol.getEventType("CLI_CMD_LOGIN"), self.onEventProtocolConnectKeyResponseHandler, self)
end

function GameServer:decodeMsg(msgType,msgSize,msgData)

	local msgName = GameProtocol.getProtocolTypeName(msgType)

	local msg = protobuf.decode(msgName, msgData, msgSize) 

	return msg
end

function GameServer:parseMsg(msgType,msgSize,msgData)

	local msgName = GameProtocol.getProtocolTypeName(msgType)
	local msg = protobuf.decode(msgName, msgData, msgSize) 


    if type(msg) =='table' then
        print("GameServer:parseMsg success = " .. msgName.." msgSize="..msgSize)    
    else
        print("GameServer:parseMsg fail = " .. msgName.." msgSize="..msgSize)    
    end
		
	NetSys:onEvent(msgType,msg)
end

function GameServer:getPassWord()
	local hash = projectx.lcc_getMD5Hash( "123456" )
	return hash
end

function GameServer:onEventLogoutHandler()

end


function GameServer:getServerInfo()
	return self.m_selectServerInfo
end

function GameServer:onEventProtocolWorldListResponseHandler(msg)
	if(msg.type == 'RSLT_GAMES_ERVER') then -- game server list
	end
end


function GameServer:connectToServer(ip,port)

	self.m_sServerAddr = ip
	self.m_serverPort = port
	self:connect()
end

function GameServer:onConnectComplete( pEventArg)
	self.m_protocol = GameProtocol:create()
	--NetManager.getInstance():setCurSocketId(self.m_nNetSocketId)

	--self:reqLogin()
end



function GameServer:reqLogin()
	local data = self.m_protocol:plLogin()
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,GameProtocol.getEventType("CLI_CMD_LOGIN"),data)
end

function GameServer:reqEnterGame()
	if self.m_roleInfo then 
		local roleInfo = self.m_roleInfo

		local playerName = cc.UserDefault:getInstance():getStringForKey("playerName","")
		local data = self.m_protocol:plEnterGame(playerName,self.m_selectServerInfo.server_id,roleInfo.id,roleInfo.noob_name)
		NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,GameProtocol.getEventType("EGMI_REQ_ENTER_GAME"),data)
	end
end

return GameServer