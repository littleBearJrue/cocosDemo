
require("dev.demo.scenes.layers.common.HintManager")

require("dev.demo.scenes.layers.PopupLayer")


cc.exports.LayerManager = class("LayerManager")

function LayerManager.getInstance()
	if not LayerManager.s_layerManager then
		LayerManager.s_layerManager = LayerManager:create()
	end
	return LayerManager.s_layerManager
end


function LayerManager:ctor()

	HintManager.getInstance()
	self.m_popupLayers = {}
	ViewSys:regEventHandler(ViewEvent.EVENT_POPUPLAYER_EXIT,self.onEventPopupLayerExit,self)
	ViewSys:regEventHandler(ViewEvent.EVENT_LAYER_POPUP_LOADING,self.onEventPopupLayerLoading,self)

	ViewSys:regEventHandler(ViewEvent.EVENT_LAYER_POPUP_COMMON_TOP_HINT,self.onEventPopupCommonTopHint,self)
	ViewSys:regEventHandler(ViewEvent.EVENT_LAYER_POPUP_COMMON_HINT2,self.onEventPopupCommonHint2,self)

end


function LayerManager:dtor()
	ViewSys:unregEventHandler(ViewEvent.EVENT_POPUPLAYER_EXIT,self.onEventPopupLayerExit,self)
	ViewSys:unregEventHandler(ViewEvent.EVENT_LAYER_POPUP_LOADING,self.onEventPopupLayerLoading,self)

	ViewSys:unregEventHandler(ViewEvent.EVENT_LAYER_POPUP_COMMON_TOP_HINT,self.onEventPopupCommonTopHint,self)
	ViewSys:unregEventHandler(ViewEvent.EVENT_LAYER_POPUP_COMMON_HINT2,self.onEventPopupCommonHint2,self)
end

function LayerManager:getCurScene()
	return cc.Director:getInstance():getRunningScene()
end

function LayerManager:isShowing(layerId)
	if layerId then
		return self.m_popupLayers[layerId]
	end
	return false
end

function LayerManager:addLayer(layer)
	if not self:isShowing(layer.m_popupId) then
		self:getCurScene():add(layer)
		if layer.m_popupId then
			self.m_popupLayers[layer.m_popupId] = layer
		end
	else
		if self.m_popupLayers[layer.m_popupId]:isAutoHide() then
			self.m_popupLayers[layer.m_popupId]:doExitPopupLayer()
			self:getCurScene():add(layer)
			self.m_popupLayers[layer.m_popupId] = layer
		end
		
	end
end

function LayerManager:exitAllLayers()

	for k,v in pairs(self.m_popupLayers) do
		v:doExitPopupLayer()
	end
end

function LayerManager:onEventPopupLayerExit(layerId, isKeep)
	if layerId then
	    if isKeep then
		    self.m_popupLayers[layerId]:setVisible(false)
		else
		    self.m_popupLayers[layerId] = nil
		end
	end
end

function LayerManager:onEventPopupLayerLoading(data)
	local layer = TPLayerLoading.create(data)
	self:addLayer(layer)
end



function LayerManager:onEventPopupCommonTopHint(data)
	local layer = LayerHint:create(data)
	self:addLayer(layer)
end

function LayerManager:onEventPopupCommonHint2(data)
	local layer = LayerHint2:create(data)
	self:addLayer(layer)
end



return LayerManager
