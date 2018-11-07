local SwapCardCtr = class("SwapCardCtr",cc.load("boyaa").mvc.BoyaaCtr)
local SwapCardView = import(".SwapCardView")
local PaixingUtil = import(".PaixingUtil")
--消息配置
local EvenConfig = {
	initCard = "initCard"
}

function SwapCardCtr:ctor(  )
	self:init()
	self:registerEvent()
end

function SwapCardCtr:init(  )
	--创建view
	self.swapCardView = SwapCardView:create(self)
	self:setView(self.swapCardView)
end

--注册消息函数
function SwapCardCtr:registerEvent( )
	for eventName, funcName in pairs(EvenConfig) do
		if self[funcName] then
			self:bindEventListener(eventName,handler(self,self[funcName]))
		else
			error(eventName.."的回调函数不存在")
		end
	end
end

--交换牌消息
function SwapCardCtr:initCard( event )
	local initData = event.initData
	--调用view
	self:getView():initCard(initData)
end

--牌型计算
function SwapCardCtr:paixingCalcluate( cardDataList )
	local judgePaixingData = {list = {},all = {}}
	for row ,rowCardDataList in ipairs(cardDataList) do
		--一行行判别牌型
		local judgeData = PaixingUtil:checkPaixing(rowCardDataList)
		if judgeData.result then
			judgePaixingData.list[row] = judgeData
		end
	end
	--判别满足性
	PaixingUtil:checkPaixingSort(judgePaixingData.list)
	return judgePaixingData
end

function SwapCardCtr:updateView( data )
	local view = self:getView()
	if view then
		view:updateView(data)
	end
end

function SwapCardCtr:sendMsg( event,eventData )
	self:sendEvenData(event,eventData)
end

return SwapCardCtr