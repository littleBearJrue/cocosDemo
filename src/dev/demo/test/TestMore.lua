
require "dev.demo.scenes.layers.PopupLayer"

local TestMore = class("TestMore", PopupLayer)

function TestMore:ctor()
	self:init()
end



function TestMore:init()

	self.m_root = NodeUtils:getRootNodeInCreator('creator/Scene/3_more.ccreator')
	self:addChild(self.m_root)


	local btExit = NodeUtils:seekNodeByName(self.m_root,'bt_exit') 
	
	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()
		end)
end

return TestMore
