--[[
	组件基类，所有组件必须继承该类
]]

---组件基类

local BehaviorBase = class("BehaviorBase")

BehaviorBase.className = "BehaviorBase"

function BehaviorBase:ctor(behaviorName, depends, priority, conflictions)
    self.name_         = behaviorName
    self.depends_      = checktable(depends)
    self.priority_     = checkint(priority) -- 行为集合初始化时的优先级，越大越先初始化
end

function BehaviorBase:getName()
    return self.name_
end

--[[--
获取当前组件的依赖组件
]]
function BehaviorBase:getDepends()
    return self.depends_
end

--[[--
获取当前组件的优先级
]]
function BehaviorBase:getPriority()
    return self.priority_
end

--[[--
组件绑定对象
]]
function BehaviorBase:bind(object)

end

--[[--
组件解绑对象
]]
function BehaviorBase:unBind(object)
end

--[[--
重置组件，按优先级调用
]]
function BehaviorBase:reset(object)

end

--[[--
获取导出属性
]]
function BehaviorBase:getExportProperties()
    return self.exportpProperties_
end


return BehaviorBase
