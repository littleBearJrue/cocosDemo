--[[--ldoc desc
@module CardLayerView
@author JrueZhu

Date   2018-10-24 10:43:45
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:49:31
]]

local appPath = "app.demo.JrueZhu"
local CardLayerView = class("CardLayerView",cc.load("boyaa").mvc.BoyaaLayout);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local HandCardView = require(appPath..".cardLayer.handCard.HandCardView");
local OutCardView = require(appPath..".cardLayer.outCard.OutCardView");

BehaviorExtend(CardLayerView);


local eventNameConfig = {
	outCard = "outCard",
	grapCard = "grapCard",
}


local relativeLayoutParameterType = {
	[1] = {
		layoutAline = ccui.RelativeAlign.alignParentBottomCenterHorizontal,
		margin = {
			bottom = 120,
		},
	},
	[2] = {
		layoutAline = ccui.RelativeAlign.alignParentTopRight,
		margin = {
			top = 260,
			right = 20,
		},
	},
	[3] = {
		layoutAline = ccui.RelativeAlign.alignParentTopCenterHorizontal,
		margin = {
			top = 100,
		},
	},
	[4] = {
		layoutAline = ccui.RelativeAlign.alignParentTopLeft,
		margin = {
			top = 260,
			left = 20,
		},
	},
}

function CardLayerView:ctor()
	self:setLayoutType(ccui.LayoutType.RELATIVE);
end

local function createOutCardBtn(self)
	local button = ccui.Button:create("Images/JrueZhu/pokerGame/mini_red_btn_short.png", "", "", 0);
	button:setTitleText("出牌")
	button:setTitleFontSize(20)
	local parameter = ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentLeftBottom)
	parameter:setMargin({bottom = 260, left = 120})
	button:setLayoutParameter(parameter);
    button:addTouchEventListener(function(sender, eventType)        
        if (ccui.TouchEventType.began == eventType)  then
        elseif (ccui.TouchEventType.moved == eventType)  then              
        elseif  (ccui.TouchEventType.ended == eventType) then            
	      	local posX, posY = self.ctr.mOutCardView.discard:getPosition();
	 		local point = self.ctr.mOutCardView.discard:getParent():convertToWorldSpace(cc.p(posX, posY));      	
	      	local data = {
	        	seatId = 1, 
				cardByte = self.ctr.mHandCardView[1].ctr.selectCardList[1].cardByte,
				disCardPos = {x = point.x, y = point.y};
	    	}; 
      		self.ctr:dispacherEvent(eventNameConfig.outCard, {outData = data});
        elseif (ccui.TouchEventType.canceled == eventType) then               
        end    
    end)
    return button;
end

local function createGrapCardBtn(self)
	local button = ccui.Button:create("Images/JrueZhu/pokerGame/mini_green_btn_short.png", "", "", 0);
	button:setTitleText("摸牌")
	button:setTitleFontSize(20)
    local parameter = ccui.RelativeLayoutParameter:create()
    parameter:setAlign(ccui.RelativeAlign.alignParentRightBottom)
	parameter:setMargin({bottom = 260, right = 120})
	button:setLayoutParameter(parameter);
    button:addTouchEventListener(function(sender, eventType)        
        if (ccui.TouchEventType.began == eventType)  then
        elseif (ccui.TouchEventType.moved == eventType)  then              
        elseif  (ccui.TouchEventType.ended == eventType) then
        local data = {
        	seatId = self.seatId, 
			cardByte = 0x18,
    	},            
      		self.ctr:dispacherEvent(eventNameConfig.grapCard, {grapData = data});
        elseif  (ccui.TouchEventType.canceled == eventType) then               
        end    
    end)
    return button;
end

function CardLayerView:createView()
	for i = 1, #self.ctr.mHandCardView do
		local parameter = ccui.RelativeLayoutParameter:create()
    	parameter:setAlign(relativeLayoutParameterType[i].layoutAline)
    	parameter:setMargin(relativeLayoutParameterType[i].margin)
    	self.ctr.mHandCardView[i]:setLayoutParameter(parameter)
    	
		self:addChild(self.ctr.mHandCardView[i]);
	end
	local outCardRect = self.ctr.mOutCardView;
	local parameter = ccui.RelativeLayoutParameter:create();
    parameter:setAlign(ccui.RelativeAlign.centerInParent);
    outCardRect:setLayoutParameter(parameter);
	self:addChild(outCardRect);

	self:addChild(createOutCardBtn(self))

	self:addChild(createGrapCardBtn(self))
end

return CardLayerView;
