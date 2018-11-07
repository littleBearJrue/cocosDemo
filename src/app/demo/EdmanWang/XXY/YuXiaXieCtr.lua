-- @Author: EdmanWang
-- @Date:   2018-10-23 18:12:30
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-29 17:39:29
local YuXiaXieCtr = class("YuXiaXieCtr",cc.load("boyaa").mvc.BoyaaCtr);
local YuXiaXieView =  require("app.demo.EdmanWang.XXY.YuXiaXieView");

local EvenConfig = {
	sprite_Even = "sprite_Even",
}

--[[-需要做的事拿到对应的筹码值，并且-]]
function YuXiaXieCtr:ctor()

end

function YuXiaXieCtr:initView()
	local YuXiaXieView = YuXiaXieView.new();
	YuXiaXieView:bindCtr(self);
	self:registerEvent();
end

function YuXiaXieCtr:registerEvent(  )
	self:bindEventListener(EvenConfig.sprite_Even,function (event)
		print("YuXiaXieCtr:registerEvent",event._usedata.chip_data);
		local params = event._usedata.chip_data;
		self:getView():createSprite(params);
	end)
end

return YuXiaXieCtr;