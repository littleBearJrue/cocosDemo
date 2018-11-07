require "dev.demo.net.BaseServer"
require "dev.demo.net.Protocol"
require "dev.demo.net.LoginServer"
require "dev.demo.net.GameServer"
require("json")

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
	
	LogicSys:regEventHandler(LogicEvent.EVENT_SERVER_CREATE, self.onEventServerCreate, self)
	LogicSys:regEventHandler(LogicEvent.EVENT_SERVER_CLOSE, self.onEventServerClose, self)
	
	if XG_USE_FAKE_SERVER then
		XGFakeServer.getInstance()
	end
end

function NetManager:dtor()
	LogicSys:unregEventHandler(LogicEvent.EVENT_SERVER_CREATE, self.onEventServerCreate, self)
	LogicSys:unregEventHandler(LogicEvent.EVENT_SERVER_CLOSE, self.onEventServerClose, self)
end

function NetManager:onNetEventHandler(nNetSocketId,nEventId, pEventArg)
	if self.m_netServers[nNetSocketId] then
		self.m_netServers[nNetSocketId]:onNetEventHandler(nEventId, pEventArg)
	end
end


function NetManager:parseMsg(nNetSocketId,msgType,msgSize,msgData)
	-- print("NetManager:parseMsg  " )
	if self.m_netServers[nNetSocketId] then
		self.m_netServers[nNetSocketId]:parseMsg(msgType,msgSize,msgData)
	end
	-- print("NetManager:parseMsg end " )
end


function NetManager:sendMsgToCurServer(nNetSocketId,msgType,msgData)
	--local ident = protobuf.pack("NFMsg.Ident svrid index",0,0)
	--local  pb = protobuf.pack("NFMsg.MsgBase player_id msg_data",ident,msgData)
	if self.m_netServers[nNetSocketId] then
		NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,msgType,msgData)
	end
end


function NetManager:onEventServerCreate(nNetSocketId,server)
	self.m_netServers[nNetSocketId] = server
end

function NetManager:onEventServerClose(nNetSocketId,server)
	self.m_netServers[nNetSocketId] = nil
end


function NetManager:downloaderOnTaskProgress(identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected)
	LogicSys:onEvent(LogicEvent.EVENT_DOWNLOADER_ON_PROGRESS,identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected)

end

function NetManager:downloaderOnDataTaskSuccess(identifier, pData,nSize)
	LogicSys:onEvent(LogicEvent.EVENT_DOWNLOADER_ON_DATA_SUCCESS,identifier,pData,nSize)
end

function NetManager:downloaderOnFileTaskSuccess(identifier)
	LogicSys:onEvent(LogicEvent.EVENT_DOWNLOADER_ON_FILE_SUCCESS,identifier)
end

function NetManager:downloaderOnTaskError(identifier,  errorCode,  errorCodeInternal,errorStr)
	LogicSys:onEvent(LogicEvent.EVENT_DOWNLOADER_ON_ERROR,identifier,errorCode,errorCodeInternal,errorStr)
end


function NetManager:httpPost(url,data,obj,onResult,onError)
	if XG_USE_FAKE_SERVER then

		XGFakeServer.getInstance():httpPost(url,data,obj,onResult,onError)

		return 
	end


	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:open("POST", url)

	local function onReadyStateChanged()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			
			local response   = xhr.response
			local output = json.decode(response,1)

			if onResult then
				onResult(obj,output)
			end
		else
			onError(obj)
			print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
		end

		xhr:unregisterScriptHandler()
		xhr=nil
	end

	xhr:registerScriptHandler(onReadyStateChanged)
	xhr:send(data)
end



return NetManager