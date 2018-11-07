local Layer = require("dev.demo.scenes.layers.Layer")
require("dev.demo.scenes.layers.LayerIds")

 local winSize = cc.Director:getInstance():getWinSize()
 cc.exports.PopupLayer = class("PopupLayer",Layer)

PopupLayer.POPUP_STYLE_ONE = 1
PopupLayer.POPUP_STYLE_TWO = 2
PopupLayer.POPUP_STYLE_THREE = 3
PopupLayer.POPUP_STYLE_FOUR = 4

function PopupLayer:ctor(popupId)
	self.m_zorder = Layer.LEVEL_POPUP_DEFAULT
	self:setLocalZOrder(self.m_zorder)

	self.m_popupId = popupId
	
	self:setContentSize(winSize)

    
    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(self.onTouchesBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(self.onTouchesMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(self.onTouchesEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self.m_pListener:registerScriptHandler(self.onTouchesCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)

	--[[self.m_keepPopupIDs = {
		LayerIds.POPUP_LAYER_SHOP,
	}]]
	self.m_colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), winSize.width, winSize.height)
    self.m_colorLayer:setCascadeColorEnabled(false)

   -- layer1:setPosition( cc.p(display.cx, display.cy))
    self:addChild(self.m_colorLayer,-1)

end

function PopupLayer:dtor()
	self:unregisterEvent()
   -- Layer.dtor(self)
end

function PopupLayer:registerEvent()
	LogicSys:regEventHandler(LogicEvent.EVENT_ON_BACK_PRESSED, self.onBackPressed, self,XGEventPriority.HIGH)
end

function PopupLayer:unregisterEvent()
	LogicSys:unregEventHandler(LogicEvent.EVENT_ON_BACK_PRESSED, self.onBackPressed, self,XGEventPriority.HIGH)
end

function PopupLayer:enableTouchBlackExit(bEnable)

end

function PopupLayer:enableLayerColor(bEnable)
	self.m_colorLayer:setVisible(bEnable)
end


function PopupLayer:onBackPressed()
	self:exitPopupLayer()
	return true
end


function PopupLayer:doExitPopupLayer()
   --[[local isKeep = false
    for i = 1, #self.m_keepPopupIDs do
	    if self.m_popupId == self.m_keepPopupIDs[i] then
		isKeep = true 
		 break
		end 
	end]]

    --if isKeep then
	    --ViewSys:onEvent(TPViewEvent.EVENT_POPUPLAYER_EXIT,self.m_popupId, true)
	--else
        ViewSys:onEvent(ViewEvent.EVENT_POPUPLAYER_EXIT,self.m_popupId)
        
		--self:dtor()
		deleteWithChildren(self)
	    self:removeFromParent()
		
		
		
	--end
end


function PopupLayer:exitPopupLayer(style)
   --[[ local isKeep = false
	local isPlayCloseEffect = true
    for i = 1, #self.m_keepPopupIDs do
	    if self.m_popupId == self.m_keepPopupIDs[i] then
		isKeep = true 
		 break
		end 
	end
	for i = 1, #self.m_noCloseEffect do
	    if self.m_popupId == self.m_noCloseEffect[i] then
		isPlayCloseEffect = false 
		 break
		end 
	end

	if not isKeep and self.m_isExiting then
		return 
	else
		self.m_isExiting = true
	end]]
    self:unregisterEvent()
	self.m_popStyle = style or self.m_popStyle
	if self.m_popStyle == PopupLayer.POPUP_STYLE_ONE then
		self:exitPopupStyleOne()
	elseif self.m_popStyle == PopupLayer.POPUP_STYLE_TWO then
		self:exitPopupStyleTwo()
	elseif self.m_popStyle == PopupLayer.POPUP_STYLE_THREE then
		self:exitPopupStyleThree()
	else
		self:doExitPopupLayer()
	end
	
end


function PopupLayer:exitPopupStyleOne()
	local scaleTo = cc.ScaleTo:create(0.1,0.0,0.0)
	local fadeTo  = cc.FadeTo:create(0.1,0.5)
	local spawn   = cc.Spawn:create(scaleTo,fadeTo)
	
	local actionFunc = cc.CallFunc:create(
		function()
		self:doExitPopupLayer()
		end
	)
	local sequnce = cc.Sequence:create(spawn,actionFunc)
	
	self:runAction(sequnce)
	
end


function PopupLayer:exitPopupStyleTwo()

	local fadeTo  = cc.FadeTo:create(0.1,120)
	
	local actionFunc = cc.CallFunc:create(self,
		function()
		self:doExitPopupLayer()
		end
	)
	local sequnce = cc.Sequence:create(fadeTo,actionFunc)
	
	self:runAction(sequnce)
	
end


function PopupLayer:exitPopupStyleThree()

	local fadeTo  = cc.FadeTo:create(0.05,50)
	
	local actionFunc = cc.CallFunc:create(
		function()
		    self:doExitPopupLayer()
		end
	)
	local sequnce = cc.Sequence:create(fadeTo,actionFunc)
	
	self:runAction(sequnce)

end


function PopupLayer:runPopupStyleOne()

	
	local time = 0.2

	local scaleTo = cc.EaseBackOut.create(cc.ScaleTo:create(time,1.0,1.0))
	local fadeTo  = cc.FadeTo:create(time,255)
	local spawn   = cc.Spawn:create(scaleTo,fadeTo)
	
	self:setScale(0.4,0.4)
	self:setOpacity(128)
	self:runAction(spawn)
end

function PopupLayer:runPopupStyleTwo()

	self:setOpacity(100)
	
	local fadeTo  = cc.FadeTo:create(0.15,255)
	local spawn   = cc.Spawn:create(fadeTo)

	self:runAction(spawn)
end



function PopupLayer:runPopupStyleThree()
	self:runPopupStyleOne()
end

function PopupLayer:runPopupStyleFour()	
	--local node = self:createBlurNode()
	--self:add(node)
end

function PopupLayer:runPopupStyle(style)
	self.m_popStyle = style
	self:unregisterEvent()
	self:registerEvent()

	if style == PopupLayer.POPUP_STYLE_ONE then
		self:runPopupStyleOne()
	elseif style == PopupLayer.POPUP_STYLE_TWO then
		self:runPopupStyleTwo()
	elseif style == PopupLayer.POPUP_STYLE_THREE then
		self:runPopupStyleThree()
	elseif style == PopupLayer.POPUP_STYLE_FOUR then
		self:runPopupStyleFour()
	else
	end
end






return PopupLayer