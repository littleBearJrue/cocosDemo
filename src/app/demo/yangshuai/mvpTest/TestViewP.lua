--[[--ldoc desc
@module TestViewP
@author ShuaiYang

Date   2018-10-15 14:37:47
Last Modified by   ShuaiYang
Last Modified time 2018-11-02 16:36:26
]]
local appPath = "app.demo.yangshuai"
local TestViewP = class("TestViewP",cc.load("boyaa").mvp.BoyaaPresenter);

local TestView =  require(appPath..".mvpTest.TestView")
-- local TestViewBehavior =  require(appPath..".testView.TestViewBehavior")
-- local TestObserverBehavior =  require(appPath..".testView.TestObserverBehavior")


local EvenConfig = {
	TestEven = "myTest",
}



function TestViewP:ctor()
	-- body
	print("TestViewP");
	self.con = 0;
end

function TestViewP:initView(isBehavior)
	-- body
	local testView = TestView.new();

	-- if isBehavior == 1 then
 --    	testView:bindBehavior(TestViewBehavior);
	-- elseif isBehavior == 2 then
 --    	testView:bindBehavior(TestObserverBehavior);
		
	-- end

    -- testView:bindCtr(self);
    self:inputViewInterface(testView,TestView.interface)
    testView:addBtn();
    testView:move(display.center);

    print("testView.cardStyle ========== "..testView.cardStyle)

    testView.cardStyle = "22222";
end


function TestViewP:registeredTest_p()
	-- body
	self:bindEventListener(EvenConfig.TestEven,function (event)
		-- body
		self:getView():showDiyView(event._usedata.str);

	end)
end

function TestViewP:schedulerTest_p(data)
	dump(data,"测试参数")
	-- body
	self.sd = self:scheduler(function ()
		-- body
		self:getView():showSchedulerTestView(self.con);
		self.con = self.con +1;

	end,0.5,false);
end

function TestViewP:unSchedulerTest_p()
	-- body
	print("====unSchedulerTest======")
	self:unScheduler(self.sd);
end

function TestViewP:sendEven_p()
	-- body
	self:sendEvenData(EvenConfig.TestEven,{str = "我是自定义事件"});
end

return TestViewP;