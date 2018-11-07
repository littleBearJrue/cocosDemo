local BetViewCtr = class("BetViewCtr",cc.load("boyaa").mvc.BoyaaCtr);

local DeskView = require("app.demo.DowneyTang.DeskView.DeskView")
local DeskViewConfig = require("app.demo.DowneyTang.DeskView.DeskViewConfig")
local DeskViewBehavior =  require("app.demo.DowneyTang.DeskView.DeskViewBehavior")
local BigChipView = require("app.demo.DowneyTang.BigChipView.BigChipView")

function BetViewCtr:ctor()
	print("BetViewCtr");
end

function BetViewCtr:initView(isBehavior)
	--【创建牌桌，添加组件划分不同的触摸区域】
	local newDeskView = DeskView.new();
	if isBehavior == 1 then
    	newDeskView:bindBehavior(DeskViewBehavior);
	elseif isBehavior == 2 then
    	newDeskView:bindBehavior(DeskViewObserverBehavior);	
	end
	newDeskView:bindCtr(self);
	local spaceMap = DeskViewConfig:getSpaceMap()
	newDeskView:addTouchSpace(spaceMap)
    newDeskView:setScale(0.5)
	newDeskView:setPosition(600,420)
	
	--【创建大筹码】
	local newBigChipView = BigChipView.new()
	newDeskView:bindCtr(self);
	newBigChipView:setScale(0.6)
	newBigChipView:setPosition(600,100)


	local node = cc.Node:create();
	newDeskView:addTo(node)
	newBigChipView:addTo(node)
	self:setView(node)
end


function BetViewCtr:registeredTest()
	-- body
	self:bindEventListener(EvenConfig.TestEven,function (event)
		-- body
		self:getView():showDiyView(event._usedata.str);

	end)
end

function BetViewCtr:schedulerTest()
	-- body
	self.sd = self:scheduler(function ()
		-- body
		self:getView():showSchedulerTestView(self.con);
		self.con = self.con +1;

	end,0.5,false);
end

function BetViewCtr:unSchedulerTest()
	-- body
	print("====unSchedulerTest======")
	self:unScheduler(self.sd);
end

function BetViewCtr:sendEven()
	-- body
	self:sendEvenData(EvenConfig.TestEven,{str = "我是自定义事件"});
end


return BetViewCtr;