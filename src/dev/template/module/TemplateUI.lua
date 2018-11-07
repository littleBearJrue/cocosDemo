--[[--ldoc desc
@module TemplateUI
@author %s

Date   %s
]]
local ViewUI = import("framework.scenes").ViewUI
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TemplateUI = class("TemplateUI",ViewUI);
BehaviorExtend(TemplateUI);

function TemplateUI:ctor()
	ViewUI.ctor(self);
	self:bindCtr(require(".TemplateCtr"));
	self:init();
end

function TemplateUI:onCleanup()
	self:unBindCtr();
end

function TemplateUI:init()
	-- do something
	
	-- 加载布局文件
	-- local view = self:loadLayout("aa.creator");
	-- self:add(view);
	
end

---刷新界面
function TemplateUI:updateView(data)
	data = checktable(data);
end

return TemplateUI;