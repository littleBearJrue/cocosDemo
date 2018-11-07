--[[--ldoc desc
@module DialogUI
@author FuYao

Date   2018-10-25
]]
local ViewUI = import("framework.scenes").ViewUI
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DialogUI = class("DialogUI",ViewUI);
BehaviorExtend(DialogUI);

function DialogUI:ctor()
	ViewUI.ctor(self);
	self:bindCtr(require(".DialogCtr"));
	self:init();
end

function DialogUI:onCleanup()
	self:unBindCtr();
end

function DialogUI:init()
	-- do something
	
	-- 加载布局文件
	-- local view = self:loadLayout("aa.creator");
	-- self:add(view);
	local tx = cc.Label:createWithSystemFont("弹窗模块","",36);
	tx:setPosition(display.cx,display.cy-100);
	self:addChild(tx);
	
end

---刷新界面
function DialogUI:updateView(data)
	data = checktable(data);
end

return DialogUI;