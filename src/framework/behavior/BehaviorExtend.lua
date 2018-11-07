--[[
	组件扩展实现
]]
local BehaviorFactory = require(".BehaviorFactory");

local BehaviorExtend

---组件扩展接口，可以让一个表支持组件机制
BehaviorExtend = function(ClassExtend)

	---是否有组件
	function ClassExtend:hasBehavior(behavior)
		local behaviorName = tostring(behavior);
	    return self.behaviorObjects_ and self.behaviorObjects_[behaviorName] ~= nil
	end

	--[[--
		获取对象绑定的组件
	]]
	function ClassExtend:getBehavior(behavior)
		local behaviorName = tostring(behavior);
	    return self.behaviorObjects_[behaviorName]
	end

	---绑定组件
	--@string behaviorName 组件名称
	function ClassExtend:bindBehavior(behavior)
		assert(behavior,"必须填入组件类")
		local behaviorName = tostring(behavior);
	    if not self.behaviorObjects_ then self.behaviorObjects_ = {} end
	    if self.behaviorObjects_[behaviorName] then return end

	    local behavior = BehaviorFactory.createBehaviorByClass(behavior)
	    for i, dependBehaviorName in pairs(behavior:getDepends()) do
	        self:bindBehavior(dependBehaviorName)
	        if not self.behaviorDepends_ then
	            self.behaviorDepends_ = {}
	        end
	        if not self.behaviorDepends_[dependBehaviorName] then
	            self.behaviorDepends_[dependBehaviorName] = {}
	        end
	        table.insert(self.behaviorDepends_[dependBehaviorName], behaviorName)
	    end

	    behavior:bind(self)
	    self.behaviorObjects_[behaviorName] = behavior
	    self:resetAllBehaviors()

	    return behavior;
	end

	---解绑组件
	--@string behaviorName 组件名称
	function ClassExtend:unBindBehavior(behavior)
		local behaviorName = tostring(behavior);
	    assert(self.behaviorObjects_ and self.behaviorObjects_[behaviorName] ~= nil,
	           string.format("GameObject:unBindBehavior() - behavior %s not binding", behaviorName))
	    assert(not self.behaviorDepends_ or not self.behaviorDepends_[behaviorName],
	           string.format("GameObject:unBindBehavior() - behavior %s depends by other binding", behaviorName))

	    local behavior = self.behaviorObjects_[behaviorName]
	    for i, dependBehaviorName in pairs(behavior:getDepends()) do
	        for j, name in ipairs(self.behaviorDepends_[dependBehaviorName]) do
	            if name == behaviorName then
	                table.remove(self.behaviorDepends_[dependBehaviorName], j)
	                if #self.behaviorDepends_[dependBehaviorName] < 1 then
	                    self.behaviorDepends_[dependBehaviorName] = nil
	                end
	                break
	            end
	        end
	    end

	    behavior:unBind(self)
	    self.behaviorObjects_[behaviorName] = nil

	    ---强制调用dtor
	    if true then
	       delete(behavior);
	    end
	end

	function ClassExtend:unBindBehaviorByBehavior(behavior)
		assert(behavior ~= nil and behavior.priority_ ~= nil and behavior.name_ ~= nil,string.format("BehaviorObject:unBindBehaviorByBehavior - behavior is not exist,",behavior))
		local className = behavior.name_;
		local bh;
		for k, v in pairs(self.behaviorObjects_) do 
			if className == v.name_ then
				bh = k;
			end
		end
		assert(bh ~= nil,string.format("BehaviorObject:unBindBehaviorByBehavior - behavior is not bind,",behavior))
		if bh then
		    local behavior = self.behaviorObjects_[bh]
		    for i, dependBehaviorName in pairs(behavior:getDepends()) do
		        for j, name in ipairs(self.behaviorDepends_[dependBehaviorName]) do
		            if name == behaviorName then
		                table.remove(self.behaviorDepends_[dependBehaviorName], j)
		                if #self.behaviorDepends_[dependBehaviorName] < 1 then
		                    self.behaviorDepends_[dependBehaviorName] = nil
		                end
		                break
		            end
		        end
		    end

		    behavior:unBind(self)
		    self.behaviorObjects_[bh] = nil
		    ---强制调用dtor
		    if true then
		       delete(behavior);
		    end
		end

	end

	---解绑所有组件
	function ClassExtend:unBindAllBehavior()
	    if self.behaviorObjects_ == nil then
	        return;
	    end
	    for k,behavior in pairs(self.behaviorObjects_) do
	        for i, dependBehaviorName in pairs(behavior:getDepends()) do
	            for j, name in ipairs(self.behaviorDepends_[dependBehaviorName]) do
	                if name == behaviorName then
	                    table.remove(self.behaviorDepends_[dependBehaviorName], j)
	                    if #self.behaviorDepends_[dependBehaviorName] < 1 then
	                        self.behaviorDepends_[dependBehaviorName] = nil
	                    end
	                    break
	                end
	            end
	        end
	        behavior:unBind(self)
	        ---强制调用dtor
	        if true then
	           delete(behavior);
	        end
	    end
	    self.behaviorObjects_ = {};
	end

	function ClassExtend:resetAllBehaviors()
	    if not self.behaviorObjects_ then return end

	    local behaviors = {}
	    for i, behavior in pairs(self.behaviorObjects_) do
	        behaviors[#behaviors + 1] = behavior
	    end
	    table.sort(behaviors, function(a, b)
	        return a:getPriority() > b:getPriority()
	    end)
	    for i, behavior in ipairs(behaviors) do
	        behavior:reset(self)
	    end
	end

	--[[--
	绑定一个组件的方法
	@param behavior 组件实例
	@string methodName 导出的接口名称
	@param method 绑定的接口
	@param deprecatedOriginMethod  是否废弃之前的函数，只用当前
	@bool callOriginMethodLast 是否最后调用上一个组件函数
	@usage
	object:bindMethod(self, "setHeadImg",   handler(self, self.setHeadImg)); --导出组件setHeadImg接口
	]]
	function ClassExtend:bindMethod(behavior, methodName, method,deprecatedOriginMethod,callOriginMethodLast)
	    local originMethod = self[methodName] --取出之前的方法
	    if not originMethod then
	        self[methodName] = method
	        return
	    end
	    
	    if not self.bindingMethods_ then self.bindingMethods_ = {} end
	    if not self.bindingMethods_[methodName] then self.bindingMethods_[methodName] = {} end

	    local chain = {behavior, originMethod}
 
	    local newMethod
	    if deprecatedOriginMethod == true then
	        newMethod = function(...)
	            return method(...)
	        end
	    elseif callOriginMethodLast == true then
	        newMethod = function(...)
	            method(...)
	            return chain[2](...);
	        end
	    else
	        newMethod = function(...)
	            local ret = chain[2](...)
	            if ret then
	                local args = {...}
	                args[#args + 1] = ret
	                return method(unpack(args))
	            else
	                return method(...)
	            end
	        end
	    end

	    self[methodName] = newMethod --新的方面 会调用之前的同名方法
	    chain[3] = newMethod
	    table.insert(self.bindingMethods_[methodName], chain)
	end


	function ClassExtend:unbindMethod(behavior, methodName)
	    if not self.bindingMethods_ or not self.bindingMethods_[methodName] then
	        self[methodName] = nil
	        return
	    end

	    local methods = self.bindingMethods_[methodName]
	    local count = #methods
	    for i = count, 1, -1 do
	        local chain = methods[i]

	        if chain[1] == behavior then
	            -- print(string.format("[%s]:unbindMethod(%s, %s)", tostring(self), behavior:getName(), methodName))
	            if i < count then
	                -- 如果移除了中间的节点，则将后一个节点的 origin 指向前一个节点的 origin
	                -- 并且对象的方法引用的函数不变
	                -- print(string.format("  remove method from index %d", i))
	                methods[i + 1][2] = chain[2]
	            elseif count > 1 then
	                -- 如果移除尾部的节点，则对象的方法引用的函数指向前一个节点的 new
	                self[methodName] = methods[i - 1][3]
	            elseif count == 1 then
	                -- 如果移除了最后一个节点，则将对象的方法指向节点的 origin
	                self[methodName] = chain[2]
	                self.bindingMethods_[methodName] = nil
	            end

	            -- 移除节点
	            table.remove(methods, i)
	            break
	        end
	    end
	end
end;


return BehaviorExtend;