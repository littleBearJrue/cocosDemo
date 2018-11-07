--[[--ldoc desc
@module HandCardCtr
@author ShuaiYang

Date   2018-10-24 10:25:23
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:07:57
]]
local appPath = "app.demo.yangshuai"
local HandCardCtr = class("HandCardCtr",cc.load("boyaa").mvc.BoyaaCtr);
local HandCardView =  require(appPath..".PlayCard.HandCard.HandCardView")
local EvenConfig =  require(appPath..".PlayCard.EvenConfig")

function HandCardCtr:ctor()
  	print("HandCardCtr");
    self.cards = {};
    self.selectedCards = {};
end

function HandCardCtr:initView(id,isShow)
	-- body
	local handCardView = HandCardView.new();
	handCardView:bindCtr(self)
	handCardView:isShowCard(isShow)

	self.localId = id;
	print("-------------HandCardCtr:initView-------------"..self:getUserId().."====data:"..id)

	-- local data1 = {
	-- 	_usedata={
	-- 		cards = {
	-- 			[1] = 0x12,
	-- 			[2] = 0x12,
	-- 			[3] = 0x12,
	-- 			[4] = 0x12,
	-- 		}
	-- 	},
	-- }
	-- self:dealCard(data1)
    self:initEvent()

end


function HandCardCtr:getUserId()
	-- body
	return self.localId;
end

function HandCardCtr:dealCard(event)
	print("-------------HandCardCtr:dealCard-------------"..self:getUserId())
	dump(event._usedata.cards,"event ==== ")
	if event._usedata.id ~= self:getUserId() then
		return
	end
	if event._usedata.cards then
		local cards = event._usedata.cards;
		local newCardDatas = self:getView():addCards(cards)
		table.merge(cards,newCardDatas);
	end

end

function HandCardCtr:initEvent()
	-- body
	self:bindSelfFun(EvenConfig.moPai,"moPai")
	self:bindSelfFun(EvenConfig.faPai,"dealCard")
end

function HandCardCtr:chuPai()
	
	
	if table.nums(self.selectedCards) == 0 then
		print("必须选择一张牌")
		return
	end

	if table.nums(self.selectedCards) > 1 then
		print("只能出一张牌")
		return
	end
	local cardData = self.selectedCards[1];
	self:getView():removeCard(cardData);
	table.remove(self.selectedCards,1);
	
	self:sendEvenData(EvenConfig.chuPai,{id = self.localId,byte = cardData.byte});
	if #self.selectedCards == 0 then
		self:getView().chuBaiBtn:setVisible(false)
	end
end

function HandCardCtr:moPai(event)
	-- body


	if event._usedata.data ~= self.localId then
		return
	end

	if event._usedata.cardByte then
		self:getView():addCard(event._usedata.cardByte);
	end

end

function HandCardCtr:addSelectedCard(data)
	-- body
	if data and data.byte and data.name then
		table.insert(self.selectedCards,data);
		self:getView().chuBaiBtn:setVisible(true)
	end
	
end

function HandCardCtr:removeSelectedCard(data)
	-- body
	if data and data.byte and data.name then
		for i,v in ipairs(self.selectedCards) do
			if v.name == data.name and v.byte == data.byte then
				table.remove(self.selectedCards,i);
				if #self.selectedCards == 0 then
					self:getView().chuBaiBtn:setVisible(false)
				end

				break
			end
		end
	end
end

return HandCardCtr;