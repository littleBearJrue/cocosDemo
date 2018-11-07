--[[--ldoc desc
@module RankCtr
@author FuYao
Date   2018-10-24
]]
local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RankCtr = class("RankCtr",ViewCtr);
BehaviorExtend(RankCtr);

local extend = import("framework.extend");
schedule = extend.Schedule;

---配置事件监听函数
RankCtr.eventFuncMap =  {
}

function RankCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
	self:doSomething();
end

function RankCtr:onCleanup()
	print("RankCtr:onCleanup")
	if self.eventObj then
		self.eventObj:cancel();
		self.eventObj = nil;
	end
	ViewCtr.onCleanup(self);
end

function RankCtr:onEnter()
	if self.eventObj then
		self.eventObj:resume();
	end
end
function RankCtr:onExit()
	if self.eventObj then
		self.eventObj:pause();
	end
end

---刷新UI
function RankCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

function RankCtr:haldler(status)
	if status == "changeScene" then
		local SceneTest = import("dev.demo.templateDemo.userInfo").scene
    	local scene = SceneTest:create()
    	cc.Director:getInstance():pushScene(scene);
    end
end

function RankCtr:doSomething()
	self.eventObj = schedule:schedule(function(dt)
			self:updateView({time = os.time()});
		end,1,50)
end

return RankCtr;