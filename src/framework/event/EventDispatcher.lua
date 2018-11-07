--[[--消息分发
@module EventDispatcher
@author YuchengMo

Date   2018-05-07 14:09:59
Last Modified by   YuchengMo
Last Modified time 2018-08-20 19:53:51
]]


local function checktable(t)
    if t and type(t)=="table" then
        return t;
    end
    return {};
end

local EventSystem = require(".EventSystem")
local EventDispatcher = class("EventDispatcher",EventSystem);
local maxPriority = 0xffffffff


---注销该对象所对应的所有事件
--@param obj 绑定事件对象
function EventDispatcher:unRegisterAllEventByTarget(obj)
	if not obj then return end
	self:off_all_event_by_target(obj)
end

--[[--
注册事件
@string event 事件名
@param obj 对象
@param func 对象上的方法
@param param 复合参数 可以设置优先级 如{priority = 1100}
@usage
local obj = {};
function onj:test()
end
g_EventDispatcher:register("test",obj,obj.test);
]]
function EventDispatcher:register(event, obj, func, params)
	params = checktable(params);
	params.target = obj;
	self:on(event,func,params);
end

---修改优先级 param = {priority = 1, ...}
function EventDispatcher:updatePriority(event, obj, func, params)
	params = checktable(params);
	params.target = obj;
	self:update_priority(event, func, params)
end

--将obj下的所有event都设置为最高优先级
function EventDispatcher:updatePriorityToTopByTarget(obj)
	if not obj then return end

	for event,eventObjs in pairs(self.m_listeners) do
		local list = eventObjs.list;
        for i,v in ipairs(list) do
            if v.target == obj and v._priority  == nil  then
                v._priority = v.priority;
                v.priority = maxPriority;
            elseif v.target ~= obj and v._priority then
            	v.priority = v._priority;
            	v._priority = nil; 
            end
        end
        eventObjs.needSort = true; -- 标记需要排序
        self:sort(eventObjs);
	end
end

function EventDispatcher:updatePriorityToDefaultByTarget(obj)
	if not obj then return end

	for event,eventObjs in pairs(self.m_listeners) do
		local list = eventObjs.list;
        for i,v in ipairs(list) do
            if v.target == obj and v._priority then
            	v.priority = v._priority;
            	v._priority = nil;
            	eventObjs.needSort = true; -- 标记需要排序
            end
        end
        self:sort(eventObjs);
	end
end

--[[--
清除注册事件,必须当obj和func都和注册事件时的相同时，才会取消注册

@string event 事件ID。
@param obj 注册事件时传入的obj。
@param #function func 注册事件时传入的回调函数
@usage
local obj = {};
function onj:test()
end
EventDispatcher:register("test",obj,obj.test);
EventDispatcher:unregister("test",obj,obj.test);
]]
function EventDispatcher:unregister(event, obj, func)
	params = checktable(params);
	params.target = obj;
	self:off(event,func,params);
end


--[[--
派发消息事件

@string event 事件ID。
@param ... 其他需要携带的参数，这些参数会传给EventDispatcher.register所注册的事件的回调函数
@return boolean 返回值 true or false 是否中断派发
@usage
EventDispatcher:dispatch("test",{test = "cs"});
]]

function EventDispatcher:dispatch(event, ...)
	return self:emit(event, ...);
end


return EventDispatcher;