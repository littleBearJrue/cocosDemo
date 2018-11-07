--[[--ldoc desc
@module TemplateScene
@author %s

Date   %s
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TemplateScene = class("TemplateScene",ViewScene);
BehaviorExtend(TemplateScene);

function TemplateScene:ctor()
	self:createUI();
end

function TemplateScene:onCleanup()
	-- 释放资源
	-- xxxxxxxxxxxxx
end

--创建UI
function TemplateScene:createUI()
	if self.mUI then
		return false;
	else
		local ViewUI = require(".TemplateUI");
		self.mUI = ViewUI:create(self);
		self:add(self.mUI);--添加到当前场景 不需要主动删除
		return true;
	end
end

--获取UI
function TemplateScene:getUI()
	return self.mUI;
end

return TemplateScene;