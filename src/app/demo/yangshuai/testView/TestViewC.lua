--[[--ldoc desc
@module TestViewC
@author ShuaiYang

Date   2018-10-15 14:37:47
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:07:43
]]
local appPath = "app.demo.yangshuai"
local TestViewC = class("TestViewC",cc.load("boyaa").mvc.BoyaaCtr);

local TestView =  require(appPath..".testView.TestView")
local TestViewBehavior =  require(appPath..".testView.TestViewBehavior")
local TestObserverBehavior =  require(appPath..".testView.TestObserverBehavior")


local EvenConfig = {
	TestEven = "myTest",
}

function TestViewC:ctor()
	-- body
	print("TestViewC");
	self.con = 0;
end

function TestViewC:initView(isBehavior)
	-- body
	local testView = TestView.new();

	if isBehavior == 1 then
    	testView:bindBehavior(TestViewBehavior);
	elseif isBehavior == 2 then
    	testView:bindBehavior(TestObserverBehavior);
		
	end

    testView:bindCtr(self);
    testView:addBtn();
    testView:move(display.center);
end


function TestViewC:registeredTest()
	-- body
	self:bindEventListener(EvenConfig.TestEven,function (event)
		-- body
		self:getView():showDiyView(event._usedata.str);

	end)
end

function TestViewC:schedulerTest()
	-- body
	self.sd = self:scheduler(function ()
		-- body
		self:getView():showSchedulerTestView(self.con);
		self.con = self.con +1;

	end,0.5,false);
end

function TestViewC:unSchedulerTest()
	-- body
	print("====unSchedulerTest======")
	self:unScheduler(self.sd);
end

function TestViewC:sendEven()
	-- body
	self:sendEvenData(EvenConfig.TestEven,{str = "我是自定义事件"});
end

return TestViewC;