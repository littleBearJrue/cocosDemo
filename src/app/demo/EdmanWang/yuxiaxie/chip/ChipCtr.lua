-- @Author: EdmanWang
-- @Date:   2018-10-24 09:41:47
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-24 15:01:08
local ChipCtr = class("ChipCtr",cc.load("boyaa").mvc.BoyaaCtr);
local ChipView =  import("app.EdmanWang.yuxiaxie.chip.ChipView");


function ChipCtr:ctor()
    self:initView();
end

function ChipCtr:initView()
	local ChipView = ChipView.new();
    self:setView(ChipView);
end 

return ChipCtr;

