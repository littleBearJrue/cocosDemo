local appPath = "app.demo.AeishenLin"
local PaiXingUtil =  require(appPath..".SSZ.PaiXingUtil")
local SSZCtr = class("SSZCtr",cc.load("boyaa").mvc.BoyaaCtr);
local SSZView =  require(appPath..".SSZ.SSZView")
local EvenConfig = {
}

function SSZCtr:ctor()
end

---获取每一组的牌型
local function paiXingOfGroup(group)
	return PaiXingUtil:find(group)
end

---获取符合牌型的所有牌
local function getAllCheakCard(allCheakCard, group)
	for _, cardByte in ipairs(group.card) do
		table.insert(allCheakCard, cardByte)
	end
end

---初始化每一组
function SSZCtr:initGround()
	self.groupHead = {}
	self.groupMid = {}
	self.groupLast = {}
end

function SSZCtr:initView()
	local sszView = SSZView.new();
	sszView:bindCtr(self);
	self:initCardData()
	self:getCoustomEvent()
end

---初始化牌数据
function SSZCtr:initCardData()
    local cardList = {0x17,0x12,0x13,0x14,0x26,0x22,0x28,0x24,0x36,0x32,0x39,0x34,0x35}
    self:getView():createAllCard(cardList)
end

---设置每一组的牌型名字
function SSZCtr:setPaiXingTitle(head,mid,last)
	self:getView():changeString(1, head.name)
	self:getView():changeString(2, mid.name)
	self:getView():changeString(3, last.name)
end

---设置每一组是否符合要求的图片
function SSZCtr:setCheckImage(head,mid,last)
	local headCheak = PaiXingUtil:GetCheckResult(head,mid) and PaiXingUtil:GetCheckResult(head,last)
	self:getView():changeTexture(1, headCheak)
	local midCheak = (PaiXingUtil:GetCheckResult(mid,last) and PaiXingUtil:GetCheckResult(head,mid)) or (PaiXingUtil:GetCheckResult(last,mid) and PaiXingUtil:GetCheckResult(mid,head))
	self:getView():changeTexture(2, midCheak)
	local lastCheak = PaiXingUtil:GetCheckResult(mid,last) and PaiXingUtil:GetCheckResult(head,last)
	self:getView():changeTexture(3, lastCheak)
end

---设置符合牌型的牌的遮罩
function SSZCtr:setCheakCard(allCheakCard)
	self:getView():beforeSetCheckCard()
	for i, slot in ipairs(self:getView().slotList) do
		local target = slot:getChildByTag(i)
		for _, _cardByte in ipairs(allCheakCard) do
			if target.cardByte == _cardByte then
				self:getView():setCheckCardView(target)
			end
		end
	end
end

---设置所有要检测的牌
function SSZCtr:setAllCheakCard(head,mid,last)
	local allCheakCard = {}
	getAllCheakCard(allCheakCard, head)
	getAllCheakCard(allCheakCard, mid)
	getAllCheakCard(allCheakCard, last)
	self:setCheakCard(allCheakCard)
end

---开始检测牌型
function SSZCtr:startCheck()
	local groupHeadData = paiXingOfGroup(self.groupHead)
	local groupMidData = paiXingOfGroup(self.groupMid)
	local groupLastData = paiXingOfGroup(self.groupLast)
	self:setAllCheakCard(groupHeadData,groupMidData,groupLastData)
	self:setPaiXingTitle(groupHeadData,groupMidData,groupLastData)
	self:setCheckImage(groupHeadData,groupMidData,groupLastData)
end

function SSZCtr:acceptData(allCardByte)
	for i = 1, #allCardByte do
		if i <= 3 then 
			table.insert(self.groupHead, allCardByte[i])
		elseif i > 3 and i <= 8 then 
			table.insert(self.groupMid, allCardByte[i])
		else
			table.insert(self.groupLast, allCardByte[i])
		end
	end
	self:startCheck()
end

--view调用发送数据
function SSZCtr:sendEvenWithData(data)
	if data then 
		self:initGround()
		self:acceptData(data)
	end	
end

function SSZCtr:getCoustomEvent()
	local function checkPaiXing(event)
		self:startCheck()
	end
	self.listener = cc.EventListenerCustom:create("time out",checkPaiXing) 
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listener, 1)
end

return SSZCtr;