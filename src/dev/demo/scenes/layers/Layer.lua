
cc.exports.Layer = class("Layer",cc.Layer)

Layer.LEVEL_FAR_BG  = -200
Layer.LEVEL_BG      = -100
Layer.LEVEL_DEFAULT  = 0
Layer.LEVEL_FRONT   = 100
Layer.LEVEL_POPUP_DEFAULT   = 1000
Layer.LEVEL_POPUP_NETWORK_LOADING   = 10000
Layer.LEVEL_POPUP_LOCAL_LOADING     = 100000


function Layer.ctor(self)
	self.m_zorder = Layer.LEVEL_DEFAULT

end

function Layer.dtor(self)
	
end

function Layer:loadcreatorLayout(path)
	local creatorReader = creator.CreatorReader:createWithFilename(path)
    creatorReader:setup()
    local scene = creatorReader:getNodeGraph()
    local root = XGUIUtils:seekNodeByName(scene,'root') 
    root:removeFromParent(false)
    self:addChild(root)
    return root
end


function Layer:onTouchesBegan()
	return true
end

function Layer:onTouchesMoved()
end

function Layer:onTouchesEnded()
end

function Layer:onTouchesCancelled()
end

return Layer