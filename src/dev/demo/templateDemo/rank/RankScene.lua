--[[--ldoc desc
@module RankScene
@author FuYao

Date   2018-10-24
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RankScene = class("RankScene",ViewScene);
BehaviorExtend(RankScene);

function RankScene:ctor()
	self:createUI();
end

function RankScene:onCleanup()
	-- 释放资源
	print("RankScene:onCleanup")
end

--创建UI
function RankScene:createUI()
	if self.mUI then
		return false;
	else
		local ViewUI = require(".RankUI");
		self.mUI = ViewUI:create(self);
		self:add(self.mUI);--添加到当前场景 不需要主动删除
		return true;
	end
end

--获取UI
function RankScene:getUI()
	return self.mUI;
end

return RankScene;