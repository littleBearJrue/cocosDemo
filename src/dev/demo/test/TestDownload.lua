
require "dev.demo.scenes.layers.PopupLayer"
require "dev.demo.net.GameServer"
require("json")


local testGetUrl =  "http://httpbin.org/get"
local downPngUrl =  "http://www.cocos2d-x.org/attachments/802/cocos2dx_landscape.png"
local downBigFileUrl =  "http://download.cocos.com/CocosCreator/v1.9.3/CocosCreator_v1.9.3.setup.7z"

--local testPostUrl =  "http://127.0.0.1:8082"
local identifier_png = "cocos2dx_landscape.png"
local identifier_bigFile = "identifier_bigFile"


local TestDownload = class("TestDownload", PopupLayer)

function TestDownload:ctor()
	self:init()
	LogicSys:regEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_PROGRESS, self.onEventOnProgress, self)
	LogicSys:regEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_DATA_SUCCESS, self.onEventOnDataSuccess, self)
	LogicSys:regEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_FILE_SUCCESS, self.onEventOnFileSuccess, self)
	LogicSys:regEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_ERROR, self.onEventOnError, self)

end

function TestDownload:dtor()
	LogicSys:unregEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_PROGRESS, self.onEventOnProgress, self)
	LogicSys:unregEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_DATA_SUCCESS, self.onEventOnDataSuccess, self)
	LogicSys:unregEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_FILE_SUCCESS, self.onEventOnFileSuccess, self)
	LogicSys:unregEventHandler(LogicEvent.EVENT_DOWNLOADER_ON_ERROR, self.onEventOnError, self)
end

function TestDownload:init()
	self.m_root = NodeUtils:getRootNodeInCreator('creator/Scene/6_download.ccreator')
	self:addChild(self.m_root)

	self.m_labelStatus = NodeUtils:seekNodeByName(self.m_root,'label_tips') 

	local btDownload = NodeUtils:seekNodeByName(self.m_root,'download_png') 

	btDownload:setPressedActionEnabled(true)
	btDownload:addClickEventListener(function(sender)
		NativeCall.lcc_download(downPngUrl,identifier_png)
		end)


	local btDownloadFile = NodeUtils:seekNodeByName(self.m_root,'download_bigfile') 

	btDownloadFile:setPressedActionEnabled(true)
	btDownloadFile:addClickEventListener(function(sender)
		NativeCall.lcc_download(downBigFileUrl,identifier_bigFile)
		end)

	

	local btExit = NodeUtils:seekNodeByName(self.m_root,'bt_exit') 

	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()
		end)


end

function TestDownload:onEventOnProgress(identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected)
	local percent = totalBytesReceived * 100 / totalBytesExpected
	self.m_labelStatus:setString(tostring( math.floor(percent) ).."%")
end

function TestDownload:onEventOnDataSuccess(identifier, data,size)
	self.m_labelStatus:setString("下载数据成功")
end

function TestDownload:onEventOnFileSuccess(identifier)
	self.m_labelStatus:setString("下载文件成功")
	if identifier_png == identifier then
		local path =cc.FileUtils:getInstance():getWritablePath()
		path = path.."/update/"..identifier
		local sprite = cc.Sprite:create(path)
		self:addChild(sprite)
		sprite:setAnchorPoint(cc.p(0,0))
	end
end

function TestDownload:onEventOnError(identifier,  errorCode,  errorCodeInternal,errorStr)
	self.m_labelStatus:setString(errorStr)
end



return TestDownload
