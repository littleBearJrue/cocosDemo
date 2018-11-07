--[[--ldoc desc
@module HandCardViewCtrl
@author JrueZhu

Date   2018-10-24 10:36:47
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:48:49
]]

local appPath = "app.demo.JrueZhu"
local HandCardViewCtrl = class("HandCardViewCtrl",cc.load("boyaa").mvc.BoyaaCtr);
local HandCardView = require(appPath..".cardLayer.handCard.HandCardView");

function HandCardViewCtrl:ctor( ... )
	self:initConfig();
    local handCardView = HandCardView:create();

    handCardView:bindCtr(self);
end

function HandCardViewCtrl:initConfig( )
	self.handCardList = {};
	self.selectCardList = {};
	self.seatId = 1;
	self.cardsNum = #self.handCardList;
end

function HandCardViewCtrl:dealCard(data)
    self.seatId = data.seatId;
	self.view:createHandCards(data);
	-- 注册每张牌的点击事件
	for i, card in ipairs(self.handCardList) do
		if self.seatId == 1 and card.cardStyle == "liang" then
			self:setCardTouchEvent(card);
		end
	end
end



function HandCardViewCtrl:outCard(data)
	self.view:executeOutCardAnim(data);
end


function HandCardViewCtrl:setCardTouchEvent(card)
  	card:setTouchEnabled(true)
    card:addTouchEventListener(function(card, eventType)        
        if (ccui.TouchEventType.began == eventType)  then            
            
        elseif (ccui.TouchEventType.moved == eventType)  then              
         
        elseif  (ccui.TouchEventType.ended == eventType) then
          
     		if self.selectCardList and #self.selectCardList > 0 then
     			if self.selectCardList[1] == card then
     				self.view:turnCardPos(card, "in");
     				self.selectCardList = {};
     			else
     				-- 先将选择的牌还原位置
     				self.view:turnCardPos(self.selectCardList[1], "in");
     				-- 再将选择的牌改变位置
     				self.view:turnCardPos(card, "out");
     				-- 最终将选中的牌放入选中的数据表中
     				self.selectCardList = {}
     				table.insert(self.selectCardList, card)
     			end
     		else
     			-- 此时未出现选中的牌
     			self.view:turnCardPos(card, "out");
     			table.insert(self.selectCardList, card)
     		end
        elseif  (ccui.TouchEventType.canceled == eventType) then                
        end    
    end)
end

return HandCardViewCtrl;