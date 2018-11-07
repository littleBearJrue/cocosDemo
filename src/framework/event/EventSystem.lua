--[[--事件系统 主要功能派发事件，事件回调返回true 则中断派发
如果正在派发事件，则在派发过程中注册的事件不会被触发，因为有优先级排序问题，具体看on注册函数
@module EventSystem
@author YuchengMo

Date   2018-05-07 14:09:59
Last Modified by   YuchengMo
Last Modified time 2018-08-21 10:37:15
]]


-- require("LuaKit")

local id = 1;
local function checktable(t)
    if t and type(t)=="table" then
        return t;
    end
    return {};
end

---根据标记移除数据
local removeByMask = function(list)
    local x, len = 0, #list
    for i = 1, len do
        local willRemove, idx = false, i-x
        local cb = list[idx];
        if cb and cb.state  ==  "maskRemove" then
            willRemove = true;
        end
        if (cb and willRemove == true) then
            table.remove(list, idx)
            x = x + 1
        end
    end
end


local EventSystem = {};

function EventSystem:ctor()
    self.m_listeners = {};
end

function EventSystem:dtor()
    self.m_listeners = nil;
end

--[[--
注册一个回调函数,如果正在派发事件，则在派发过程中注册的事件不会被触发，因为有优先级排序问题

@string event 事件名称
@param func 回调函数
@param params 扩展参数
@string  params.target 目标,回调函数第一个参数
@string  params.priority 优先级
@usage
local g_EventSystem = new(EventSystem)
g_EventSystem:on("test",function(...)
end,{target = self,priority = 10})
]]
function EventSystem:on(event,func,params)
    local listeners = self.m_listeners;
    local event = tostring(event)
    if listeners[event] == nil then
        listeners[event] = {dispatching = false, list = {}};
    end
    local eventObjs = listeners[event];
    local list = eventObjs.list;

    params = checktable(params);
    local priority = params.priority or 0;
    local target   = params.target;
    local cb = {target = target, func = func, priority = priority, id = id};
    id = id + 1;
    table.insert(list,cb);
    if priority > 0 then
        eventObjs.needSort = true; -- 标记需要排序
        self:sort(eventObjs); ---如果正在派发 注册的时候排序会有问题 比如当前有四个回调 1 2 3 4 当前运行到第3个 这时候往第一个插入，然后排序，会导致再调用一次滴三个回调
    end
end


--[[--
反注册事件，正在派发过程中要移除的事件会被标记，在派发结束之后再移除

@string event 事件名称
@param func 回调函数
@param params 扩展参数
@string  params.target 目标,回调函数第一个参数
@string  params.priority 优先级
@usage
local g_EventSystem = new(EventSystem)
g_EventSystem:off("test",function(...)
end,{target = self,priority = 10})
]]
function EventSystem:off(event,func,params)
    local listeners = self.m_listeners;
    local event = tostring(event)
    if listeners[event] == nil then
        return;
    end
    local eventObjs = listeners[event];
    local list = eventObjs.list;
    local dispatching = eventObjs.dispatching;

    params = checktable(params);
    local priority = params.priority or 0;
    local target = params.target;

    for i,v in ipairs(list) do
        if v.func == func and v.target == target then
            v.state = "maskRemove"; --
            if dispatching == true then
                eventObjs.needClean = true; --标记需要在派发结束时候进行清理
            else
                table.remove(list,i);
            end
            break;
        end
    end
end

--[[--
派发一个事件，只执行当前注册的回调函数，在派发过程中注册的不触发回调

@string event 事件名称
@param ... 不定参数

@usage
local g_EventSystem = new(EventSystem)
g_EventSystem:emit("test",{a = 1})
]]
function EventSystem:emit(event, ...)
    local listeners = self.m_listeners;
    local event = tostring(event)
    local eventObjs = listeners[event];
    if eventObjs == nil then
        return;
    end
    local list = eventObjs.list;
    -- self.m_dispatching = true; --不能写在这 如果回调内部再次emit 则会导致dispatching为false
    local INTR; --是否中断 不再派发事件

    local len = #list; ---这里只取当前已经注册的事件数量，如果在派发过程中再注册 则当次不会调用
    for i=1,len do
        if INTR == true then
            break;
        end
        local cb = list[i];
        if cb.func and cb.state ~= "maskRemove" then
            eventObjs.dispatching = true; -- 必须在这里赋值
            INTR = cb.func(cb.target,...);
            eventObjs.dispatching = false; -- 必须在这里赋值
        end
    end

    self:sort(eventObjs);
    self:clean(eventObjs);

    return INTR;

end

---排序 如果正在派发则不排序 派发完之后再排序 否则影响执行顺序
function EventSystem:sort(eventObjs)
    local list = eventObjs.list;
    if eventObjs.needSort == true and eventObjs.dispatching == false then
        table.sort(list,function(a,b)
            if a.priority == b.priority then
                return a.id < b.id;
            else
                return a.priority > b.priority;
            end
        end)
        eventObjs.needSort = false; -- 已经【排序过了
    end
end

---清理标记要移除的对象
function EventSystem:clean(eventObjs)
    if eventObjs.needClean == true then
        eventObjs.needClean = false;
        removeByMask(eventObjs.list)
    end
end

---移除所有对象对应的event事件
function EventSystem:off_all_event_by_target(target)
    local listeners = self.m_listeners;
    for k,eventObjs in pairs(listeners) do
        local list = eventObjs.list;
        for i,v in ipairs(list) do
            if v.target == target  then
                v.state = "maskRemove";
            end
        end
        ---如果正在派发 则标记移除
        if eventObjs.dispatching == true then
            eventObjs.needClean = true;
        else
            removeByMask(list);
        end
        
    end

end


--[[--
修改优先级

@string event 事件名称
@param func 回调函数
@param params 扩展参数
@string  params.target 目标,回调函数第一个参数
@string  params.priority 优先级
@usage
local g_EventSystem = new(EventSystem)
g_EventSystem:update_priority("test",,func,{priority = 1})
]]
function EventSystem:update_priority(event,func, params)
    local listeners = self.m_listeners;
    local event = tostring(event)
    if listeners[event] == nil then
        return;
    end
    local eventObjs = listeners[event];
    local list = eventObjs.list;

    params = checktable(params);
    local priority = params.priority or 0;
    local target   = params.target;

    for i,v in ipairs(list) do
        if v.func == func and v.target == target then
            v.priority = priority;
        end
    end
    eventObjs.needSort = true; -- 标记需要排序
    self:sort(eventObjs); ---如果正在派发 注册的时候排序会有问题 比如当前有四个回调 1 2 3 4 当前运行到第3个 这时候往第一个插入，然后排序，会导致再调用一次滴三个回调

end

return EventSystem;