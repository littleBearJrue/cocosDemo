local CardView = import("...card.CardView")
local imagePath = "Images/cangkulan/"
local HandCardView = class("HandCardView",cc.load("boyaa").mvc.BoyaaLayout)

local handConfig = {
	width = 180,
	height = 90,
	maxSpace = 30,
	cardScale = 0.25,
}

function HandCardView:ctor( ctr,seatId )
	self:bindCtr(ctr)
	self:initData(seatId)
	self:initView()
end

--初始化
function HandCardView:initData( seatId )
	--当前手牌的玩家座位
	self.seatId = seatId
	--是否是自己
	self.isMine = 1
	if self.seatId ~= 1 then
		self.isMine = 2
	end
	--剩余牌数
	self.remainNum = 0
	--手牌列表
	self.cardList = {}
	--选中的牌
	self.selectCardList = nil
end

function HandCardView:initView( )
	self:setContentSize(handConfig.width,handConfig.height)
	self:setLayoutType(ccui.LayoutType.RELATIVE)
	--剩余牌标签
	self.remainLabel = ccui.Text:create("X"..self.remainNum, s_arialPath, 18)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	self.remainLabel:setLayoutParameter(parameter)
	self.remainLabel:setVisible(false)
	self:addChild(self.remainLabel)

	--手牌区节点
	self.handCardNode = ccui.Layout:create()
	self.handCardNode:setLayoutType(ccui.LayoutType.RELATIVE)
	self.handCardNode:setContentSize(handConfig.width,handConfig.height/6)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentBottomCenterHorizontal)
	self.handCardNode:setLayoutParameter(parameter)
	self:addChild(self.handCardNode)

	--出牌按钮
	self.outButton = ccui.Button:create(imagePath.."room_draw_btn.png",imagePath.."room_play_btn.png")
	self.outButton:setScale(0.6,0.6)
	self.outButton:setAnchorPoint(0.5,0.5)
	self.outButton:setTitleText("outCard")
	self.outButton:setTitleFontSize(30)
	self.outButton:setVisible(false)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)
	parameter:setMargin({top = -20})
	self.outButton:setLayoutParameter(parameter)
	local callback = function(tag)
		local data = {
			seatId = self.seatId, 
			cardByte = self.selectCardList.cardByte,
		}
		--模拟发送消息给后端
		self:getCtr():sendMsg("C2S_outCard",clone(data))
	    self.selectCardList = nil
       	self.outButton:setVisible(false)
    end
    --出牌回调
    self.outButton:addClickEventListener(callback)
	self:addChild(self.outButton)
end

--发牌
function HandCardView:dealCard( cardList )
	--数据清理
	if #self.cardList > 0 then
		for i,cardView in ipairs(self.cardList) do
			cardView:removeFromParent()
		end
		self.cardList = {}
	end
	--创建所有牌
	for i,cardByte in ipairs(cardList) do
		local cardView = self:createOneHandCard(cardByte)
		cardView:setOpacity(0)
	end
	--进行排序
	self:sortCardPos()
	--发牌动画
	self:dealCardAnim()
	--设置触摸事件
	if self.isMine == 1 then
		for i,cardView in ipairs(self.cardList) do
			self:setCardTouch(cardView)
		end
	end
	--重置剩余牌
	self.remainNum = 0
	--修改剩余牌
	self:updateRemainNum("add",#self.cardList)
end

--发牌动画
function HandCardView:dealCardAnim(  )
	for i,cardView in ipairs(self.cardList) do
		cardView:runAction(cc.FadeIn:create(i*0.2))
	end
end

--设置触摸事件
function HandCardView:setCardTouch( cardView )
  	cardView:setTouchEnabled(true)
  	--升起或放下牌
  	local changeCardPos = function ( flag, cardView )
  		local parameter = cardView:getLayoutParameter()
		local margin = parameter:getMargin()
		if flag == "up" then
			margin.bottom = (margin.bottom or 0) + 15
		elseif flag == "down" then
			margin.bottom = (margin.bottom or 0) - 15
		end
		parameter:setMargin(margin)
		cardView:getParent():requestDoLayout()
  	end
  	--判断是否显示出牌按钮
  	local judgeButton = function ( flag, cardView )
  		if self.selectCardList then
  			self.outButton:setVisible(true)
  		else
  			self.outButton:setVisible(false)
  		end
  	end
  	--回调函数
  	local callback = function(cardView,event)
  		if event == 0 then
  		elseif event == 1 then
  		--抬起
  		elseif event == 2 then
  			if self.selectCardList then
  				if self.selectCardList == cardView then
  					changeCardPos("down",cardView)
  					self.selectCardList = nil
  				else
  					changeCardPos("down",self.selectCardList)
  					changeCardPos("up",cardView)
  					self.selectCardList = cardView
  				end
  			else
  				changeCardPos("up",cardView)
  				self.selectCardList = cardView
  			end
  			judgeButton()
  		end
    end
    cardView:addTouchEventListener(callback)
end

--抓牌，出牌模块动画执行才执行这里
function HandCardView:grapCardAfterAnim( cardByte )
	--创建一张牌
	local cardView = self:createOneHandCard(cardByte)
	--重置位置
	self:sortCardPos()
	if self.isMine == 1 then
		--设置触摸事件
		self:setCardTouch(cardView)
	end
	--修改剩余牌
	self:updateRemainNum("add",1)
end

--出牌
function HandCardView:outCard( data )
	local index = 0
	local outCard
	--找到要出的牌
	for i,cardView in ipairs(self.cardList) do
		if cardView.cardByte == data.cardByte then
			outCard = cardView
			index = i
			break
		end
	end
	if outCard then
		--坐标转换
		local localPos = cc.p(outCard:getPositionX(),outCard:getPositionY())
		local worldPos = outCard:getParent():convertToWorldSpaceAR(localPos)
		local pos = {x = data.pos.x - worldPos.x , y = data.pos.y - worldPos.y}
		--出牌动画执行完
		local outAnimFunc = function ( ... )
			outCard:removeFromParent()
			table.remove(self.cardList, index)
			self:updateRemainNum("sub",1)
    	   	self:sortCardPos()
			--发送出牌动画执行完消息
			self:getCtr():sendMsg("outCardAfterAnim",data)
		end
		outCard:setLocalZOrder(50)
		--设置移动动作
		outCard:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(pos.x, pos.y)), cc.CallFunc:create(outAnimFunc)))
	end
end

--创建单张牌
function HandCardView:createOneHandCard( cardByte )
	local handCard = CardView:create({cardByte = cardByte,cardStyle = self.isMine})
	self.handCardNode:addChild(handCard)
	table.insert(self.cardList,1,handCard)
	handCard:setCascadeOpacityEnabled(true)
	handCard:setScale(handConfig.cardScale,handConfig.cardScale)
	handCard:setAnchorPoint(0,0)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentLeftBottom)
	handCard:setLayoutParameter(parameter)
	return handCard
end

--进行排序
function HandCardView:sortCardPos( )
	local space = handConfig.maxSpace
	if #self.cardList > 1 then
		local cardWidth = self.cardList[1]:getContentSize().width
		space = (handConfig.width - cardWidth*handConfig.cardScale)/(#self.cardList - 1)
	end
	if space > handConfig.maxSpace then
		space = handConfig.maxSpace
	end
	for i,cardView in ipairs(self.cardList) do
		local parameter = cardView:getLayoutParameter()
		parameter:setMargin({ left = (i-1)*space })
		cardView:getParent():requestDoLayout()
		cardView:setLocalZOrder(i)
	end
end

--更新剩余牌数
function HandCardView:updateRemainNum( flag,num )
	if flag == "add" then
		self.remainNum = self.remainNum + num
	else
		self.remainNum = self.remainNum - num
	end
	self.remainLabel:setVisible(true)
	self.remainLabel:setString("X"..self.remainNum)
end

--获取手牌坐标
function HandCardView:getHandPos( pos )
	if #self.cardList > 0 then
		local cardView = self.cardList[#self.cardList]
		local localPos = cc.p(cardView:getPositionX(),cardView:getPositionY())
		local worldPos = cardView:getParent():convertToWorldSpaceAR(localPos)
		pos.x = worldPos.x
		pos.y = worldPos.y
	else
		pos.x = 150
		pos.y = 0
	end
end

return HandCardView