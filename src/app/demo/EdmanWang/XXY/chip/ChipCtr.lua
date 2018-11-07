-- @Author: EdmanWang
-- @Date:   2018-10-24 09:41:47
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-29 17:44:41
local ChipCtr = class("ChipCtr",cc.load("boyaa").mvc.BoyaaCtr);
local ChipView =  require("app.demo.EdmanWang.XXY.chip.ChipView");

local EvenConfig = {
	sprite_Even = "sprite_Even",
}

function ChipCtr:ctor()
   
end

function ChipCtr:dispatcherEvent(data)
	self:sendEvenData(EvenConfig.sprite_Even,{chip_data = data});
end

function ChipCtr:initView()
	print("ChipCtr:initView");
	local ChipView = ChipView.new();
	ChipView:bindCtr(self);
end 

return ChipCtr;

