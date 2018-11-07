--[[--组件基类，所有组件必须继承该类
@module BehaviorBase
@author YuchengMo

Date   2018-05-07 10:47:11
Last Modified by   ShuaiYang
Last Modified time 2018-10-22 17:58:01
]]

---组件基类
local BehaviorBase = class("BehaviorBase")


function BehaviorBase:ctor()
end

function BehaviorBase:getName()
	if not self.name_ then
    	self.name_ = self.__cname;
    end
    return self.name_
end


--[[--
设置当前组件名字
]]
function BehaviorBase:setName(name)
	self.name_ = name;
	-- body
end


--[[--
设置当前组件依赖
]]
function BehaviorBase:setDepends( depends )
	-- body
	self.depends_      = checktable(depends)
end


--[[--
获取当前组件的依赖组件
]]
function BehaviorBase:getDepends()
	if not self.depends_ then
    	self.depends_ = {};
    end
    return self.depends_
end


--[[--
设置当前组件优先级
]]
function BehaviorBase:setPriority( priority )
	-- body
    self.priority_     = checkint(priority) -- 行为集合初始化时的优先级，越大越先初始化
end


--[[--
获取当前组件的优先级
]]
function BehaviorBase:getPriority()
	if not self.priority_ then
    	self.priority_ = 0;
    end
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
