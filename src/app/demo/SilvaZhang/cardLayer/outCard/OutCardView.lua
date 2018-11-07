local imagePath = "Images/cangkulan/"
local CardView = import("...card.CardView")
local OutCardView = class("OutCardView",cc.load("boyaa").mvc.BoyaaLayout)

local outConfig = {
	width = 110,
	height = 100,
	cardScale = 0.25,
}

function OutCardView:ctor( ctr )
	self:bindCtr(ctr)
	self:initData()
	self:initView()
end

function OutCardView:initData( )
	self.remainNum = 0
end

function OutCardView:initView( )
	--设置出牌层布局
	self:setContentSize(outConfig.width,outConfig.height)
	self:setLayoutType(ccui.LayoutType.RELATIVE)
	--创建左边布局
	self:createLeftLayout()
	--创建右边布局
	self:createRightLayout()
end

function OutCardView:createLeftLayout( )
	--左边布局背景
	local leftLayout = ccui.Layout:create()
	self.leftLayout = leftLayout
	leftLayout:setLocalZOrder(2)
	leftLayout:setLayoutType(ccui.LayoutType.RELATIVE)
	leftLayout:setContentSize(55,100)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentLeftCenterVertical)
	leftLayout:setLayoutParameter(parameter)
	self:addChild(leftLayout)

	--剩余牌标签
	self.remainLabel = ccui.Text:create(""..self.remainNum, s_arialPath, 18)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)
	self.remainLabel:setLayoutParameter(parameter)
	self.remainLabel:setVisible(false)
	leftLayout:addChild(self.remainLabel)

	--剩余牌背景
	local remainBg= ccui.ImageView:create(imagePath.."poker_cover.png")
	self.remainBg = remainBg
	remainBg:setVisible(false)
	remainBg:setAnchorPoint(0.5,0.5)
	remainBg:setScale(0.5,0.5)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentBottomCenterHorizontal)
	remainBg:setLayoutParameter(parameter)
	leftLayout:addChild(remainBg)

	--创建剩余牌
	local remainCard = self:createOneOutCard()
	self.remainCard = remainCard
	remainCard.cardByte = 0x51
	remainCard.cardStyle = 2
	remainCard:setVisible(false)
	self.leftLayout:addChild(remainCard)
end

function OutCardView:createRightLayout( )
	--右边背景
	local rightLayout = ccui.Layout:create()
	self.rightLayout = rightLayout
	rightLayout:setLocalZOrder(1)
	rightLayout:setLayoutType(ccui.LayoutType.RELATIVE)
	rightLayout:setContentSize(55,100)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentRightCenterVertical)
	rightLayout:setLayoutParameter(parameter)
	self:addChild(rightLayout)

	--出牌标签
	self.outLabel = ccui.Text:create("out", s_arialPath, 18)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)
	self.outLabel:setLayoutParameter(parameter)
	self.outLabel:setVisible(false)
	rightLayout:addChild(self.outLabel)

	--出牌背景
	local outBg= ccui.ImageView:create(imagePath.."poker_cover.png")
	self.outBg = outBg
	outBg:setVisible(false)
	outBg:setAnchorPoint(0.5,0.5)
	outBg:setScale(0.5,0.5)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentBottomCenterHorizontal)
	outBg:setLayoutParameter(parameter)
	rightLayout:addChild(outBg)

	--创建出牌
	local outOneCard = self:createOneOutCard()
	self.outOneCard = outOneCard
	outOneCard.cardByte = 0x11
	outOneCard.cardStyle = 1
	outOneCard:setVisible(false)
	self.rightLayout:addChild(outOneCard)
end

--创建一张牌
function OutCardView:createOneOutCard( )
	local outCard= CardView:create({cardValue = 0x11,cardStyle = 2})
	outCard:setAnchorPoint(0,0)
	outCard:setScale(outConfig.cardScale,outConfig.cardScale)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentBottomCenterHorizontal)
	parameter:setMargin({ bottom = 3 })
	outCard:setLayoutParameter(parameter)
	return outCard
end

--摸牌
function OutCardView:dealCard( )
	self.outBg:setVisible(true)
	self.remainBg:setVisible(true)
	self.remainCard:setVisible(true)
	self.outOneCard:setVisible(false)
	self.remainNum = 0
	self:updateRemainNum("add",20)
end

--抓牌
function OutCardView:grapCard( data )
	local grapCard = self:createOneOutCard()
	self.leftLayout:addChild(grapCard)
	local localPos = cc.p(grapCard:getPositionX(),grapCard:getPositionY())
	local worldPos = grapCard:getParent():convertToWorldSpaceAR(localPos)
	local pos = {x = data.pos.x - worldPos.x , y = data.pos.y - worldPos.y}
	local grapAnimFunc = function ( ... )
		grapCard:removeFromParent()
		self:updateRemainNum("sub",1)
		--抓牌动画完成发送消息
		self:getCtr():sendMsg("grapCardAfterAnim",data)
	end
	--执行抓牌动画
	grapCard:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(pos.x, pos.y)), cc.CallFunc:create(grapAnimFunc)))
end

--出牌
function OutCardView:outCardAfterAnim( cardByte )
	if self.outOneCard then
		self.outOneCard:setVisible(true)
		self.outOneCard.cardByte = cardByte
	end
end

--修改剩余牌
function OutCardView:updateRemainNum( flag,num )
	if flag == "add" then
		self.remainNum = self.remainNum + num
	else
		self.remainNum = self.remainNum - num
	end
	self.remainLabel:setVisible(true)
	self.outLabel:setVisible(true)
	self.remainLabel:setString("X"..self.remainNum)
end

--获取出牌区坐标
function OutCardView:getOutPos( pos )
	local localPos = cc.p(self.outOneCard:getPositionX(),self.outOneCard:getPositionY())
	local worldPos = self.outOneCard:getParent():convertToWorldSpaceAR(localPos)
	pos.x = worldPos.x
	pos.y = worldPos.y
end

return OutCardView