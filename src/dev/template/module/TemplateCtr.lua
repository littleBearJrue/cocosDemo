--[[--ldoc desc
@module TemplateCtr
@author %s
Date   %s
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TemplateCtr = class("TemplateCtr",ViewCtr);
BehaviorExtend(TemplateCtr);

---配置事件监听函数
TemplateCtr.eventFuncMap =  {
}

function TemplateCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function TemplateCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function TemplateCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function TemplateCtr:haldler(status,...)
end

return TemplateCtr;