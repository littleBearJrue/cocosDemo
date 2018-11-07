-- @Author: YiangYang
-- @Date:   2018-10-24 09:53:16
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 18:13:27
local PokerLayerCtr = class("PokerLayerCtr",cc.load("boyaa").mvc.BoyaaCtr)

local HandCardView = require("app.demo.YiangYang.poker.HandCardView")

local OutCardView = require("app.demo.YiangYang.poker.OutCardView")

local PokerLayer = require("app.demo.YiangYang.poker.PokerLayer")

local EventConfig = import(".EventConfig")


function PokerLayerCtr:ctor()
	self:initView()
	self.handCardViewTb = {}	--手牌view集合
	self.outCardList = {}		--出牌牌值
	self.remainNum = 24			--底牌剩余数量（未摸）

	self:bindEvent()

end

--绑定事件
function PokerLayerCtr:bindEvent()
	self:bindEventListener(EventConfig.GrabCardEvent,handler(self, self.grabCardEvent))
	self:bindEventListener(EventConfig.DealCardEvent,handler(self, self.dealCardEvent))
	self:bindEventListener(EventConfig.OutCardEvent,handler(self, self.outCardEvent))
	self:bindEventListener(EventConfig.OutCardAfterAnimaEvent,handler(self, self.outCardAfterAnimaEvent))
	self:bindEventListener(EventConfig.GrabCardAfterAnimaEvent,handler(self, self.grabCardAfterAnimaEvent))
end

--初始化界面
function PokerLayerCtr:initView()
	local layer = PokerLayer.new()
	self:setView(layer)
end

--摸牌
function PokerLayerCtr:grabCardEvent( data )
	self.view:grabCard(data.grabData)
end

--发牌
function PokerLayerCtr:dealCardEvent( data )
	self.view:dealCard(data)
end

--出牌
function PokerLayerCtr:outCardEvent( data )
	self.view:outCard(data.outData)
end

--出牌动画操作完毕
function PokerLayerCtr:outCardAfterAnimaEvent( data )
	--通知增加相应出牌
	self.view:afterOutCard(data.outData)
end

--摸牌动画操作完毕
function PokerLayerCtr:grabCardAfterAnimaEvent( data )
	--通知增加相应手牌
	self.view:afterGrabCard(data.grabData)
end

--更新界面
function PokerLayerCtr:updateView( data )
	self.view:updateView(data)
end

return PokerLayerCtr