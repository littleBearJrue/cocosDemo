local HandCardCtr = class("HandCardCtr",cc.load("boyaa").mvc.BoyaaCtr)
local HandCardView = import(".HandCardView")
function HandCardCtr:ctor( seatId )
	--创建视图
	self:createView(seatId)
end

function HandCardCtr:createView( seatId )
	local handCardView = HandCardView:create(self,seatId)
	--设置视图
	self:setView(handCardView)
end

--发牌
function HandCardCtr:dealCard( cardList )
	self:getView():dealCard(cardList)
end

--出牌
function HandCardCtr:outCard( outData )
	self:getView():outCard(outData)
end

--抓牌动画后
function HandCardCtr:grapCardAfterAnim( grapData )
	self:getView():grapCardAfterAnim(grapData.cardByte)
end

--获取坐标
function HandCardCtr:getHandPos( pos )
	self:getView():getHandPos(pos)
end

--设置层级
function HandCardCtr:setCardZOrder( value )
	self:getView():setLocalZOrder(value)
end

--发送消息
function HandCardCtr:sendMsg( event,eventData )
	self:sendEvenData(event,eventData)
end

return HandCardCtr