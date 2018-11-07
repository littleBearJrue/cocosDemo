--[[--ldoc desc
@module CardPileView
@author ShuaiYang

Date   2018-10-25 16:05:54
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:07:52
]]
local appPath = "app.demo.yangshuai"
local CardPileView = class("CardPileView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local CardView = require(appPath..".PlayCard.CardView")
local resRootPath = "Images/yangshuai/";

BehaviorExtend(CardPileView);

CardPileView.config = {
	cardScale = {x = 0.5, y = 0.5}, --缩放
	isShowCard = false,--是否显示手牌
}



local function initView(self)
	-- body


end

function CardPileView:ctor()
  
    self.cards = {};
    
    self.bgSprite = ccui.ImageView:create(resRootPath.."pile/bg.png")
    local seize = self.bgSprite:getContentSize()
	self:setContentSize(seize)
	self.bgSprite:setAnchorPoint(0,0)
	
	self.bgSprite:addTo(self)

	

	self.text = ccui.Text:create()
    self.text:setText("我是组件");
    self.text:setPosition(50,seize.height+10)
  	self.text:addTo(self)
	-- self.bgSprite:move(display.center);

	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self:setBackGroundColor(cc.c3b(193, 193, 32))
end

function CardPileView:setText( str )
	if str and type(str) == "string" then
		self.text:setText(str)
	end

end


function CardPileView:addCard(data)
	-- body
	if CardPileView.config.isShowCard then
		self.bgSprite:removeAllChildren();
		if data and data.byte then
			local card  = CardView:create()
			card.cardTByte = data.byte;
			card.cardStyle = 0;
			card:setScale(CardPileView.config.cardScale.x,CardPileView.config.cardScale.y);
			card:setPosition(3,3)
			card:addTo(self.bgSprite);
		end
		
	else
		local count = self.bgSprite:getChildrenCount();
		print("======CardPileView:addCard======="..count)
		if count >= 2 then
		
		else
			local card  = CardView:create()
			card.cardStyle = 1;
			card:setScale(CardPileView.config.cardScale.x,CardPileView.config.cardScale.y);
			card:setPosition(3,3)
			card:addTo(self.bgSprite);

		end
		
		
	end
	
	

end



return CardPileView;