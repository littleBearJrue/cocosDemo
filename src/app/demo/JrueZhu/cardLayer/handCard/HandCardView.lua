--[[--ldoc desc
@module HandCardView
@author JrueZhu

Date   2018-10-24 10:34:05
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:56:26
]]

local HandCardView = class("HandCardView",cc.load("boyaa").mvc.BoyaaLayout);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local SingleCardView = require("app.demo.JrueZhu.cardLayer.singleCard.SingleCardView")

BehaviorExtend(HandCardView);

function HandCardView:ctor(data)
	self:setContentSize(240, 120)
	-- self:setBackGroundColorType(1);
	-- self:setBackGroundColor(cc.c3b(51, 51, 51))
	self:setLayoutType(ccui.LayoutType.RELATIVE)
end

function HandCardView:createView( ... )

end

local function getNumImgPath(num)
	local imgBase = "Images/JrueZhu/pokerGame/";
	local firstImgPath;
	local secondImgPath;
	if num >= 0 and num <= 9 then
		firstImgPath = "Images/JrueZhu/pokerGame/score_win_0.png";
		secondImgPath = string.format("Images/JrueZhu/pokerGame/score_win_%d.png", num);
	elseif num > 9 then
		local firstNum, secondNum = math.modf(num / 10);
		firstImgPath = string.format("Images/JrueZhu/pokerGame/score_win_%d.png", firstNum);
		secondImgPath = string.format("Images/JrueZhu/pokerGame/score_win_%d.png", secondNum);
	end
	return firstImgPath, secondImgPath;
end

local function createCardNumImg(self)
	local horizontalLayout = ccui.Layout:create():setLayoutType(ccui.LayoutType.HORIZONTAL);
	self.firthImg = ccui.ImageView:create();
	self.secondImg = ccui.ImageView:create();
	self.thirdImg = ccui.ImageView:create();
	horizontalLayout:addChild(self.firthImg);
	horizontalLayout:addChild(self.secondImg);
	horizontalLayout:addChild(self.thirdImg);

	 local parameter = ccui.RelativeLayoutParameter:create()

	parameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	parameter:setMargin({ left = 5, top = 5 } )
	horizontalLayout:setLayoutParameter(parameter)
	horizontalLayout:setScale(0.5)
	local tParameter = ccui.RelativeLayoutParameter:create()
    tParameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
    tParameter:setMargin({left = 5, bottom = 5})
    horizontalLayout:setLayoutParameter(tParameter)
	horizontalLayout:setScale(0.8);
	self:updataCardNum();
	return horizontalLayout;
end

function HandCardView:createOneCard(data)
	local card = SingleCardView:create({cardByte = data.cardByte, cardStyle = data.cardStyle});
	table.insert(self.ctr.handCardList, card);
	return card;
end


function HandCardView:createHandCards(data)
	for i, v in ipairs(data) do
		local card = self:createOneCard(v)
      	local parameter = ccui.RelativeLayoutParameter:create()
	    parameter:setAlign(ccui.RelativeAlign.alignParentLeftBottom)
	    parameter:setMargin({left = 20*(i - 1), bottom = 5})
	    card:setLayoutParameter(parameter)
		card:setScale(0.6);
		self:addChild(card);
		
		self:executeDealCardAnim(card);
	end
	local cardNumLabel = createCardNumImg(self);
	self:addChild(cardNumLabel)
end

function HandCardView:executeDealCardAnim(card)
	card:setVisible(false);
	local function dealCardAnimFunc()
		card:setVisible(true);
	end
	card:runAction(cc.Sequence:create(cc.Blink:create(1, 1), cc.CallFunc:create(dealCardAnimFunc)))
end

local function getOutCardIndex(handCardList, selectedCardByte)
	local cardIndex;
	for i, card in ipairs(handCardList) do
		if card.cardByte == selectedCardByte then
			cardIndex = i;
			break;
		end
	end
	return cardIndex;
end

function HandCardView:executeOutCardAnim(data)
	-- 找到选中的位置点，之后对此牌移除处理
	local cardIndex = getOutCardIndex(self.ctr.handCardList, data.cardByte);
	-- 找到了位置点那就说明这就是要出的牌
	if cardIndex then
		local outCard = self.ctr.selectCardList[1];
		local disCardX = data.disCardPos.x;
		local disCardY = data.disCardPos.y;
		local outCardPosX, outCardPosY = outCard:getPosition();
		local point = outCard:getParent():convertToWorldSpace(cc.p(outCardPosX, outCardPosY));
		local offsetX = disCardX - point.x;
		local offsetY = disCardY - point.y;

		local function outCardAnimFunc()
			table.remove(self.ctr.handCardList, cardIndex);
			outCard:removeFromParent();
			self.ctr.selectCardList = {}
			self:updataCardNum();
    	   	self:updateCardPos();
    	   	local data = {outCard.cardByte};
    	   	self.ctr:sendEvenData("outCardUpdateDisCard", {discardData = data});
		end
		outCard:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(offsetX, offsetY)), cc.CallFunc:create(outCardAnimFunc)))
	end
end


function HandCardView:updataCardNum()
	local cardCount = #self.ctr.handCardList;
	local firstNumPath, secondNumPath = getNumImgPath(cardCount);
	local signalPath = "Images/JrueZhu/pokerGame/score_win_times.png"
	self.firthImg:loadTexture(signalPath);
	self.secondImg:loadTexture(firstNumPath);
	self.thirdImg:loadTexture(secondNumPath);
end

function HandCardView:updateCardPos()
	for i, card in ipairs(self.ctr.handCardList) do
		local parameter = card:getLayoutParameter();
		parameter:setMargin({left = 20*(i - 1), bottom = 5});
		card:setLayoutParameter(parameter)
		self:requestDoLayout()
	end
end

function HandCardView:turnCardPos(card, moveType)
	local parameter = card:getLayoutParameter();
	local margin = parameter:getMargin()
	if moveType == "out" then
		margin.bottom = (margin.bottom or 0) + 15
	elseif moveType == "in" then
		margin.bottom = (margin.bottom or 0) - 15
	end
	parameter:setMargin(margin)
	card:getParent():requestDoLayout()
end

return HandCardView;
