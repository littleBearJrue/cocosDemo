

local LayerHint =  class('LayerHint',PopupLayer)


function LayerHint:ctor(data)
    PopupLayer.ctor(self,LayerIds.POPUP_LAYER_TOP_HINT)
    self.m_popupId = LayerIds.POPUP_LAYER_TOP_HINT
    self.m_data = data
    self:init()
    self.m_pListener:setSwallowTouches(false)
    self:enableLayerColor(false)
end

function LayerHint:dtor()
    PopupLayer.dtor(self)
end

function LayerHint:init()
    local txt = ccui.Text:create(self.m_data,"",20)
    self:addChild(txt)
    XGUIUtils:arrangeToTopCenter(txt)
    local action =cc.DelayTime:create(3.0)

    local exitLayer = function ( dt )
        self:exitPopupLayer()
    end

    local actionFunc = cc.CallFunc:create(exitLayer)

    self:runAction(cc.Sequence:create(action,actionFunc))
end


return LayerHint