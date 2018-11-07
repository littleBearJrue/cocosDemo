local TestView = class("TestView",cc.load("boyaa").mvp.BoyaaViewWidget);
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


TestView.interface = {
	"schedulerTest_p",
	"unSchedulerTest_p",
	"registeredTest_p",
	"sendEven_p",
}

--[[--
TestView.interface 导出接口

接口名称：schedulerTest_p
@param data 测试参数
数据结构为 {test1 = "",test2 = "" }
@usage

接口名称：unSchedulerTest_p
@usage


接口名称：registeredTest_p
@usage


接口名称：sendEven_p
@usage


]]






function TestView:ctor()
    -- body
    -- cc.Label:createWithSystemFont("Hello World", "Arial", 40)
    -- :addTo(self)
    -- self:setColor(cc.c3b(201, 201, 40));
	self.layout = ccui.Layout:create()
    self.layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	self.layout:addTo(self);
    
    print("TestView:ctor")

    self:initMkproprety(TestView)

 --    local peer = tolua.getpeer(self)
	-- local mt = getmetatable(peer)
	-- local __index = mt.__index
	-- mt.__index = function(_, k)
	-- 	if type(TestView[k]) == "table" and TestView[k].proprety == true then
	-- 		return TestView[k].get(self)
	-- 	elseif __index then
	-- 		if type(__index) == "table" then
	-- 			return __index[k]
	-- 		elseif type(__index) == "function" then
	-- 			return __index(_, k)
	-- 		end
	-- 	end
	-- end
	-- mt.__newindex = function(_, k, v)
	-- 	if type(TestView[k]) == "table" and TestView[k].proprety == true then
	-- 		return TestView[k].set(self, v)
	-- 	else
	-- 		rawset(_, k, v)
	-- 	end
	-- end

	
	self.proprety = {
		cardTByte =" data.cardTByte or defaultData.cardTByte",
	}


end




TestView.cardStyle = TestView.mkproprety(function(self)
	dump(self,"TestView.mkproprety --------- self")
	return "self.proprety.cardStyle"
end,function(self, cardStyle)
	dump(self,"TestView.mkproprety --------- self")
	dump(cardStyle,"TestView.mkproprety --------- cardStyle")
end)


function TestView:schedulerTest()
	-- body
	local data = { test1 = "1111",test2 = "22222" }
	self:schedulerTest_p(data);

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
	self:unSchedulerTest_p();
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
	self:registeredTest_p();
end

function TestView:sendEvenDiy()
	-- body
	self:sendEven_p();
end


function TestView:showDiyView(name)
	-- body

	local btn = ccui.Button:create();
	btn:setTitleText(name);
	btn:addTo(self.layout);
end



return TestView;