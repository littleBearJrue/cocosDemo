
local SceneWelcome = class("SceneWelcome", Scene)

function SceneWelcome:onCreate()


  local ret = cc.UserDefault:getInstance():getBoolForKey("online",false)
  if ret then
    XG_USE_FAKE_SERVER = false
  else
    XG_USE_FAKE_SERVER = true
  end
  --XG_USE_FAKE_SERVER = false
	LogicSys:onEvent(LogicEvent.EVENT_NET_LAUNCH_VERSION_CHECK)
   	local s = cc.Director:getInstance():getWinSize()
	 local layer1 = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), s.width, s.height)
    layer1:setCascadeColorEnabled(false)

   -- layer1:setPosition( cc.p(display.cx, display.cy))
    self:addChild(layer1)

   self.m_imgs = {
    --"welcome/lemonjam.png",
   	"welcome/HelloWorld.png",
}


	self.m_curIndex = 1


	self.m_spriteBg = cc.Sprite:create(self.m_imgs[self.m_curIndex])
	self.m_spriteBg:setPosition(cc.p(display.cx, display.cy))
	self:addChild(self.m_spriteBg)
   
	--NativeCall.lcc_setGLProgramState(self.m_spriteBg,1)

	--local glprogram = cc.GLProgram:createWithFilenames("shader/gray.vsh","shader/gray.fsh")
	--local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(glprogram)
	

	--self.m_spriteBg:setGLProgramState(XGShaderCache.getInstance():getGLProgramState(2))

   self:runFadeAction()

  -- local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/helloworld.ccreator')
 -- creatorReader:setup()
  --local scene = creatorReader:getSceneGraph()
 -- self:addChild(scene)
   


--self:scheduleUpdate(onUpdate)
end

function SceneWelcome:runFadeAction()
	local dt = 0.5
	self.m_spriteBg:setOpacity(0)
	 local actionTo = cc.FadeIn:create(dt)
	 local actionOut = cc.FadeOut:create(dt)
	local callEnd=cc.CallFunc:create(function ()
		self:fadeActionEnd()


	end)

	self.m_spriteBg:runAction(cc.Sequence:create(actionTo, actionOut,callEnd))
end

function SceneWelcome:fadeActionEnd()
	self.m_curIndex = self.m_curIndex+ 1
	if self.m_curIndex > #self.m_imgs then


	--	local XGTest = require "app/scenes/XGTest"
  -- local test = XGTest:create()
  -- self:addChild(test)
		LogicSys:onEvent(LogicEvent.EVENT_SCENE_ENTER,Scene.XG_SCENE_LOGIN)

		
		--HintManager.getInstance():addData("tsetdata")
		--HintManager.getInstance():addData("tsetdata222")
		--XGAniGoldManager.getInstance():playGoldAni(50,50,500,1200,null,null)
	else
		self.m_spriteBg = cc.Sprite:create(self.m_imgs[self.m_curIndex])
		self.m_spriteBg:setPosition(cc.p(display.cx, display.cy))
		self:addChild(self.m_spriteBg)

		self:runFadeAction()	
	end
	
end


function SceneWelcome:init()
 --[[ local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            print(string.format("SceneWelcome::onTouchBegan id = %d, x = %f, y = %f", touch:getId(), touch:getLocation().x, touch:getLocation().y))
            LogicSys:onEvent(LogicEvent.EVENT_SCENE_ENTER,Scene.XG_SCENE_LOGIN)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)]]
end

return SceneWelcome


 -- add background image
    --[[display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)
]]
        
        

        
       -- local stringbuffer = protobuf.pack("XGNetMsg.Person name id phone","abc",12345,{number = "87654321" })


		  
		--[[local stringbuffer = protobuf.encode("XGNetMsg.Person",      
		    {      
		        name = "Alice",      
		        id = 12345,      
		        phone = {      
		            {      
		                number = "87654321"      
		            },      
		        }      
		    })      
		     
		local slen = string.len(stringbuffer)      
		local temp = ""      
		for i=1, slen do      
		    temp = temp .. string.format("0xX, ", string.byte(stringbuffer, i))      
		end 

       -- projectx.lua_call_c_phc_data(stringbuffer)  
		--release_print(temp)      
		local result = protobuf.decode("XGNetMsg.Person", stringbuffer)      
		--release_print("result name: "..result.name)  
		--release_print("result name: "..result.id)  ]]
    -- add HelloWorld label


	--[[local filename = "test_hello"
	local file, err = io.open("test_hello", "rb")
	if file == nil then  
            error(("Unable to write '%s': %s"):format(filename, err)) 
	else
		--file:write(stringbuffer)  
		--file:close()  
		
		local data = file:read("*a")
		local result = protobuf.decode("Person", data) 

		release_print("result name: "..result.name)  
		release_print("result name: "..result.id)  
    end  ]]
	--self:init()



   -- local node2 = Player:create()

    --self:addChild(node2)