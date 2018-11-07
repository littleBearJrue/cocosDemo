
local ViewBase = cc.load("mvc").ViewBase;
local ViewCtr = class("ViewCtr",ViewBase);

---配置事件监听函数
ViewCtr.eventFuncMap =  {

}

function ViewCtr:ctor(delegate)
	ViewBase.ctor(self);
	self.mDelegate = delegate; --对应的view ui
	self:registerEvent();
end

function ViewCtr:onCleanup()
	self.mDelegate = nil;
	self:unRegisterEvent();
end

---获取UI
function ViewCtr:getUI()
	return self.mDelegate;
end

---注册监听事件
function ViewCtr:registerEvent()
	if self.eventFuncMap then
	    for k,v in pairs(self.eventFuncMap) do
	        assert(self[v],"配置的回调函数不存在")
	        g_eventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function ViewCtr:unRegisterEvent()
	if g_eventDispatcher then
		g_eventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

---刷新UI
function ViewCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function ViewCtr:haldler(status,...)
end

return ViewCtr;