--[[--ldoc desc
@module DialogCtr
@author FuYao
Date   2018-10-25
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DialogCtr = class("DialogCtr",ViewCtr);
BehaviorExtend(DialogCtr);

---配置事件监听函数
DialogCtr.eventFuncMap =  {
}

function DialogCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function DialogCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function DialogCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function DialogCtr:haldler(status,...)
end

return DialogCtr;