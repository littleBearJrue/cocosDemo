--[[--ldoc desc
@module OutCardView
@author JrueZhu

Date   2018-10-24 10:39:45
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:49:13
]]


local OutCardView = class("OutCardView",cc.load("boyaa").mvc.BoyaaLayout);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local SingleCardView = require("app.demo.JrueZhu.cardLayer.singleCard.SingleCardView")

BehaviorExtend(OutCardView);

function OutCardView:ctor( ... )
	self:setContentSize(160, 140)
	self:setBackGroundColorType(1);
	self:setBackGroundColor(cc.c3b(251, 151, 51))
	self:setLayoutType(ccui.LayoutType.HORIZONTAL)

	self:initView();
end

local function createRemainLayout(self)
	local remainLayout = ccui.Layout:create();
	remainLayout:setContentSize(80, 140)
	remainLayout:setBackGroundColorType(1);
	remainLayout:setBackGroundColor(cc.c3b(25, 121, 15))
	remainLayout:setLayoutType(ccui.LayoutType.RELATIVE);

	local remainCardNum = ccui.Text:create("0张","Arial",20);
	local cparameter = ccui.RelativeLayoutParameter:create()
	cparameter:setRelativeName("number")
    cparameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)

    remainCardNum:setLayoutParameter(cparameter)
	self.remainCardNum = remainCardNum;
	self.remainCardNum:setColor(cc.c3b(255,255,255));
	remainLayout:addChild(self.remainCardNum);

	local remainCardRect = ccui.ImageView:create("Images/JrueZhu/PokerGame/poker_cover.png");
	local aparameter = ccui.RelativeLayoutParameter:create()
	aparameter:setRelativeToWidgetName("number")
    aparameter:setAlign(ccui.RelativeAlign.locationBelowCenter)
    remainCardRect:setLayoutParameter(aparameter)
    remainCardRect:setScale(0.7)
    remainLayout:addChild(remainCardRect);

	local remainCard = ccui.ImageView:create("Images/JrueZhu/PokerGame/poker_back_blue.png");
	self.remainCard = remainCard;
	local bparameter = ccui.RelativeLayoutParameter:create()
	bparameter:setRelativeToWidgetName("number")
    bparameter:setAlign(ccui.RelativeAlign.locationBelowCenter)
    bparameter:setMargin({top = 8})
    remainCard:setLayoutParameter(bparameter)
    remainCard:setScale(0.6)
	remainLayout:addChild(remainCard);
	remainCard:setVisible(false);

	return remainLayout;
end

local function createDisCardLayout(self)
	local discardLayout = ccui.Layout:create();
	discardLayout:setContentSize(80, 140)
	discardLayout:setBackGroundColorType(1);
	discardLayout:setBackGroundColor(cc.c3b(35, 101, 55))
	discardLayout:setLayoutType(ccui.LayoutType.RELATIVE);
	local discardLabel = ccui.Text:create("弃牌区","Arial",20);
	local cparameter = ccui.RelativeLayoutParameter:create()
	cparameter:setRelativeName("number")
    cparameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)
    discardLabel:setLayoutParameter(cparameter)
	discardLabel:setColor(cc.c3b(255,255,255));
	discardLayout:addChild(discardLabel);

	local discardRect = ccui.ImageView:create("Images/JrueZhu/PokerGame/poker_cover.png");
	local aparameter = ccui.RelativeLayoutParameter:create()
    aparameter:setRelativeToWidgetName("number")
    aparameter:setAlign(ccui.RelativeAlign.locationBelowCenter)
    discardRect:setLayoutParameter(aparameter)
    discardRect:setScale(0.7)
    discardLayout:addChild(discardRect);

	local discard = self:createOneCard({cardByte = 0x11, cardStyle = "liang"});
	self.discard = discard;
	local bparameter = ccui.RelativeLayoutParameter:create()
    bparameter:setRelativeToWidgetName("number")
    bparameter:setMargin({top = 8})
    bparameter:setAlign(ccui.RelativeAlign.locationBelowCenter)
    discard:setLayoutParameter(bparameter)
    discard:setScale(0.6)
	discardLayout:addChild(discard);
	discard:setVisible(false);
	self.discardLayout = discardLayout;
	return discardLayout;
end

function OutCardView:initView()
	
    self:addChild(createRemainLayout(self));
    self:addChild(createDisCardLayout(self));
end

function OutCardView:createOneCard(data)
	local card = SingleCardView:create({cardByte = data.cardByte, cardStyle = data.cardStyle});
	return card;
end

--[[
	更新牌墙显示
--]]
function OutCardView:updateRemainCardView()
	local remainCardCount = self.ctr.remainCardsNum;
	if remainCardCount > 0 then
		self.remainCard:setVisible(true);
	else
		self.remainCard:setVisible(false);
	end
	-- 更新牌张的显示
	self.remainCardNum:setString(string.format("%d张", remainCardCount));
end

--[[
	更新弃牌区显示
--]]
function OutCardView:updateDiscardView()
	local cardList = self.ctr.discardList;
	self.discard.cardByte = cardList[#cardList];
	self.discard:setVisible(true);
end

return OutCardView;
