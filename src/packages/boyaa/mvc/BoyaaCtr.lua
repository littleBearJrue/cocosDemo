--[[--ldoc desc
@module BoyaaCtr
@author ShuaiYang

Date   2018-10-18 14:49:56
Last Modified by   ShuaiYang
Last Modified time 2018-11-01 14:46:55
]]
local BoyaaCtr = class("BoyaaCtr");
-- BoyaaCtr[".isclass"] = true;

function BoyaaCtr:ctor()
    print("BoyaaCtr   ctor");
end

--[[--
设置控制器绑定的view
@param view 绑定的view对象
@usage
]]
function BoyaaCtr:setView(view)
    -- body
    self.view = view;
end

function BoyaaCtr:getSchedulerList()
    -- body
    if not self.schedulerList then
        self.schedulerList = {}
    end
    return self.schedulerList;
end

function BoyaaCtr:getEvenNames()
    -- body
    if not self.evenNames then
        self.evenNames = {}
    end
    return self.evenNames;
end


--[[--
初始化view接口，控制器需要控制的view初始化的地方
@usage
]]
function BoyaaCtr:initView()
    -- body
end

--[[--
获取一个调度器对象
@usage
]]
function BoyaaCtr:getScheduler()
    -- body
    return cc.Director:getInstance():getScheduler();
end

--[[--
获取当前控制器控制的view
@usage
]]
function BoyaaCtr:getView()
    -- body
    return self.view;
end

--[[--
绑定自定义事件
@param evenName 自定义事件名称
@param listener 回调方法
@usage
]]
function BoyaaCtr:bindEventListener(evenName,listener)
    -- body
    local evenNames = self:getEvenNames();
    if evenName and not table.keyof(evenNames,evenName) then

        local listener1 = cc.EventListenerCustom:create(evenName,listener)
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
        eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)

        table.insert(evenNames,evenName);
    end

end

--[[--
绑定自定义事件到当前对象
@param evenName 自定义事件名称
@param fnNmae 方法名
@usage
]]
function BoyaaCtr:bindSelfFun(evenName,fnNmae)
    -- body
    local fn = self[fnNmae];
    local evenNames = self:getEvenNames();
    
    if evenName and fn and type(fn) == "function" and  not table.keyof(evenNames,evenName) then

        local listener1 = cc.EventListenerCustom:create(evenName,handler(self,fn))
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
        eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)

        table.insert(evenNames,evenName);
    end
    
end


--[[--
发送自定义事件消息数据
@param evenName 自定义事件名称
@param data 数据
@usage
]]
function BoyaaCtr:sendEvenData(evenName,data)
    -- body
    local event = cc.EventCustom:new(evenName)
    event._usedata = data
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:dispatchEvent(event)
end

--[[--
使用调度器
@param fn 回调方法
@param interval 间隔时间
@param paused 是否暂停
@usage
]]
function BoyaaCtr:scheduler(fn,interval,paused)
    -- body
    local shid = self:getScheduler():scheduleScriptFunc(fn,interval,paused);
    local schedulerList =  self:getSchedulerList();
    schedulerList[tostring(shid)] = shid;

    return shid;
end

--[[--
释放某个调度器，这调度器必须当前类创建的
@param shid 调度器
@usage
]]
function BoyaaCtr:unScheduler(shid)
    -- body
    print("====unSchedulerTest======")
    local schedulerList =  self:getSchedulerList();
    if table.keyof(schedulerList,shid) then
        self:getScheduler():unscheduleScriptEntry(shid);
        table.remove(schedulerList,tostring(shid))
    end
end


--[[--
取消调度器
@usage
]]
function BoyaaCtr:cancelAllSchedule()
    local schedulerList =  self:getSchedulerList();
    if schedulerList then
        for i,v in ipairs(schedulerList) do
            if v then
                self:getScheduler():unscheduleScriptEntry(v);
            end
        end
    end
    self.schedulerList = nil;
end

--[[--
取消事件监听
@usage
]]
function BoyaaCtr:removeAllCustomEventListeners()
    -- body
    local evenNames = self:getEvenNames();
    if evenNames then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
        for i,evenName in ipairs(evenNames) do
            eventDispatcher:removeCustomEventListeners(evenName);
        end
    end
    self.evenNames = nil;
end

function BoyaaCtr:dtor()
    self:cancelAllSchedule()
    self:removeAllCustomEventListeners();
end


return BoyaaCtr;