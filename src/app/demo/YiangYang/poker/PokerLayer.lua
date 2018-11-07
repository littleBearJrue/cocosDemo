-- @Author: YiangYang
-- @Date:   2018-10-24 09:52:58
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 17:13:31
local PokerLayer = class("PokerLayer",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend

local HandCardView = require("app.demo.YiangYang.poker.HandCardView")
-- local HandCardViewCtr = require("app.YiangYang.poker.HandCardViewCtr")
local OutCardView = require("app.demo.YiangYang.poker.OutCardView")
-- local OutCardViewCtr = require("app.YiangYang.poker.OutCardViewCtr")

local DiPaiView = require("app.demo.YiangYang.poker.DiPaiView")

BehaviorExtend(PokerLayer)
local ImageRoot = "yiang/cangkulan/"

--手牌位置
local Config = {
	startX_1_3 = 130,
	startY_1 = 200,
	startY_3 = display.height-50,

	startX_2 = display.width-220,
	startX_4 = 20,
	startY_2_4 = display.cy+200
}

function PokerLayer:ctor( ... )
	self.handCardViewTb = {}	--手牌view集合
	self.outCardList = {}		--出牌牌值
	self.remainNum = 0			--底牌剩余数量（未摸）
	self:initLayout()
end

function PokerLayer:initLayout()
	--相对布局
	-- self:setLayoutType(ccui.LayoutType.RELATIVE)
	--牌桌背景
	local room_bg = ccui.ImageView:create(ImageRoot.."room_bg.png")
	-- self:setContentSize(room_bg:getContentSize())
	room_bg:setAnchorPoint(0,0)

	self:addChild(room_bg)
	local table_bg = ccui.ImageView:create(ImageRoot.."table_bg.png")
	table_bg:setAnchorPoint(0,0)
	self:addChild(table_bg)
	

	-- --中间区域
	self.outCardView = OutCardView.new()
	self.outCardView:bindCtrClass(OutCardViewCtr)
	self.outCardView:setAnchorPoint(0.5,0.5)
	self.outCardView:move(display.cx,display.cy)

	self:addChild(self.outCardView)

	--Test Start---
	local function dealCardTest()
		dump("dealCardTest")
		local myEvent = cc.EventCustom:new("DealCardEvent")
		myEvent.dealData = {
						{0x11,0x12,0x11,0x31,0x21,0x13,0x32,0x22},
						-- {0x11,0x11,0x14,0x15,0x16,0x17,0x18,0x19,},
						-- {0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,},
						{0x11,0x12,0x11,0x11,0x11,0x11,0x11,0x11,},
						{0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,},
						{0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,}
		}
		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
       	customEventDispatch:dispatchEvent(myEvent)
	end 

	local function outCardTest()
		dump("outCardTest")
		local myEvent = cc.EventCustom:new("OutCardEvent")
		local data = {}
		data.seatID = 4
		data.cardTByte = 0x11

		myEvent.outData = data

		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
       	customEventDispatch:dispatchEvent(myEvent)
	end 

	local function grabCardTest()
		dump("grabCardTest")
		local myEvent = cc.EventCustom:new("GrabCardEvent")
		local data = {}
		data.seatID = 4
		data.cardTByte = 0x11

		myEvent.grabData = data
		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
       	customEventDispatch:dispatchEvent(myEvent)
	end 


	--发牌
	local dealBtn = ccui.Button:create(ImageRoot.."room_play_btn.png",ImageRoot.."room_draw_btn.png")
	dealBtn:setScale(0.7,0.7)
	dealBtn:move(display.width/3,display.cy-150)
	dealBtn:setTitleText("发牌")
	dealBtn:setTitleFontSize(30)
	dealBtn:addTo(self)
	dealBtn:addClickEventListener(dealCardTest)

	--出牌
	local playBtn = ccui.Button:create(ImageRoot.."room_draw_btn.png",ImageRoot.."room_play_btn.png")
	playBtn:setScale(0.7,0.7)
	playBtn:move((display.width/3)*2,display.cy-150)
	playBtn:setTitleText("出牌")
	playBtn:setTitleFontSize(30)
	playBtn:addTo(self)
	playBtn:addClickEventListener(outCardTest)

	--摸牌
	local grabBtn = ccui.Button:create(ImageRoot.."room_draw_btn.png",ImageRoot.."room_play_btn.png")
	grabBtn:setScale(0.7,0.7)
	grabBtn:move(display.cx,display.cy-150)
	grabBtn:setTitleText("摸牌")
	grabBtn:setTitleFontSize(30)
	grabBtn:addTo(self)
	grabBtn:addClickEventListener(grabCardTest)

	--Test End---
end

--发牌
function PokerLayer:dealCard(data)
	dump("dealCard")
	local cards = data.dealData

	for i,v in ipairs(cards) do
		local handcardView = HandCardView:create()
		handcardView:updateView(v,i)
		if i == 1 then
			handcardView:setPosition(Config.startX_1_3,Config.startY_1)
		elseif i == 2 then
			handcardView:setPosition(Config.startX_2,Config.startY_2_4)
		elseif i == 3 then
			handcardView:setPosition(Config.startX_1_3,Config.startY_3)
		elseif i == 4 then
			handcardView:setPosition(Config.startX_4,Config.startY_2_4)
		end

		self:addChild(handcardView)
		table.insert(self.handCardViewTb,handcardView)

	end
end

--出牌
function PokerLayer:outCard(data)
	-- dump("outCard")
	local seatID = data.seatID or 1
	self.outCardView:setLocalZOrder(1)
	self.handCardViewTb[seatID]:setLocalZOrder(2)

	local pos = self.outCardView:getChuPaiWorldPos()
	data.pos = pos
	self.handCardViewTb[seatID]:playOutCard(data)

end

--摸牌
function PokerLayer:grabCard(data)
	local seatID = data.seatID or 1
	self.outCardView:setLocalZOrder(2)
	self.handCardViewTb[seatID]:setLocalZOrder(1)
	local pos = self.handCardViewTb[seatID]:getLastHandCardWorldPos()
	data.pos = pos
	self.outCardView:grabCard(data)

end

--出牌动画之后
function PokerLayer:afterOutCard( data )
	self.outCardView:updateViewWithOutCard(data)
end

--摸牌动画之后
function PokerLayer:afterGrabCard( data )
	local seatID = data.seatID or 1
	self.handCardViewTb[seatID]:addCard(data)
end


--更新界面
function PokerLayer:updateView( data )
	
end


return PokerLayer