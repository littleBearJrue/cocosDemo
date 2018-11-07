--[[--ldoc desc
@module UserInfoScene
@author FuYao

Date   2018-10-24
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local UserInfoScene = class("UserInfoScene",ViewScene);
BehaviorExtend(UserInfoScene);

function UserInfoScene:ctor()
	ViewScene.ctor(self);
	self:createUI();
end

function UserInfoScene:onCleanup()
	print("UserInfoScene:onCleanup")
end

--创建UI
function UserInfoScene:createUI(reload)
	if self.mUI then
		return false;
	else
		local ViewUI 	= require(".UserInfoUI");
		self.mUI = ViewUI:create(self);
		self:add(self.mUI);--添加到当前场景 不需要主动删除
		return true;
	end
end

--获取UI
function UserInfoScene:getUI()
	return self.mUI;
end

return UserInfoScene;