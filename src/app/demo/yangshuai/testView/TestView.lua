local TestView = class("TestView",cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

BehaviorExtend(TestView);


TestView.btnList = {
	[1] = {
		name = "注册自定义事件",
		fn = "evenDiy",
	},
	[2] = {
		name = "发送自定义事件",
		fn = "sendEvenDiy",
	},
	[3] = {
		name = "测试调度器",
		fn = "schedulerTest",
	},
	[4] = {
		name = "取消测试调度器",
		fn = "unSchedulerTest",
	},

};

function TestView:ctor()
    -- body
    -- cc.Label:createWithSystemFont("Hello World", "Arial", 40)
    -- :addTo(self)
    -- self:setColor(cc.c3b(201, 201, 40));
	self.layout = ccui.Layout:create()
    self.layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	self.layout:addTo(self);
    
    print("TestView:ctor")
end

function TestView:schedulerTest()
	-- body
	self:getCtr():schedulerTest();

end

function TestView:showSchedulerTestView(con)
	-- body
	local name = string.format("当前调度器第%d次循环",con);
	if self.testLabel then
		self.testLabel:setString(name);
	else
		self.testLabel = cc.Label:create()
		self.testLabel:addTo(self.layout);
	end
	
end

function TestView:unSchedulerTest()
	-- body
	self:getCtr():unSchedulerTest();
end

function TestView:addBtn()
    -- layout大小
    -- layout:setContentSize(display.width,display.height)
    -- layout:setBackGroundColor(cc.c3b(255, 255, 0));
    -- layout:setPosition(0,0)

	-- body
	for i,v in ipairs(self.btnList) do
		local btn = ccui.Button:create();
		btn:setTitleText(v.name);
		btn:addClickEventListener(handler(self,self[v.fn]));
    	btn:addTo(self.layout);
	end
	-- for i,v in ipairs(self.ctr) do
		
	-- end
end

function TestView:evenDiy()
	-- body
	self.ctr:registeredTest();
end

function TestView:sendEvenDiy()
	-- body
	self.ctr:sendEven();
end


function TestView:showDiyView(name)
	-- body

	local btn = ccui.Button:create();
	btn:setTitleText(name);
	btn:addTo(self.layout);
end



return TestView;