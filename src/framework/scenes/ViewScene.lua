
local SceneBase = cc.load("mvc").SceneBase;
local ViewScene = class("ViewScene",SceneBase);

function ViewScene:ctor()
	SceneBase.ctor(self);
	self:createUI();
end

--创建UI
function ViewScene:createUI()
end

--获取UI
function ViewScene:getUI()
	return self.mUI;
end
return ViewScene;