
require "dev.demo.scenes.layers.PopupLayer"

local TestWidget = class("TestWidget", PopupLayer)

function TestWidget:ctor()
	self:init()
end



function TestWidget:init()

	--目前只支持 9 个样式的布局，如例子所示，其它的功能暂不支持

	self.m_root = NodeUtils:getRootNodeInCreator('creator/Scene/1_widget.ccreator')
	self:addChild(self.m_root)


	local btExit = NodeUtils:seekNodeByName(self.m_root,'bt_exit') 
	
	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()
		end)
end

return TestWidget
