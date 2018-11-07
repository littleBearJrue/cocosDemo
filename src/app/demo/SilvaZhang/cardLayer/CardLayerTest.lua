local CardLayerTest = {}
--工具类
local Utils = import(".Utils")
--设计分辨率
local designSize = Utils.designConfig.designSize
local CardLayerCtr = import(".CardLayerCtr")

--所有牌
local allCard = 
{
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
	0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,
}

--主入口
function CardLayerTest:main( ... )
	--创建场景
	local scene = cc.Scene:create()
	self.scene = scene
	self:initData()
	self:initView()
	return scene
end

--初始数据
function CardLayerTest:initData( ... )
	--剩余牌
	self.remainCard = clone(allCard)
	--每个玩家手中的牌
	self.seatIdCard = {[1] = {},[2] = {},[3] = {},[4] = {}}
	--记录要改变的玩家座位
	self.seatId = 1
end

function CardLayerTest:initView( ... )
	--创建CardLayerCtr，将view加入场景中
	local cardLayerCtr = CardLayerCtr:create()
	local cardLayerView = cardLayerCtr:getView()
	self.scene:addChild(cardLayerView)
	--注册事件
	self:bindEventListener()
	--创建控制器
	self:createController()
end

--注册消息，模拟前端提交出牌
function CardLayerTest:bindEventListener()
	local function callback( event )
		local outData = event._usedata
		local seatId = outData.seatId
		local cardByte = outData.cardByte
		for i,v in ipairs(self.seatIdCard[seatId]) do
			if v == cardByte then
				table.remove(self.seatIdCard[seatId], i)
				break
			end
		end
		local myEvent=cc.EventCustom:new("outCard")
		myEvent.outData = outData
		local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
       	customEventDispatch:dispatchEvent(myEvent)
	end
    local listener1 = cc.EventListenerCustom:create("C2S_outCard",callback)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)
end

--给seatId玩家增加一张牌
function CardLayerTest:addSeatCard( seatId )
	local cardNum = #self.remainCard
	local index = math.random(1, cardNum)
	local tempCard = self.remainCard[index]
	table.remove(self.remainCard, index)
	table.insert(self.seatIdCard[seatId],tempCard)
	return tempCard
end

--给seatId玩家减少一张牌
function CardLayerTest:subSeatCard( seatId )
	local cardNum = #self.seatIdCard[seatId]
	local index = math.random(1, cardNum)
	local tempCard = self.seatIdCard[seatId][index]
	table.remove(self.seatIdCard[seatId], index)
	return tempCard
end

--控制器
function CardLayerTest:createController( ... )
	--设置背景
	local controllerBg = ccui.Layout:create()
	controllerBg:setContentSize(170,120)
	controllerBg:setAnchorPoint(0,1)
	controllerBg:setPosition(0,designSize.height)
	controllerBg:setLayoutType(ccui.LayoutType.RELATIVE)
	self.scene:addChild(controllerBg)

	--发牌按钮
	local dealCardBtn = ccui.Button:create("Images/r1.png","Images/r2.png")
	dealCardBtn:setTitleText("deal")
	dealCardBtn:setTitleFontSize(22)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)
	dealCardBtn:setLayoutParameter(parameter)
	controllerBg:addChild(dealCardBtn)
	local dealCallback = function(tag)
		self:initData()
		self.seatLabel:setString(self.seatId.."")
		local dealData = {}
		for i = 1, 4 do
			dealData[i] = {}
			for j = 1, 8 do
				local tempCard = self:addSeatCard(i)
				table.insert(dealData[i],tempCard)
			end
		end
		--发送发牌消息
		local myEvent=cc.EventCustom:new("dealCard")
		myEvent.dealData = dealData
		local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
       	customEventDispatch:dispatchEvent(myEvent)
    end
    dealCardBtn:addClickEventListener(dealCallback)

	--增加按钮
	local addBtn = ccui.Button:create("Images/f1.png","Images/f2.png")
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentRightCenterVertical)
	addBtn:setLayoutParameter(parameter)
	controllerBg:addChild(addBtn)
	local addCallback = function(tag)
		self.seatId = self.seatId + 1
		if self.seatId == 5 then
			self.seatId = 1
		end
		self.seatLabel:setString(self.seatId.."")
    end
    addBtn:addClickEventListener(addCallback)

	--坐标标签
	local seatLabel = ccui.Text:create(self.seatId.."", s_arialPath, 30)
	self.seatLabel = seatLabel
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.centerInParent)
	seatLabel:setLayoutParameter(parameter)
	controllerBg:addChild(seatLabel)

	--减少按钮
	local subBtn = ccui.Button:create("Images/b1.png","Images/b2.png")
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentLeftCenterVertical)
	subBtn:setLayoutParameter(parameter)
	controllerBg:addChild(subBtn)
	local subCallback = function(tag)
		self.seatId = self.seatId - 1
		if self.seatId == 0 then
			self.seatId = 4
		end
		self.seatLabel:setString(self.seatId.."")
    end
    subBtn:addClickEventListener(subCallback)

	--抓牌按钮
	local grapCardBtn = ccui.Button:create("Images/r1.png","Images/r2.png")
	grapCardBtn:setTitleText("grap")
	grapCardBtn:setTitleFontSize(22)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentLeftBottom)
	grapCardBtn:setLayoutParameter(parameter)
	controllerBg:addChild(grapCardBtn)
	local grapCallback = function(tag)
		local grapData = {
			seatId = self.seatId, 
			cardByte = self:addSeatCard(self.seatId),
		}
		--发送抓牌消息
		if grapData.cardByte then
			local myEvent=cc.EventCustom:new("grapCard")
			myEvent.grapData = grapData
			local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
       		customEventDispatch:dispatchEvent(myEvent)
       	end
    end
    grapCardBtn:addClickEventListener(grapCallback)

	--出牌按钮
	local outCardBtn = ccui.Button:create("Images/r1.png","Images/r2.png")
	outCardBtn:setTitleText("out")
	outCardBtn:setTitleFontSize(22)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.alignParentRightBottom)
	outCardBtn:setLayoutParameter(parameter)
	controllerBg:addChild(outCardBtn)
	local outCallback = function(tag)
		local outData = {
			seatId = self.seatId, 
			cardByte = self:subSeatCard(self.seatId),
		}
		if outData.cardByte then
			--发送出牌消息
			local myEvent=cc.EventCustom:new("outCard")
			myEvent.outData = outData
			local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
       		customEventDispatch:dispatchEvent(myEvent)
       	end
    end
    outCardBtn:addClickEventListener(outCallback)

	return controllerBg
end

return handler(CardLayerTest, CardLayerTest.main)