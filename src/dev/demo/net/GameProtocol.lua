require "dev.demo.net.MsgType"

local GameProtocol = class("GameProtocol")

function GameProtocol:ctor()
  self.m_selfServerId = 0
  self.m_selfIndex = 0
end

function GameProtocol.getEventType(sProtocolMsgType)

	local msgType = protobuf.enum_id("XGMsg.GameServerId", sProtocolMsgType)  
	if msgType == nil then
		print("error ="..sProtocolMsgType)
	end
	return msgType
end

function GameProtocol.getProtocolType(nEventType)

end

function GameProtocol.getProtocolTypeName(nMsgType)
	return GameServerIdName[nMsgType] or ""
end

	-- ==================== begin: sending protocols ====================
function GameProtocol:plHeartBeat()
end

function GameProtocol:plLogin(tid,uid,mtkey,imgUrl,giftId,passworld) 

  local stringbuffer = protobuf.pack("XGMsg.RoomReqLoginData tid uid mtkey imgUrl giftId passworld",1,1,"mtkey","url",1,"123456") 
  local  pb = stringbuffer--protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,stringbuffer)

  return pb
end

function GameProtocol:plExitGame()
end

return GameProtocol



