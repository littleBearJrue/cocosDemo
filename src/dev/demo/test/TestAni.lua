
require "dev.demo.scenes.layers.PopupLayer"

local TestAni = class("TestAni", PopupLayer)

function TestAni:ctor()
	self:init()
end



function TestAni:init()

	local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/2_ani.ccreator')
	creatorReader:setup()
 
	local scene = creatorReader:getNodeGraph()

	self.m_root = NodeUtils:seekNodeByName(scene,'root') 
	self.m_root:removeFromParent(false)
	self:addChild(self.m_root)


	-- 因为 AnimationManager 节点不在 root 节点下，所以把它添加到 self 下
	self.m_aniManager =  creatorReader:getAnimationManager()
    self.m_aniManager:removeFromParent(false)
    self:addChild(self.m_aniManager)

	local func = function (  )
        self.m_aniManager:playAnimationClip(self.m_root,"2_ani")
    end
    NodeUtils:delayCall(0.1,self,func)



	

	local btExit = NodeUtils:seekNodeByName(self.m_root,'bt_exit') 
	
	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()
		end)
end

return TestAni
