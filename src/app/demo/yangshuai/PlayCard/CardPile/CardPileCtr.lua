--[[--ldoc desc
@module CardPileCtr
@author ShuaiYang

Date   2018-10-25 16:07:31
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:07:50
]]
local appPath = "app.demo.yangshuai"
local CardPileCtr = class("CardPileCtr",cc.load("boyaa").mvc.BoyaaCtr);
local CardPileView =  require(appPath..".PlayCard.CardPile.CardPileView")

local EvenConfig =  require(appPath..".PlayCard.EvenConfig")


function CardPileCtr:ctor()
  	print("HandCardCtr");
    self.cards = {};
end


function CardPileCtr:initView(data)
	-- body
	local node = ccui.Layout:create();
  	node:setLayoutType(ccui.LayoutType.HORIZONTAL);
  	

	self.baseCardPile = CardPileView.new();
	self.baseCardPile:bindCtr(self)
	self.baseCardPile:addCard();
  	self.baseCardPile:addTo(node)
  	self.baseCardPile:setText("0张")

	self.playCardPile = CardPileView.new();
	self.playCardPile:bindCtr(self)
	self.playCardPile.config.isShowCard = true;
  	self.playCardPile:addTo(node)
	self.playCardPile:addCard({byte = 0x12});
	self.playCardPile:setText("弃牌区")


	self:setView(node)
	self:initEven()

end



function CardPileCtr:initEven()
	-- body
	self:bindSelfFun(EvenConfig.chuPaiResult,"chuPaiResult")
	self:bindSelfFun(EvenConfig.diPai,"diPaiResult")

end

function CardPileCtr:diPaiResult( event )
	-- body
	if event._usedata.cardSize then
		local str = string.format("%d张", event._usedata.cardSize)
		self.baseCardPile:setText(str)
	end
end
function CardPileCtr:chuPaiResult(event)
	-- body
	print("===========CardPileCtr:chuPaiResult========ent._usedata.byte==="..event._usedata.cardByte)
	if not event._usedata.id and not event._usedata.cardByte  then
		return
	end

	self.playCardPile:addCard({byte = event._usedata.cardByte})
end


return CardPileCtr;