
local net = import("framework.net")
local NetManager = net.NetManager
local NativeCall = {}

function NativeCall.lcc_connectToServer(netSocketId,ip,port)
	if XG_USE_FAKE_SERVER then

		NativeCall.ccl_socketEvent(netSocketId,g_event.SOCKET_EVENT_CONNECT_BEGIN)
		NativeCall.ccl_socketEvent(netSocketId,g_event.SOCKET_EVENT_CONNECT_COMPLETE)

		return 
	end
    projectx.lcc_connectToServer(netSocketId,ip,port)
end

function NativeCall.lcc_disconnectToServer(netSocketId)
    projectx.lcc_disconnectToServer(netSocketId)
end


function NativeCall.ccl_socketEvent(netSocketId,eventId,arg)
    print("ccl_socketEvent="..netSocketId.." eventId="..eventId)
    NetManager.getInstance():onNetEventHandler(netSocketId,eventId,arg)
    return 1
end


function NativeCall.lcc_sendMsgToServer(netSocketId,msgType,msgData)
	print("lcc_sendMsgToServer="..netSocketId.." msgType="..msgType)
	if XG_USE_FAKE_SERVER then
		NetSys:onEvent(msgType,msgData)
		return 
	end
	local msgSize = string.len(msgData)
	projectx.lcc_sendMsgToServer(netSocketId,msgData,msgSize)
end


function NativeCall.ccl_recvMsgFromServer(netSocketId,msgSize, msgData)
	print("start lcc_recvMsgFromServer =xxx"..netSocketId)
	NetManager.getInstance():parseMsg(netSocketId,msgType or 0,msgSize,msgData)
    print("end lcc_recvMsgFromServer =xxx"..netSocketId)
	--projectx.lcc_sendMsgToServer(netSocketId,msgType,msgData)
end


function NativeCall.lcc_download(url,identifier)
	--print("NativeCall.lcc_download="..url)
	projectx.lcc_download(url,identifier)
	--print("NativeCall.lcc_download22222=2"..url)
end

function NativeCall.lcc_getMD5Hash(data)
	return projectx.lcc_getMD5Hash(data)
end

function NativeCall.ccl_downloaderOnTaskProgress(identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected)
	NetManager.getInstance():downloaderOnTaskProgress(identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected)
end

function NativeCall.ccl_downloaderOnDataTaskSuccess(identifier, pData,nSize)
	NetManager.getInstance():downloaderOnDataTaskSuccess(identifier, pData,nSize)
end

function NativeCall.ccl_downloaderOnFileTaskSuccess(identifier)
	NetManager.getInstance():downloaderOnFileTaskSuccess(identifier)
end

function NativeCall.ccl_downloaderOnTaskError(identifier,  errorCode,  errorCodeInternal,errorStr)

	NetManager.getInstance():downloaderOnTaskError(identifier,  errorCode,  errorCodeInternal,errorStr)
end


function NativeCall.lcc_setGLProgramState(node,  shadeId)
	projectx.lcc_setGLProgramState(node,  shadeId)
end


function NativeCall.lcc_callSystemEvent(key,  data)
	projectx.lcc_callSystemEvent(key, data)
end


function NativeCall.ccl_systemCallLuaEvent(key,  data)
	print("ccl_systemCallLuaEvent"..key..data)
end


return NativeCall;