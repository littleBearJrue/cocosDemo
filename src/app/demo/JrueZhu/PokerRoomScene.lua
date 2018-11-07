--[[--ldoc desc
@module PokerRoomScene
@author JrueZhu

Date   2018-10-25 15:15:14
Last Modified by   JrueZhu
Last Modified time 2018-10-29 17:52:44
]]

local appPath = "app.demo.JrueZhu"
local PokerRoomScene = class("PokerRoomScene", cc.load("mvc").ViewBase);
local CardLayerCtrl = require(appPath..".cardLayer.CardLayerViewCtrl");


local function createRoomBg()
	local bg = cc.Sprite:create("Images/JrueZhu/pokerGame/table_bg.png");
	local visiblieSize = cc.Director:getInstance():getVisibleSize()
    local spriteContentSize = bg:getTextureRect()
    bg:setPosition(visiblieSize.width/2, visiblieSize.height/2)
    bg:setScaleX(visiblieSize.width/spriteContentSize.width)
    bg:setScaleY(visiblieSize.height/spriteContentSize.height)
	return bg;
end

local function createCardLayer()
	local dealData = {
		[1] = {
			[1] = {cardByte = 0x11, cardStyle = "liang"},
			[2] = {cardByte = 0x12, cardStyle = "liang"},
			[3] = {cardByte = 0x01, cardStyle = "liang"},
			[4] = {cardByte = 0x21, cardStyle = "liang"},
			[5] = {cardByte = 0x31, cardStyle = "liang"},
			[6] = {cardByte = 0x07, cardStyle = "liang"},
		},
		[2] = {
			[1] = {cardByte = 0x11, cardStyle = "an"},
			[2] = {cardByte = 0x12, cardStyle = "an"},
			[3] = {cardByte = 0x01, cardStyle = "an"},
			[4] = {cardByte = 0x21, cardStyle = "an"},
			[5] = {cardByte = 0x31, cardStyle = "an"},
			[6] = {cardByte = 0x07, cardStyle = "an"},
		},
		[3] = {
			[1] = {cardByte = 0x11, cardStyle = "an"},
			[2] = {cardByte = 0x12, cardStyle = "an"},
			[3] = {cardByte = 0x01, cardStyle = "an"},
			[4] = {cardByte = 0x21, cardStyle = "an"},
			[5] = {cardByte = 0x31, cardStyle = "an"},
			[6] = {cardByte = 0x07, cardStyle = "an"},
			[7] = {cardByte = 0x11, cardStyle = "an"},
			[8] = {cardByte = 0x12, cardStyle = "an"},
			[9] = {cardByte = 0x01, cardStyle = "an"},
			[10] = {cardByte = 0x21, cardStyle = "an"},
			[11] = {cardByte = 0x31, cardStyle = "an"},
			[12] = {cardByte = 0x07, cardStyle = "an"},
		},
		[4] = {
			[1] = {cardByte = 0x11, cardStyle = "an"},
			[2] = {cardByte = 0x12, cardStyle = "an"},
			[3] = {cardByte = 0x01, cardStyle = "an"},
			[4] = {cardByte = 0x21, cardStyle = "an"},
			[5] = {cardByte = 0x31, cardStyle = "an"},
			[6] = {cardByte = 0x07, cardStyle = "an"},
		},
	}
	local cardPools = {
		[1] = 0x11,
		[2] = 0x12, 
		[3] = 0x01,
		[4] = 0x21,
		[5] = 0x31,
		[6] = 0x07,
		[7] = 0x21,
		[8] = 0x33,
	
	}
	local discards = {
		[1] = 0x07,
		[2] = 0x21,
		[3] = 0x33,
	}
	local cardLayerCtrl = CardLayerCtrl:create();
	cardLayerCtrl:initView();
	cardLayerCtrl:dealCards(dealData);
	cardLayerCtrl:dealOutCards(cardPools);
	cardLayerCtrl:updateDiscard(discards);
	local cardLayerView = cardLayerCtrl:getView();
	local visiblieSize = cc.Director:getInstance():getVisibleSize();
	cardLayerView:setPosition(visiblieSize.width/2, visiblieSize.height/2)
	cardLayerView:setAnchorPoint(0.5, 0.5)
	cardLayerView:setContentSize(cc.size(visiblieSize.width, visiblieSize.height));
	return cardLayerView;
end

local function createBeginBtn(scene)
	local button = ccui.Button:create("Images/JrueZhu/btn_play.png", "", "", 0);
    button:move(display.cx, display.cy)
    button:addTouchEventListener(function(sender, eventType)        
        if (ccui.TouchEventType.began == eventType)  then
        elseif (ccui.TouchEventType.moved == eventType)  then              
        elseif  (ccui.TouchEventType.ended == eventType) then            
      		scene:addChild(createCardLayer())
      		button:setVisible(false);
        elseif  (ccui.TouchEventType.canceled == eventType) then               
        end    
    end)
    return button;
end

function PokerRoomScene:main()
	local scene = cc.Scene:create();

	scene:addChild(createRoomBg());
	scene:addChild(createBeginBtn(scene))
	scene:addChild(CreateBackMenuItem())

	return scene;
end

return handler(PokerRoomScene, PokerRoomScene.main)