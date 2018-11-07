--[[--ldoc desc
@module RankUI
@author FuYao

Date   2018-10-24
]]
local ViewUI = import("framework.scenes").ViewUI
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RankUI = class("RankUI",ViewUI);
BehaviorExtend(RankUI);

function RankUI:ctor()
	ViewUI.ctor(self);
	self:bindCtr(require(".RankCtr"));
	self:init();
end

function RankUI:onCleanup()
	print("RankUI:onCleanup")
	self:unBindCtr();
end

function RankUI:init()
	local tx = cc.Label:createWithSystemFont("排行榜","",36);
	tx:setPosition(display.cx,display.height - 40);
	self:addChild(tx);

	self.time = cc.Label:createWithSystemFont("","",24);
	self.time:setPosition(display.width - 150,display.height - 40);
	self:addChild(self.time);

	local function onChangeScene()
		self:doLogic("changeScene");
	end
	local  item1 = cc.MenuItemFont:create("切换场景")
    item1:registerScriptTapHandler(onChangeScene)

    local  menu = cc.Menu:create(item1)
    menu:alignItemsVertically()
    self:addChild(menu)

    local aa = require(".a.aa")
    self:addChild(aa:create())

    -- 加载外部的模块
    local mod = import("dev.demo.templateDemo.dialog");
    self:addChild(mod.scene:create())
end

---刷新界面
function RankUI:updateView(data)
	data = checktable(data);
	if data.time then
		local format = "%m-%d-%H:%M:%S";
    	local str = os.date(format, data.time);
		self.time:setString("刷新时间：" .. str)
	end
end

return RankUI;