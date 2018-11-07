
require "dev.demo.scenes.layers.PopupLayer"
require "dev.demo.net.GameServer"

local TestServer = class("TestServer", PopupLayer)

local function initProtocol()
	local protos = {
        "dev/demo/net/pbc/MsgType.pb",
        "dev/demo/net/pbc/MsgProtocol.pb",
    }
    for k,v in pairs(protos) do
        local pbFilePath = cc.FileUtils:getInstance():fullPathForFilename(v)       	  
	    local buffer = readProtobufFile(pbFilePath)      
	    protobuf.register(buffer)--注:protobuf 是因为在protobuf.lua里面使用module(protobuf)来修改全局名字  
    end
end

function TestServer:ctor()
	initProtocol();
	self:init()
	LogicSys:regEventHandler(LogicEvent.EVENT_SERVER_STATUS, self.onEventServerStatus, self)

	NetSys:regEventHandler(GameProtocol.getEventType("SVR_CMD_LOGIN_SUCC"),self.onAckLoginSuccess,self)
	NetSys:regEventHandler(GameProtocol.getEventType("SVR_CMD_LOGIN_FAIL"),self.onAckLoginFail,self)
end



function TestServer:dtor()
	GameServer.release()
	LogicSys:unregEventHandler(LogicEvent.EVENT_SERVER_STATUS, self.onEventServerStatus, self)
	NetSys:unregEventHandler(GameProtocol.getEventType("SVR_CMD_LOGIN_SUCC"),self.onAckLoginSuccess,self)
	NetSys:unregEventHandler(GameProtocol.getEventType("SVR_CMD_LOGIN_FAIL"),self.onAckLoginFail,self)
end

function TestServer:init()

	
	self.m_root = NodeUtils:getRootNodeInCreator('creator/Scene/4_server.ccreator')
	self:addChild(self.m_root)


	self.m_labelTips = NodeUtils:seekNodeByName(self.m_root,'label_tips') 

	local btLogin = NodeUtils:seekNodeByName(self.m_root,'bt_login') 
	
	btLogin:setPressedActionEnabled(true)
	btLogin:addClickEventListener(function(sender)
		--self:exitPopupLayer()
		btLogin:setEnabled(false)
		self.m_labelTips:setString("登录中...")
		GameServer.getInstance():connectToServer(XG_SERVER_IP,XG_SERVER_PORT)
		end)


	local btExit = NodeUtils:seekNodeByName(self.m_root,'bt_exit') 
	
	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()

		end)
end


function TestServer:onEventServerStatus(nNetId,status)

	print("onEventServerStatus "..status)
	if XG_SERVER_STATUS_CONNECTING == status then
		self.m_labelTips:setString("连接服务器中...")
	elseif XG_SERVER_STATUS_DISCONNECT == status then
		self.m_labelTips:setString("连接服务器失败")
	elseif XG_SERVER_STATUS_CONNECTED == status then
		self.m_labelTips:setString("连接服务器成功")
		GameServer.getInstance():reqLogin()
    end

end

function TestServer:onAckLoginSuccess(msg)
	self.m_labelTips:setString("登录房间成功")
end

function TestServer:onAckLoginFail(msg)

end


return TestServer
