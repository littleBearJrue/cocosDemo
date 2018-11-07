
require "dev.demo.scenes.layers.PopupLayer"
require "dev.demo.net.GameServer"
require("json")


local testGetUrl =  "http://httpbin.org/get"
local testPostUrl =  "http://httpbin.org/post"
--local testPostUrl =  "http://127.0.0.1:8082"


local TestHttp = class("TestHttp", PopupLayer)

function TestHttp:ctor()
	self:init()
end

function TestHttp:dtor()

end

function TestHttp:init()
	self.m_root = NodeUtils:getRootNodeInCreator('creator/Scene/5_http.ccreator')
	self:addChild(self.m_root)

	self.m_labelStatus = NodeUtils:seekNodeByName(self.m_root,'label_tips') 

	local btGet = NodeUtils:seekNodeByName(self.m_root,'bt_get') 

	btGet:setPressedActionEnabled(true)
	btGet:addClickEventListener(function(sender)
		local xhr = cc.XMLHttpRequest:new()
            xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
            xhr:open("GET", testGetUrl)

            local function onReadyStateChanged()
                if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                    print(xhr.response)
                    if not tolua.isnull( self.m_labelStatus) then
						self.m_labelStatus:setString("Http Status Code:" .. xhr.statusText)
                    else
                        print("ERROR: labelStatusCode is invalid!")
                    end
                else
                    print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
                end
                xhr:unregisterScriptHandler()
            end

            xhr:registerScriptHandler(onReadyStateChanged)
            xhr:send()

            self.m_labelStatus:setString("waiting...")
		end)

	local btPost =NodeUtils:seekNodeByName(self.m_root,'bt_post') 
	btPost:setPressedActionEnabled(true)
	btPost:addClickEventListener(function(sender)
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
		xhr:open("POST", testPostUrl)
		local function onReadyStateChanged()
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				if not tolua.isnull( self.m_labelStatus) then
					self.m_labelStatus:setString("Http Status Code:" .. xhr.statusText)
				else
					print("ERROR: labelStatusCode is invalid!")
				end
				print(xhr.response)
			else
				print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
			end
			xhr:unregisterScriptHandler()
		end
		xhr:registerScriptHandler(onReadyStateChanged)
		xhr:send("my test")

		self.m_labelStatus:setString("waiting...")
		end)




	local btPostBinary = NodeUtils:seekNodeByName(self.m_root,'bt_post_binary') 
	btPostBinary:setPressedActionEnabled(true)
	btPostBinary:addClickEventListener(function(sender)
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
		xhr:open("POST", testPostUrl)

		local function onReadyStateChanged()
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				local response   = xhr.response
				local size     = table.getn(response)
				local strInfo = ""

				for i = 1,size do
					if 0 == response[i] then
						strInfo = strInfo.."\'\\0\'"
					else
						strInfo = strInfo..string.char(response[i])
					end
				end

				if not tolua.isnull( self.m_labelStatus) then
					self.m_labelStatus:setString("Http Status Code:" .. xhr.statusText)
				else
					print("ERROR: labelStatusCode is invalid!")
				end

				print(strInfo)
			else
				print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
			end
			xhr:unregisterScriptHandler()
		end

		xhr:registerScriptHandler(onReadyStateChanged)
		xhr:send("my test")

		self.m_labelStatus:setString("waiting...")
		end)


	local btPostJson = NodeUtils:seekNodeByName(self.m_root,'bt_post_json') 
	btPostJson:setPressedActionEnabled(true)
	btPostJson:addClickEventListener(function(sender)
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		xhr:open("POST", testPostUrl)

		local function onReadyStateChanged()
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				if not tolua.isnull( self.m_labelStatus) then
					self.m_labelStatus:setString("Http Status Code:" .. xhr.statusText)
				else
					print("ERROR: labelStatusCode is invalid!")
				end
				local response   = xhr.response
				local output = json.decode(response,1)
				table.foreach(output,function(i, v) print (i, v) end)
				print("headers are")
				table.foreach(output.headers,print)
			else
				print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
			end
			xhr:unregisterScriptHandler()
		end

		xhr:registerScriptHandler(onReadyStateChanged)
		xhr:send()

		self.m_labelStatus:setString("waiting...")
		end)

	local btExit = NodeUtils:seekNodeByName(self.m_root,'bt_exit') 

	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()
		end)


end



return TestHttp
