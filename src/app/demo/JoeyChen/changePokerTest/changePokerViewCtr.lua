local appPath = "app.demo.JoeyChen"
local changePokerViewCtr = class("changePokerViewCtr",cc.load("boyaa").mvc.BoyaaCtr);
local changePokerView = require(appPath..".changePokerTest.changePokerView")
local PaixingUtil = import(".PaixingUtil")

function changePokerViewCtr:ctor(pokerfig)
	self.cardList = {}
	self:initView(pokerfig)
	print("changePokerViewCtr");
end

-- 初始化ui
function changePokerViewCtr:initView(pokerfig)
	local changePokerView = changePokerView.new();

    changePokerView:bindCtr(self);
    changePokerView:addPoker(pokerfig);
    changePokerView:setAnchorPoint(0.5,0.5)
    changePokerView:move(0,0);
    self:setView(changePokerView)
end

-- 接收view发来的换牌数据
function changePokerViewCtr:receiveCardListInfo(cardListInfo, isOver)
	-- 通知view做相应的UI处理
	self.cardList = cardListInfo
	local cardTypeInfo = self:checkCardType()
	self.view:changeUIByCardType(cardTypeInfo)

	-- 将数据发送给后端
	-- @cardListInfo 换牌数据
	-- @isOver 换牌流程是否结束

	-- 结束流程
	if isOver then
		self.view:cleanAll()
	end
end

-- 判断换牌区域分别拥有的牌型
function changePokerViewCtr:checkCardType()
	local cardTypeInfo = {list = {[1] = {name = "顺子",card = {},result = true}},all = {}}
	for row ,rowCardDataList in ipairs(self.cardList) do
		local judgeData = PaixingUtil:checkPaixing(rowCardDataList)
		if judgeData.result then
			cardTypeInfo.list[row] = judgeData
		end
	end
	PaixingUtil:checkPaixingSort(cardTypeInfo.list)
	dump(cardTypeInfo,"chao")

	return cardTypeInfo
end

return changePokerViewCtr;