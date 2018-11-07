local Utils = import(".Utils")
local ClockView = import(".ClockView")
local CardView = import("..card.CardView")
local designSize = Utils.designConfig.designSize
local SwapCardView = class("SwapCardView",cc.load("boyaa").mvc.BoyaaLayout)

local config = {
	cardScale = 0.38,
	cardSelectScale = 0.45,
	cardZorder = 10,
	cardSelectZorder = 15,
	cardOpacity = 255,
	cardSelectOpacity = 180,
}

function SwapCardView:ctor( ctr )
	self:bindCtr(ctr)
	self:setContentSize(720,1280)
	--获取换牌场景
	local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/SilvaZhang/swap/SwapScene.ccreator');
    creatorReader:setup();
    local swapScene = creatorReader:getNodeGraph();
    self:addChild(swapScene)
    swapScene:setVisible(true)
    self:initView(swapScene)
end

--初始化View
function SwapCardView:initView( swapScene )
	self:setVisible(false)
	local Canvas = swapScene:getChildByName("Canvas")
	--提示语
	self.tipLabel = Canvas:getChildByName("tipLabel")
	--完成按钮
	self.finishBtn = Canvas:getChildByName("finishBtn")
	--交换按钮
	self.changeBtn = Canvas:getChildByName("changeBtn")
	--牌背景
	self.cardBg = Canvas:getChildByName("cardBg")
	--牌型标签
	self.paixingLabel = {} 
	self.paixingLabel[1] = self.cardBg:getChildByName("paixingLabel1")
	self.paixingLabel[2] = self.cardBg:getChildByName("paixingLabel2") 
	self.paixingLabel[3] = self.cardBg:getChildByName("paixingLabel3")  
	self.requestImg = {}
	--牌型要求
	self.requestImg[1] = self.cardBg:getChildByName("requestImg1")
	self.requestImg[2] = self.cardBg:getChildByName("requestImg2") 
	self.requestImg[3] = self.cardBg:getChildByName("requestImg3") 
	--单张牌背景遮罩
	self.cardNodeList = {[1] = {},[2] = {},[3] = {}}
	table.insert(self.cardNodeList[1],self.cardBg:getChildByName("cardNode11"))
	table.insert(self.cardNodeList[1],self.cardBg:getChildByName("cardNode12"))
	table.insert(self.cardNodeList[1],self.cardBg:getChildByName("cardNode13"))
	table.insert(self.cardNodeList[2],self.cardBg:getChildByName("cardNode21"))
	table.insert(self.cardNodeList[2],self.cardBg:getChildByName("cardNode22"))
	table.insert(self.cardNodeList[2],self.cardBg:getChildByName("cardNode23"))
	table.insert(self.cardNodeList[2],self.cardBg:getChildByName("cardNode24"))
	table.insert(self.cardNodeList[2],self.cardBg:getChildByName("cardNode25"))
	table.insert(self.cardNodeList[3],self.cardBg:getChildByName("cardNode31"))
	table.insert(self.cardNodeList[3],self.cardBg:getChildByName("cardNode32"))
	table.insert(self.cardNodeList[3],self.cardBg:getChildByName("cardNode33"))
	table.insert(self.cardNodeList[3],self.cardBg:getChildByName("cardNode34"))
	table.insert(self.cardNodeList[3],self.cardBg:getChildByName("cardNode35"))
	for row ,rowCardNodeList in ipairs(self.cardNodeList) do
		for col, cardNode in ipairs(rowCardNodeList) do
			cardNode:setVisible(false)
		end
	end
	--单张牌视图
	self.cardList = {[1] = {},[2] = {},[3] = {}}
	--选中牌
	self.selectCard = nil
	--满足贴图
	self.rightImg = cc.Director:getInstance():getTextureCache():addImage("creator/Texture/SilvaZhang/SwapRes/room_placecard_right.png") 
	self.wrongImg = cc.Director:getInstance():getTextureCache():addImage("creator/Texture/SilvaZhang/SwapRes/room_placecard_wrong.png")
	self:setButtonClick()
end

function SwapCardView:setButtonClick( )
	local callback1 = function ( tag )
		self:setVisible(false)
		local data = {}
		data.card = self:getAllCardByte()
		data.ready = true
		self:getCtr():sendMsg( "ready",data )
	end
	self.finishBtn:addClickEventListener(callback1)

	local callback2 = function ( tag )
		for i = 1,5 do
			local tempByte = self.cardList[2][i].cardByte
			self.cardList[2][i].cardByte = self.cardList[3][i].cardByte
			self.cardList[3][i].cardByte = tempByte
		end
		self:paixingCalcluate()
	end
	self.changeBtn:addClickEventListener(callback2)
end

--开始换牌
function SwapCardView:initCard( initData )
	--显示视图
	self:setVisible(true)
	self.selectCard = nil
	--移除原有的牌
	for row ,rowCardNodeList in ipairs(self.cardList) do
		for col, cardView in ipairs(rowCardNodeList) do
			cardView:removeFromParent()
		end
	end
	self.cardList = {[1] = {},[2] = {},[3] = {}}
	--获取牌值
	local cardByteList = initData.cardByteList
	--创建牌
	for row,cardRowList in ipairs(cardByteList) do
		for col,cardByte in ipairs(cardRowList) do
			--创建单张牌
			local singleCard = self:createOneCard(cardByte,row,col)
			--加入list中
			self.cardList[row][col] = singleCard
			--设置触摸事件
			self:setCardTouch(singleCard)
		end
	end
	--获取牌宽高
	if self.cardList[1][1] then
		local cardSize = self.cardList[1][1]:getContentSize()
		self.cardWidth = cardSize.width/2 * config.cardScale
		self.cardHeight = cardSize.height/2 * config.cardScale
	end
	--牌型计算
	self:paixingCalcluate()
	self:addScheduler()
end

function SwapCardView:addScheduler(  )
	if self.clockView then
		self.clockView:removeFromParent()
		self.clockView = nil
	end
	local fun1 = function ( ... )
		self.tipLabel:setString("快快快")
	end
	local fun2 = function ( ... )
		self:setVisible(false)
		local data = {}
		data.card = self:getAllCardByte()
		data.ready = true
		self:getCtr():sendMsg( "ready",data )
	end
	local data = {{time = 10,style = true ,func = fun1},{time = 0,func = fun2}}
	self.clockView = ClockView:create(20,data)
	self.clockView:setPosition(designSize.width/2,designSize.height-100)
	self.clockView:addTo(self)
end

--创建单牌
function SwapCardView:createOneCard( cardByte,row,col )
	local singleCard = CardView:create({cardByte = cardByte,cardStyle = 1})
	singleCard:setLocalZOrder(config.cardZorder)
	singleCard:setScale(config.cardScale,config.cardScale)
	--加入牌背景中
	singleCard:addTo(self.cardBg)
	singleCard:setCascadeOpacityEnabled(true)
	singleCard:setAnchorPoint(0.5,0.5)	
	--设置坐标为遮罩坐标
	if row and col then
		singleCard:setPosition(self.cardNodeList[row][col]:getPosition())
	end
	return singleCard
end

--牌返回原地
local setReturnCardMove = function ( self,card )
	local animFunc = function ( ... )
		--是否有拖动而创建的牌
		if self.tempTouchCard then
			self.tempTouchCard:removeFromParent()
			self.tempTouchCard = nil
		end
		--恢复透明度
		card:setOpacity(config.cardOpacity)
	end
	--找到牌所在row，col
	local index = self:findCardIndex(card)
	--获取牌背景坐标
	local nodePosX,nodePosY = self.cardNodeList[index[1]][index[2]]:getPosition()
	--计算偏移差值
    local posX = nodePosX - card:getPositionX() 
	local posY = nodePosY - card:getPositionY()
	--执行移动动画
	card:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(posX,posY)), cc.CallFunc:create(animFunc)))
end

--设置选中牌
local setCardSelect = function ( self,singleCard ,flag)
	local animFunc = function ( ... )
	end
	local scaleValue = 1
	--选中
	if flag == "select" then
		self.selectCard = singleCard
		scaleValue = config.cardSelectScale
	--取消
	elseif flag == "cancel" then
		self.selectCard = nil
		scaleValue = config.cardScale
	end
	singleCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, scaleValue , scaleValue), cc.CallFunc:create(animFunc)))
end

--点击释放飞行
local setClickCardMove = function ( self,card1,card2 )
	--card1原来 card2现在
	--原来飞现在
	local animFunc = function ( ... )
		--数值交换
		local tempByte = card1.cardByte
		card1.cardByte = card2.cardByte
		card2.cardByte = tempByte
		--清除临时牌
		self.tempClickCard:removeFromParent()
		self.tempClickCard = nil
		--清除选中牌
		self.selectCard = nil
		--进行计算牌型
		self:paixingCalcluate()
	end
	--偏移差值
	local posX = card2:getPositionX() - card1:getPositionX() 
	local posY = card2:getPositionY() - card1:getPositionY()
	--恢复缩放
	card1:setScale(config.cardScale,config.cardScale)
	--创建一张临时牌执行飞行
	self.tempClickCard = self:createOneCard(card1.cardByte)
	self.tempClickCard:setPosition(card1:getPosition())
	self.tempClickCard:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(posX,posY)), cc.CallFunc:create(animFunc)))
end

--点击触摸飞行
local setTouchCardMove = function ( self,card1,card2 )
	--card1拖动 card2区域
	--拖动飞回原位
	local animFunc = function ( ... )
		--是否有拖动而创建的牌
		if self.tempTouchCard then
			self.tempTouchCard:removeFromParent()
			self.tempTouchCard = nil
		end
		--恢复层级
		card1:setLocalZOrder(config.cardZorder)
		card2:setLocalZOrder(config.cardZorder)
		--恢复透明度
		card1:setOpacity(config.cardOpacity)
		--计算牌型
		self:paixingCalcluate()
	end
	local animFunc2 = function ( ... )
	end
	--交换牌值
	local tempByte = card1.cardByte
	card1.cardByte = card2.cardByte
	card2.cardByte = tempByte
	--计算飞行偏移
	local index = self:findCardIndex(card1)
	local nodePosX,nodePosY = self.cardNodeList[index[1]][index[2]]:getPosition()
    local posX = nodePosX - card2:getPositionX() 
	local posY = nodePosY - card2:getPositionY()
	--设置拖动牌从区域牌位置开始飞行
	card1:setPosition(card2:getPosition())
	--执行飞行
	card1:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(posX,posY)), cc.CallFunc:create(animFunc)))
	card2:setScale(0.3)
	--执行缩放
	card2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, config.cardScale , config.cardScale), cc.CallFunc:create(animFunc2)))
end

--区域判断
--遍历每一个区域，除了自己
local judgeCardArea = function ( self,target,fun1,fun2,fun3 )
	local isFind = false
	for row ,rowCardNodeList in ipairs(self.cardList) do
		for col, cardView in ipairs(rowCardNodeList) do
			if cardView ~= target then
				--看判断矩形中中心点是否在拖动牌区域内
				local nowPosX,nowPosY = target:getPosition()
				local judgePosX,judgePosY = cardView:getPosition()
				local distanceX = math.abs(nowPosX-judgePosX)
				local distanceY = math.abs(nowPosY-judgePosY)
				if distanceX < self.cardWidth and distanceY < self.cardHeight then	
					isFind = true
					--相交
					fun1(row,col)
				else
					--未相交
					fun2(row,col)
				end
			end
		end
	end
	--没有发现相交矩形
	if not isFind then
		fun3()
	end
end

--设置触摸事件
function SwapCardView:setCardTouch( singleCard )
	--触摸开始
    local function onTouchBegan(pTouch,pEvent)
    	--被点击的牌
       	local target = pEvent:getCurrentTarget()
       	--点击点的世界坐标
       	local startPos = pTouch:getLocation()
       	--转换成牌的本地坐标
       	local locationInNode = target:convertToNodeSpace(startPos);
       	local size = target:getContentSize();
       	--牌的大小矩阵
       	local rect = cc.rect(0, 0, size.width, size.height);
       	--判断点是否在矩阵内
       	if cc.rectContainsPoint(rect,locationInNode) then
       		--记录开始点的坐标
       		self.startPosX = startPos.x
       		self.startPosY = startPos.y
       		local localPos = target:getParent():convertToNodeSpace(startPos)
       		--记录点击点到牌中心的偏移
       		self.touchDiffX = localPos.x - target:getPositionX()
       		self.touchDiffY = localPos.y - target:getPositionY()
       		return true
       	end
       	return false
    end
    --触摸结束
    local function onTouchEnded(pTouch,pEvent)
    	--被点击的牌
    	local target = pEvent:getCurrentTarget()
    	--结束点的世界坐标
    	local endPos = pTouch:getLocation()
    	--点击的牌在row，col矩形中
    	local inArea = function ( row,col )
    		--设置背景消失
    		self.cardNodeList[row][col]:setVisible(false)
    		--设置拖动交换
    		setTouchCardMove(self,target,self.cardList[row][col])
    	end
    	--点击的牌不在row，col矩形中
    	local outArea = function ( row,col )

    	end
    	--点击的牌不在所有矩形中
    	local notFind = function ( )
    		--设置返回原位
    		setReturnCardMove(self,target)
    		--恢复原有层级
    		target:setLocalZOrder(config.cardZorder)
    	end
    	--没有移动
    	if endPos.x == self.startPosX and endPos.y == self.startPosY then
    		if self.selectCard then
    			if self.selectCard == target then
    				setCardSelect(self,self.selectCard,"cancel")
    			else
    				setClickCardMove(self,self.selectCard,target)
    			end
    		else
    			setCardSelect(self,target,"select")
    		end
    	--有移动
    	else
    		judgeCardArea(self,target,inArea,outArea,notFind)
    	end
    end
    --触摸移动
    local function onTouchMoved(pTouch, pEvent)
    	local inArea = function ( row,col )
    		--显示背景板
    		self.cardNodeList[row][col]:setVisible(true)
    	end
    	local outArea = function ( row,col )
    		--隐藏背景板
    		self.cardNodeList[row][col]:setVisible(false)
    	end
        local notFind = function ( )
    	end
    	--移动中有选中的牌，放下去
    	if self.selectCard then
    		setCardSelect(self,self.selectCard,"cancel")
    		self.selectCard = nil
    	end
    	local target = pEvent:getCurrentTarget()
    	target:setLocalZOrder(config.cardSelectZorder)
    	--设置移动后的位置
    	local newPos = target:getParent():convertToNodeSpace(pTouch:getLocation());
    	target:setPosition(newPos.x - self.touchDiffX,newPos.y - self.touchDiffY)
    	--设置透明度
    	target:setOpacity(config.cardSelectOpacity)
    	--创建一张底部的临时牌
    	if not self.tempTouchCard then
    		self.tempTouchCard = self:createOneCard(target.cardByte)
    		local index = self:findCardIndex(target)
    		self.tempTouchCard:setPosition(self.cardNodeList[index[1]][index[2]]:getPosition())
    		self.tempTouchCard:setOpacity(config.cardSelectOpacity)
    	end
    	--矩形判别
    	judgeCardArea(self,target,inArea,outArea,notFind)
    end
    --设置触摸事件
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = singleCard:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, singleCard)
end

--根据牌查找row,col
function SwapCardView:findCardIndex( target )
	for row ,rowCardNodeList in ipairs(self.cardList) do
		for col, cardNode in ipairs(rowCardNodeList) do
			if cardNode == target then
				return {row,col}
			end
		end
	end
end

--恢复所有牌的某个属性
function SwapCardView:returnAllCardValue( valueType )
	for row ,rowCardNodeList in ipairs(self.cardList) do
		for col, cardView in ipairs(rowCardNodeList) do
			if valueType == "Opacity" then
				cardView:setOpacity(config.cardOpacity)
			end
			if valueType == "Zorder" then
				cardView:setLocalZOrder(config.cardZorder)
			end
			if valueType == "Scale" then
				cardView:setScale(config.cardScale)
			end
		end
	end
end

function SwapCardView:getAllCardByte( )
	local cardDataList = {[1] = {},[2] = {},[3] = {}}
	for row ,rowCardNodeList in ipairs(self.cardList) do
		for col, cardView in ipairs(rowCardNodeList) do
			cardDataList[row][col] = cardView.cardByte
		end
	end
	return cardDataList
end

--牌型计算
function SwapCardView:paixingCalcluate( )
	local cardDataList = self:getAllCardByte()
	local judgePaixingData = self:getCtr():paixingCalcluate(cardDataList)
	local allInfo = judgePaixingData.all
	local listInfo = judgePaixingData.list
	--先恢复透明度
	self:returnAllCardValue("Opacity")
	for row ,rowListInfo in ipairs(listInfo) do
		--设置标题
		self.paixingLabel[row]:setString(rowListInfo.name)
		--设置满足条件
		if rowListInfo.result then
			self.requestImg[row]:initWithTexture(self.rightImg)
		else
			self.requestImg[row]:initWithTexture(self.wrongImg)
		end
		for i,cardByte in ipairs(rowListInfo.card) do
			for j,cardView in ipairs(self.cardList[row]) do
				if cardView.cardByte == cardByte then
					--设置牌效果
					cardView:setOpacity(150)
					break
				end
			end
		end
	end
end

return SwapCardView