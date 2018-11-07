local CardLayerCtr = class("CardLayerCtr",cc.load("boyaa").mvc.BoyaaCtr)
local CardLayerView = import(".CardLayerView")
local HandCardCtr = import(".handCard.HandCardCtr")
local OutCardCtr = import(".outCard.OutCardCtr")
--消息配置
local EvenConfig = {
	dealCard = "dealCard",
	grapCard = "grapCard",
	outCard = "outCard",
	grapCardAfterAnim = "grapCardAfterAnim",
	outCardAfterAnim = "outCardAfterAnim",
}

function CardLayerCtr:ctor( ... )
	--注册消息
	self.handCardCtrList = {}
	self.outCardCtr = nil
	self:registerEvent()
	self:createView()
	self:createCtr()
end

--注册消息函数
function CardLayerCtr:registerEvent( )
	for eventName, funcName in pairs(EvenConfig) do
		if self[funcName] then
			self:bindEventListener(eventName,handler(self,self[funcName]))
		else
			error(eventName.."的回调函数不存在")
		end
	end
end

--创建视图
function CardLayerCtr:createView( )
	--创建cardLayerView
	local cardLayerView = CardLayerView:create()
	self:setView(cardLayerView)
end

--创建控制器
function CardLayerCtr:createCtr( )
	for seatId = 1,4 do
		--先创建handCardCtr
		local handCardCtr = HandCardCtr:create(seatId)
		table.insert(self.handCardCtrList,handCardCtr)
		--将handCardView加入到cardLayerView中
		self:getView():addChildNode(handCardCtr:getView(),{viewType = "hand",seatId = seatId})
	end
	--先创建outCardCtr
	self.outCardCtr = OutCardCtr:create()
	--将outCardView加入到cardLayerView中
	self:getView():addChildNode(self.outCardCtr:getView(),{viewType = "out",})
end

--发牌
function CardLayerCtr:dealCard( event )
	local dealData = event.dealData
	for seatId,cardList in pairs(dealData) do
		--手牌模块处理
		self.handCardCtrList[seatId]:dealCard(cardList)
	end
	--出牌模块处理
	self.outCardCtr:dealCard()
end

--抓牌
function CardLayerCtr:grapCard( event )
	local grapData = event.grapData
	--调整层级
	self.handCardCtrList[grapData.seatId]:setCardZOrder(1)
	self.outCardCtr:setCardZOrder(2)
	local pos = {}
	--获取手牌位置的坐标
	self.handCardCtrList[grapData.seatId]:getHandPos(pos)
	grapData.pos = pos
	--出牌模块处理
	self.outCardCtr:grapCard(grapData)
end

--出牌
function CardLayerCtr:outCard( event )
	local outData = event.outData
	--调整层级
	self.handCardCtrList[outData.seatId]:setCardZOrder(2)
	self.outCardCtr:setCardZOrder(1)
	local pos = {}
	--获取出牌位置的坐标
	self.outCardCtr:getOutPos(pos)
	outData.pos = pos
	--手牌模块处理
	self.handCardCtrList[outData.seatId]:outCard(outData)
end

--抓牌动画后
function CardLayerCtr:grapCardAfterAnim( event )
	local grapData = event._usedata
	self.handCardCtrList[grapData.seatId]:grapCardAfterAnim(grapData)
end

--出牌动画后
function CardLayerCtr:outCardAfterAnim( event )
	local outData = event._usedata
	self.outCardCtr:outCardAfterAnim(outData)
end

function CardLayerCtr:updateView( data )
	local view = self:getView()
	if view then
		view:updateView(data)
	end
end

return CardLayerCtr