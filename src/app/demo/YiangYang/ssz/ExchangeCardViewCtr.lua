-- @Author: YiangYang
-- @Date:   2018-10-31 11:12:30
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-11-02 15:54:16
local ExchangeCardViewCtr = class("ExchangeCardViewCtr",cc.load("boyaa").mvc.BoyaaCtr)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend

local ExchangeCardView = import(".ExchangeCardView")
local PaiXingUtil = import(".PaiXingUtil")


--测试数据
local testData = {	
					0x31,0x11,0x25,
					0x13,0x4a,0x1d,0x12,0x14,
					0x39,0x19,0x29,0x49,0x15,
				}

function ExchangeCardViewCtr:ctor()

	local view = ExchangeCardView:create()
	view:bindCtr(self)
	self:setView(view)

	self.cardBytes = {} --牌值集合 
	self.cardBytes = testData 

	--获取牌型
	local paixing = self:getGroupType(self.cardBytes)
	self:updateView(testData,paixing)

end


--获取牌型
function ExchangeCardViewCtr:getGroupType(cardBytes)
	if not cardBytes or #cardBytes~=13 then return end
	
	local ag = {}
	local bg= {}
	local cg = {}
	for i=1,13 do
		if i < 4 then
			table.insert(ag,cardBytes[i])
		elseif i < 9 then
			table.insert(bg,cardBytes[i])
		else
			table.insert(cg,cardBytes[i])
		end
	end

	return PaiXingUtil.getSortThreePaiXingData({ag,bg,cg})
end


--发送消息通知后端牌值变化
function ExchangeCardViewCtr:sendReq( ... )
	-- body
end

--更新牌值列表
function ExchangeCardViewCtr:updateCardBytes(cardBytes)
	self.cardBytes = cardBytes
	self:sendReq()
	--获取牌型
	local paixing = self:getGroupType(self.cardBytes)
	self:getView():showPaiXing(paixing)
end


--2,3排数据调换
function ExchangeCardViewCtr:exchange23CardGroup()
	
	for i=4,8 do
		local tem = 0
		tem = self.cardBytes[i]
		self.cardBytes[i] = self.cardBytes[i+5]
		self.cardBytes[i+5] = tem
	end

	--获取牌型
	local paixing = self:getGroupType(self.cardBytes)
	--发送消息通知view
	self:getView():updateExchange23CardGroup(self.cardBytes,paixing)
end

--更新view
--data 牌值数据
--pxData 牌型数据
function ExchangeCardViewCtr:updateView(data,pxData)
	local view = self:getView()
	if view then
		view:updateView(data,pxData)
	end
end



return ExchangeCardViewCtr