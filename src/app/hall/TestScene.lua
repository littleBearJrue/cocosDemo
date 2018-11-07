
local TestScene = class("TestScene",cc.Scene);

TestScene.eventFuncMap =  {
	[g_event.SOCKET_EVENT_CONNECT_COMPLETE]		 	 	= "onConnected";
	[g_event.SOCKET_EVENT_CLOSED]		 	 	 		= "onCloseed";
	[g_event.SOCKET_EVENT_CONNECT_FAILED]		 	 	= "onConnectFailed";
};

function TestScene:ctor()
	self:init();
	self:registerEvent();
end

function TestScene:init()
	local layer = cc.Layer:create();
	self:addChild(layer);
    
	local title = cc.Label:createWithSystemFont("demo","",36);
	title:setPosition(display.cx,display.height-20);
	layer:add(title);

	self.desc = cc.Label:createWithSystemFont("","",24);
	self.desc:setPosition(display.cx,display.height-50);
	layer:add(self.desc);

	local function onConnect()
		local isConnected = g_socket:requestInterface("isConnected")
		if isConnected then
			g_socket:requestInterface("closeSocket");
		else
			g_socket:requestInterface("openSocket","dfaccess.oa.com",7000);
		end
	end

	self.socketTx = cc.MenuItemFont:create("socket连接测试")
    self.socketTx:registerScriptTapHandler(onConnect)
    local function onChangeDemo()
    	-- require("dev.demo.init")
    	-- local SceneTest = require "dev.demo.test.SceneTest"
		-- local scene = SceneTest:create()
		-- cc.Director:getInstance():pushScene(scene)
		
    local scene = cc.Scene:create()
	scene:addChild(CreatePersonalMenu())
	
		-- local scene = require("app.game.init").TestScene:create()
		cc.Director:getInstance():pushScene(scene)
    end

	local  item2 = cc.MenuItemFont:create("切换demo")
    item2:registerScriptTapHandler(onChangeDemo)

    local  menu = cc.Menu:create(self.socketTx,item2)
    menu:alignItemsVertically()
    layer:addChild(menu)

end

function TestScene:onConnected(info)
	self.desc:setString("socket连接成功")
	self.socketTx:setString("关闭socket")
end

function TestScene:onCloseed()
	self.desc:setString("socket关闭成功")
	self.socketTx:setString("连接socket")
end

function TestScene:onConnectFailed()
	self.desc:setString("socket连接失败")
	self.socketTx:setString("连接socket")
end

---注册监听事件
function TestScene:registerEvent()
    self.eventFuncMap = checktable(self.eventFuncMap);
    for k,v in pairs(self.eventFuncMap) do
    	print(k,v)
        assert(self[v],"配置的回调函数不存在")
        g_eventDispatcher:register(k,self,self[v])
    end
end

---取消事件监听
function TestScene:unRegisterEvent()
    if g_eventDispatcher then
        g_eventDispatcher:unRegisterAllEventByTarget(self)
    end 
end

function TestScene:dtor()
	error(1)
	self:unRegisterEvent();
end

return TestScene;