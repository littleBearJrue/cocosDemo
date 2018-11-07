--[[--ldoc desc
@module UserInfoCtr
@author FuYao
Date   2018-10-24
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local UserInfoCtr = class("UserInfoCtr",ViewCtr);
BehaviorExtend(UserInfoCtr);

---配置事件监听函数
UserInfoCtr.eventFuncMap =  {
	[1] = "tests"
}

function UserInfoCtr:ctor(delegate)
	ViewCtr.ctor(self);
	self.mDelegate = delegate; --对应的view ui
end

function UserInfoCtr:onCleanup()
	ViewCtr.onCleanup(self);
	self.mDelegate = nil;
	print("UserInfoCtr:onCleanup")
end

---获取UI
function UserInfoCtr:getUI()
	return self.mDelegate;
end

function UserInfoCtr:tests()
	
end

---刷新UI
function UserInfoCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

function UserInfoCtr:haldler(status,...)
	if status == "popScene" then
		cc.Director:getInstance():popScene();
    end
end

return UserInfoCtr;