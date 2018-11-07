--[[--ldoc desc
@module PlayCardCtr
@author ShuaiYang

Date   2018-10-24 10:23:51
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:08:00
]]
local appPath = "app.demo.yangshuai"
local PlayCardCtr = class("PlayCardCtr",cc.load("boyaa").mvc.BoyaaCtr);

local PlayCardView =  require(appPath..".PlayCard.PlayCardView")
local HandCardCtr =  require(appPath..".PlayCard.HandCard.HandCardCtr")
local CardPileCtr =  require(appPath..".PlayCard.CardPile.CardPileCtr")
local EvenConfig =  require(appPath..".PlayCard.EvenConfig")

PlayCardCtr.config = {
	handCardScale = {x = 0.6,y = 0.6},
	cardPileScale = {x = 0.6,y = 0.6},
}

local cardList = {
	[1] = 0x12,
	[2] = 0x21,
	[3] = 0x33,
	[4] = 0x41,
	[5] = 0x13,
	[6] = 0x21,
	[7] = 0x32,
	[8] = 0x43,
	[9] = 0x10,
	[10] = 0x23,
}

function PlayCardCtr:ctor()
	-- body
end


function PlayCardCtr:initView(data)
	-- body
	local playCardView = PlayCardView.new();
	playCardView:bindCtr(self)
	-- playCardView:move(display.center);

	local handCardCtr1 = HandCardCtr.new();
	handCardCtr1:initView(1,true)
	local handCardView1 = handCardCtr1:getView();
	-- handCardView:move(display.center);
	handCardView1:addTo(playCardView);
	handCardView1:setPosition(0,-100)
	handCardView1:setScale(PlayCardCtr.config.handCardScale.x,PlayCardCtr.config.handCardScale.y)

	local handCardCtr2 = HandCardCtr.new();
	handCardCtr2:initView(2,false)
	local handCardView2 = handCardCtr2:getView();
	-- handCardView:move(display.center);
	handCardView2:addTo(playCardView);
	handCardView2:setPosition(120,0)
	handCardView2:setScale(PlayCardCtr.config.handCardScale.x,PlayCardCtr.config.handCardScale.y)


	local handCardCtr3 = HandCardCtr.new();
	handCardCtr3:initView(3,false)
	local handCardView3 = handCardCtr3:getView();
	-- handCardView:move(display.center);
	handCardView3:addTo(playCardView);
	handCardView3:setPosition(0,300)
	handCardView3:setScale(PlayCardCtr.config.handCardScale.x,PlayCardCtr.config.handCardScale.y)

	local handCardCtr4 = HandCardCtr.new();
	handCardCtr4:initView(4,false)
	local handCardView4 = handCardCtr4:getView();
	-- handCardView:move(display.center);
	handCardView4:addTo(playCardView);
	handCardView4:setPosition(-150,0)
	handCardView4:setScale(PlayCardCtr.config.handCardScale.x,PlayCardCtr.config.handCardScale.y)




	local cardPileCtr = CardPileCtr.new();
	cardPileCtr:initView()
	local cardPileView = cardPileCtr:getView();
	-- cardPileView:move(display.center);
	cardPileView:addTo(playCardView);

	cardPileView:setPosition(-50,130)

	cardPileView:setScale(PlayCardCtr.config.cardPileScale.x,PlayCardCtr.config.cardPileScale.y)

	self:initEven()

end

function PlayCardCtr:initEven()
	-- body
	self:bindSelfFun(EvenConfig.chuPai,"chuPai")

end

function PlayCardCtr:faPai()

	self:sendEvenData(EvenConfig.faPai,
				{id = 1,
				cards = {
					0x12,
					0x22,
					0x32,
					0x32,
					0x32,
					0x32,
				},
			});
	self:sendEvenData(EvenConfig.faPai,
				{id = 2,
				cards = {
					0x12,
					0x22,
					0x32,
					0x32,
					0x32,
					0x32,
				},
			});

	self:sendEvenData(EvenConfig.faPai,
				{id = 3,
				cards = {
					0x12,
					0x22,
					0x32,
					0x32,
					0x32,
					0x32,
				},
			});

	self:sendEvenData(EvenConfig.faPai,
				{id = 4,
				cards = {
					0x12,
					0x22,
					0x32,
					0x32,
					0x32,
					0x32,
				},
			});

	
	self:sendEvenData(EvenConfig.diPai,{cardSize = #cardList});
	
	-- body
end

function PlayCardCtr:moPai()
	-- body
	local cardByte = cardList[1];
	self:sendEvenData(EvenConfig.moPai,{data = 1,cardByte = cardByte});
	table.remove(cardList,1);
	self:sendEvenData(EvenConfig.diPai,{cardSize = #cardList});
end

-- byte 牌值  seyle 牌面类型  userId 用户id  animType 动画类型 1出牌 2摸牌
function PlayCardCtr:moPaiAction()
	-- body
	self:getView():cardActionAnim(0x13,1,1,2);
end

--出牌结果
function PlayCardCtr:chuPaiResult(byte)
	-- body
	print("===========PlayCardCtr:chuPaiResult==========="..byte)

	self:sendEvenData(EvenConfig.chuPaiResult,{data = 1,cardByte = byte});
end

--出牌事件响应
function PlayCardCtr:chuPai(event)
	-- body
	if not event._usedata.id and not event._usedata.byte then
		return
	end

	self:getView():cardActionAnim(event._usedata.byte,0,event._usedata.id,1);
		
end


return PlayCardCtr;