

local SceneLogin = class("SceneLogin", Scene)


local function SceneLogin_onEnterOrExit(tag)
  
end

function SceneLogin:onCreate()
  
  self:registerScriptHandler(
      function ( tag )
        if tag == "enter" then
          LogicSys:onEvent(LogicEvent.EVENT_NET_LAUNCH_ENTER_SERVER)
        elseif tag == "exit" then
        end
      end
    )

	self:init()
end

function SceneLogin:init()
  local s = cc.Director:getInstance():getWinSize()
  --self.m_spriteBg = cc.Sprite:create("tex/login/login_bg.jpg")
  --self.m_spriteBg:setPosition(cc.p(display.cx, display.cy))
  --self:addChild(self.m_spriteBg)
  
 -- self.m_spriteBg:setTextureRect(cc.rect(0,0,s.width,s.height))
    
   local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)

            if not self.m_isEnter then
                self.m_isEnter = true
              --  GameServer.getInstance():reqEnterGame()
               -- LogicSys:onEvent(LogicEvent.EVENT_SCENE_ENTER,Scene.XG_SCENE_TOWN)

        
            end

            
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

   

   local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/login_scene.ccreator')
   if creatorReader then
      creatorReader:setup()


      local scene = creatorReader:getNodeGraph()
      self.m_root = NodeUtils:seekNodeByName(scene,'root') 
      self.m_root:removeFromParent(false)
      self:addChild(self.m_root)

      self.m_aniManager =  creatorReader:getAnimationManager()
      self.m_aniManager:removeFromParent(false)
      self:addChild(self.m_aniManager)

      local func = function (  )
        self.m_aniManager:playAnimationClip(self.m_root,"login_scene")
      end
      NodeUtils:delayCall(2.0,self,func)
      --local scene = creatorReader:getNodeGraph()
      --self:addChild(scene)
    end
    


  self.m_checkOnline = NodeUtils:seekNodeByName(self,'online') 
  self.m_checkOnline:setScale(1.0)

  local ret = cc.UserDefault:getInstance():getBoolForKey("online",false)


  self.m_checkOnline:setSelected(ret)

  self.m_checkOnline:addEventListener(
      function (send,selectType)
        --print("m_checkOnline="..type)
        if selectType == 0 then
          cc.UserDefault:getInstance():setBoolForKey("online",true)
        else
          cc.UserDefault:getInstance():setBoolForKey("online",false)
        end
        self:updateUseFakeServer()
      end
    )

  self:updateUseFakeServer()
  print("SceneLogin:onCreate")
end

function SceneLogin:updateUseFakeServer()

  local ret = cc.UserDefault:getInstance():getBoolForKey("online",false)
  if ret then
    XG_USE_FAKE_SERVER = false
  else
    XG_USE_FAKE_SERVER = true
  end
end




return SceneLogin
