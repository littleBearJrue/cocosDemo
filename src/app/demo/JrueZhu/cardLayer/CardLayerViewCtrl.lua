--[[--ldoc desc
@module CardLayerViewCtrl
@author JrueZhu

Date   2018-10-24 10:48:49
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:50:32
]]

local appPath = "app.demo.JrueZhu"
local CardLayerViewCtrl = class("CardLayerViewCtrl",cc.load("boyaa").mvc.BoyaaCtr);
local CardLayerView = require(appPath..".cardLayer.CardLayerView");
local HandCardViewCtrl = require(appPath..".cardLayer.handCard.HandCardViewCtrl");
local OutCardViewCtrl = require(appPath..".cardLayer.outCard.OutCardViewCtrl");


local EventFuncConfig = {
	outCard = "executeOutCard",
	grapCard = "executeGrapCard",
	outCardUpdateDisCard = "updateDiscardAfterOutCard",
}

function CardLayerViewCtrl:ctor( ... )
	self:registerEventListener();

	-- 将节点通过view层加进cardLayerView中
	local cardLayerView = CardLayerView:create();
	cardLayerView:bindCtr(self);
	-- 初始化数据
	self:initConfig();
end

--[[
	注册event事件，此时不需要解绑事件，框架已做处理
--]]
function CardLayerViewCtrl:registerEventListener()
	for name, func in pairs(EventFuncConfig) do
		self:bindSelfFun(name, func)
	end
end

function CardLayerViewCtrl:dispacherEvent(eventName, data)
	self:sendEvenData(eventName, data);
end

function CardLayerViewCtrl:initConfig()
	if self.mHandCardView then
		for i, v in ipairs(self.handCardList) do
			v:removeSelf(true)
		end
	end
	if self.mOutCardView then
		for i, v in pairs(self.mOutCardView) do
			v:removeSelf(true)
		end
	end

	-- 玩家手牌数据表
	self.mHandCardView = {};


	for i = 1, 4 do
		local handCardViewCtrl = HandCardViewCtrl:create();
		self.mHandCardView[i] = handCardViewCtrl:getView();
	end
	-- 牌墙/弃牌池数据表
	local outCardViewCtrl = OutCardViewCtrl:create();
	self.mOutCardView = outCardViewCtrl:getView();

	self.view:createView();

	 -- 做事件的吞噬工作，避免事件传递下去
	-- local function onTouchBegan(touch, event)
	-- 	return true
	-- end
	-- local function onTouchMoved(touch, event)
	-- end
	-- local function onTouchEnded(touch, event)
	-- end
	
	-- local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(true)
	-- listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
 --    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
 --    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	-- local eventDispatcher = self.view:getEventDispatcher()
	-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.view) 
end

--[[
	模拟发牌
--]]
function CardLayerViewCtrl:dealCards(data)
	for i, cardData in ipairs(data) do
		cardData.seatId = i;
		self.mHandCardView[i].ctr:dealCard(cardData);
	end
end

--[[
	发牌墙的牌
--]]
function CardLayerViewCtrl:dealOutCards(data)
	self.mOutCardView.ctr:dealCard(data);
end


function CardLayerViewCtrl:updateDiscard(data)
	self.mOutCardView.ctr:updateDiscard(data);
end

--[[
	模拟出牌
--]]
function CardLayerViewCtrl:executeOutCard(event)
	local outCardData = event._usedata.outData;
	self.mHandCardView[outCardData.seatId].ctr:outCard(outCardData);

end

--[[
	模拟抓牌
--]]
function CardLayerViewCtrl:executeGrapCard(event)

end

--[[
	模拟出牌后更新弃牌池的显示
--]]
function CardLayerViewCtrl:updateDiscardAfterOutCard(event)
	self:updateDiscard(event._usedata.discardData)
end


return CardLayerViewCtrl;