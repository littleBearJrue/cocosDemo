--[[--ldoc desc
@module UserInfoUI
@author FuYao

Date   2018-10-24
]]
local ViewUI = import("framework.scenes").ViewUI
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local UserInfoUI = class("UserInfoUI",ViewUI);
BehaviorExtend(UserInfoUI);

function UserInfoUI:ctor()
	ViewUI.ctor(self);
	self:bindCtr(require(".UserInfoCtr"));
	self:init();
end


function UserInfoUI:onCleanup()
	print("UserInfoUI:onCleanup")
	self:unBindCtr();
end

function UserInfoUI:init()
	local tx = cc.Label:createWithSystemFont("个人信息","",36);
	tx:setPosition(display.cx,display.height - 30);
	self:addChild(tx);

	local function onChangeScene()
		self:doLogic("popScene");
	end
	local  item1 = cc.MenuItemFont:create("返回排行榜界面")
    item1:registerScriptTapHandler(onChangeScene)

    local  menu = cc.Menu:create(item1)
    menu:alignItemsVertically()
    self:addChild(menu)

end

---刷新界面
function UserInfoUI:updateView(data)
	data = checktable(data);

	local view = self:loadLayout("xxx");
end

return UserInfoUI;