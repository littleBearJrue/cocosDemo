--[[--ldoc desc
@module OutCardViewCtrl
@author JrueZhu

Date   2018-10-24 10:40:22
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:49:20
]]


local appPath = "app.demo.JrueZhu"
local OutCardViewCtrl = class("OutCardViewCtrl",cc.load("boyaa").mvc.BoyaaCtr);
local OutCardView = require(appPath..".cardLayer.outCard.OutCardView");

function OutCardViewCtrl:ctor( ... )
	self:initConfig();
	
	local outCardView = OutCardView:create();
    outCardView:bindCtr(self);
end

function OutCardViewCtrl:initConfig()
	self.remainCardList = {};
	self.discardList = {};
	self.remainCardsNum = #self.remainCardList;
	self.discardNum = #self.discardList;

end

function OutCardViewCtrl:dealCard(data)
	for i, v in ipairs(data) do
		table.insert(self.remainCardList, v);
	end
	self.remainCardsNum = #self.remainCardList;
	self.view:updateRemainCardView();
end

function OutCardViewCtrl:updateDiscard(data)
	for i, v in ipairs(data) do
		table.insert(self.discardList, v);
	end
	self.discardNum = #self.discardList;
	-- 只显示最后一张牌
	self.view:updateDiscardView(self.discardList[#self.discardList]);
end

return OutCardViewCtrl;