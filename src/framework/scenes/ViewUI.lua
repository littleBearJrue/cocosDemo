local ViewBase = cc.load("mvc").ViewBase;
local ViewUI = class("ViewUI",ViewBase);

function ViewUI:ctor()
	ViewBase.ctor(self);
end

---绑定控制器
function ViewUI:bindCtr(ctrClass)
	if self.mCtr then
		print("already bind ViewCtr");
		return false;
	else
		if ctrClass then
			self.mCtr = ctrClass:create(self);
			self:addChild(self.mCtr);
			return true;
		end
	end
end

---解除控制器的绑定
function ViewUI:unBindCtr()
	if self.mCtr then
		self:removeChild(self.mCtr,true);
		self.mCtr = nil;
	else
		print("unBindViewCtr failed");
	end
end

---获得控制器
function ViewUI:getCtr()
	return self.mCtr;
end

---加载布局文件
function ViewUI:loadLayout(viewLayout)
	return g_nodeUtils:getRootNodeInCreator(viewLayout);
end

---刷新界面
function ViewUI:updateView(data)
	data = checktable(data);
end

---触发逻辑处理
function ViewUI:doLogic(status,...)
	local ctr = self:getCtr();
	if ctr then
		ctr:haldler(status,...);
	end
end

return ViewUI;