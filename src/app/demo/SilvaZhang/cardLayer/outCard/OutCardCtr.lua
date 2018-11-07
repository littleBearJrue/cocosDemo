local OutCardCtr = class("OutCardCtr",cc.load("boyaa").mvc.BoyaaCtr)
local OutCardView = import(".OutCardView")
function OutCardCtr:ctor( ... )
	--创建视图
	self:createView()
end

function OutCardCtr:createView( )
	local outCardView = OutCardView:create(self)
	--设置视图
	self:setView(outCardView)
end

--发牌
function OutCardCtr:dealCard( cardList )
	self:getView():dealCard(cardList)
end

--出牌
function OutCardCtr:grapCard( grapData )
	self:getView():grapCard(grapData)
end

--抓牌动画后
function OutCardCtr:outCardAfterAnim( outData )
	self:getView():outCardAfterAnim(outData.cardByte)
end

--获取坐标
function OutCardCtr:getOutPos( pos )
	self:getView():getOutPos(pos)
end

--设置层级
function OutCardCtr:setCardZOrder( value )
	self:getView():setLocalZOrder(value)
end

--发送消息
function OutCardCtr:sendMsg( event,eventData )
	self:sendEvenData(event,eventData)
end

return OutCardCtr