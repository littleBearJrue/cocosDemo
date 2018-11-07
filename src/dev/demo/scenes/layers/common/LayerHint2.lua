

local LayerHint2 =  class('LayerHint2',PopupLayer)


function LayerHint2:ctor(data)
    PopupLayer.ctor(self,LayerIds.POPUP_LAYER_TOP_HINT2)
    self.m_popupId = LayerIds.POPUP_LAYER_TOP_HINT2
    self.m_data = data
    self:init()
    --self.m_pListener:setSwallowTouches(false)
    --self:enableLayerColor(false)
end

function LayerHint2:dtor()
    PopupLayer.dtor(self)
end

function LayerHint2:init()

    local sprite = cc.Sprite:create("tex/common/ui_frame_01.png")
    sprite:setContentSize(750,347)
    self:addChild(sprite)
    XGUIUtils:arrangeToCenter(sprite)
    

    local txt = ccui.Text:create(self.m_data,"",26)
    sprite:addChild(txt)
    XGUIUtils:arrangeToCenter(txt,0,20)



    local button = ccui.Button:create("tex/common/ui_button_02.png")
    button:setTitleText("确定")
    button:setTitleFontSize(26)
    button:setTitleColor(cc.c3b(0,0,0))
    sprite:addChild(button)
    XGUIUtils:arrangeToBottomCenter(button,0,20)


   --[[ local txt2 = ccui.Text:create("确定","",20)
    button:addChild(txt2)
    XGUIUtils:arrangeToCenter(txt2)]]

    button:setPressedActionEnabled(true)
    button:addClickEventListener(function(sender)
        self:exitPopupLayer()
    end)

end


return LayerHint2