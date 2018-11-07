require "dev.demo.net.MsgType"

local Protocol = class("Protocol")

function Protocol:ctor()
  self.m_selfServerId = 0
  self.m_selfIndex = 0
end

function Protocol.getEventType(sProtocolMsgType)

	local msgType = protobuf.enum_id("NFMsg.EGameMsgID", sProtocolMsgType)  
	--local result = protobuf.decode("XGXGNetMsg.MsgType", stringbuffer)  
	--print("main msgtype = "..msgType)
	if msgType == nil then
		print("error ="..sProtocolMsgType)
	end
	return msgType
end

function Protocol.getProtocolType(nEventType)

end

function Protocol.getProtocolTypeName(nMsgType)
	return EGameMsgIDName[nMsgType] or ""
end



function Protocol:plIdent()
  -- local ident = protobuf.pack("NFMsg.Ident svrid index",self.m_selfServerId,self.m_selfIndex)
   local ident = protobuf.pack("NFMsg.Ident svrid index",0,0)
   return ident
 end
 
 function Protocol:plPackage(data)
   local ident = self:plIdent()
   local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,data)
   return pb
 end
 

	-- ==================== begin: sending protocols ====================
function Protocol:plHeartBeat()
end

function Protocol:plLogin( sName, sPassword) 

  local stringbuffer = protobuf.pack("NFMsg.ReqAccountLogin account password security_code signBuff clientVersion loginMode clientIP clientMAC device_info extra_info",
  sName,sPassword,"","",1,0,0,0,"","") 

  local ident = self:plIdent()

  local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,stringbuffer)

  return pb
end

function Protocol:plCreatePlayer(sName,  sPassword, sPlayerName,  nRace,  nSex)
end

function Protocol:plEnterGame(sName, sPassword,  nPlayerId)
    local sessionData = protobuf.pack("XGNetMsg.LoginSession sessionId userId","1",nPlayerId)
    local msg = protobuf.pack("XGNetMsg.EnterGameRequest userName password loginSession playerId",sName,sPassword,sessionData,nPlayerId)

    --[[local msg = protobuf.encode("XGNetMsg.EnterGameRequest",
        {
            userName = sName,password = sPassword,loginSession = {sessionId = "1", userId = 1}, playerId= nPlayerId
            })]]
    return msg
end

function Protocol:plExitGame()
end



function Protocol:plVersionChecking(platformcode,versionCode)
 
  local ident = self:plIdent()--protobuf.pack("NFMsg.Ident svrid index",10,10)

  local stringbuffer = protobuf.pack("NFMsg.ReqCheckVersion platformCode verionCode",platformcode,versionCode)
  
  local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,stringbuffer)

  return pb
end


function Protocol:plWorldList(type)
 
  local ident = self:plIdent()

  local stringbuffer = protobuf.pack("NFMsg.ReqServerList type",0)
  
  local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,stringbuffer)

  return pb
end



function Protocol:plServerList(type)
 
  local ident = self:plIdent()

  local stringbuffer = protobuf.pack("NFMsg.ReqServerList type",1)
  
  local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,stringbuffer)

  return pb
end

function Protocol:plConnectWorld(worldId)
 
  local stringbuffer = protobuf.pack("NFMsg.ReqConnectWorld world_id",worldId)
  
  local  pb = self:plPackage(stringbuffer)

  return pb
end

function Protocol:plVerifyWorldKey(sName,sPassword,strKey)
 
  local stringbuffer = protobuf.pack("NFMsg.ReqAccountLogin account password security_code signBuff clientVersion loginMode clientIP clientMAC device_info extra_info",
  sName,sPassword,strKey,"",1,0,0,0,"","")

  --local stringbuffer = protobuf.pack("NFMsg.ReqAccountLogin world_id",worldId)
  
  local  pb = self:plPackage(stringbuffer)

  return pb
end

function Protocol:plSelectServer(serverId)
 
  local stringbuffer = protobuf.pack("NFMsg.ReqSelectServer world_id",serverId)
  
  local  pb = self:plPackage(stringbuffer)

  return pb
end

function Protocol:plRoleList(playerName,serverId)
	

  local data = protobuf.pack("NFMsg.ReqRoleList game_id account",serverId,playerName)

  
  local  pb = self:plPackage(data)

  return pb
end

function Protocol:plCreateRole(account,serverId)
  
  
  local data = protobuf.pack("NFMsg.ReqCreateRole account career sex race noob_name game_id",account,0,0,0,"default",serverId)

  
  local  pb = self:plPackage(data)

  return pb
end


function Protocol:plEnterGame(account,serverId,ident,name)

  local id = protobuf.pack("NFMsg.Ident svrid index",ident.svrid,ident.index)--ident.svrid or serverId ,ident.index)
  local data = protobuf.pack("NFMsg.ReqEnterGameServer id account game_id name",id,account,serverId,name)

  --local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,data)
  local  pb = self:plPackage(data)

  return pb
end

return Protocol