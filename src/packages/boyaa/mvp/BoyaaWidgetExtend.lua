--[[--ldoc desc
@module BoyaaWidgetExtend
@author ShuaiYang

Date   2018-10-30 10:03:58
Last Modified by   ShuaiYang
Last Modified time 2018-11-02 17:25:10
]]
local BoyaaWidgetExtend

---自定义mvp view扩展，让自定义view支持mpv
BoyaaWidgetExtend = function(ClassExtend)
	
	--[[--
	扩展自定义属性，添加get、set方法
	@param getFun 获取
	@param getFun 设置
	@usage
	]]
	function ClassExtend.mkproprety(getFun,setFun)
		-- body
		local instance = {proprety = true}
		instance.get = getFun
		instance.set = setFun
		setmetatable(instance, {__newIndex = function()
			-- error(1)
		end})
		return instance
	end

	--[[--
	扩展自定义属性，初始化
	@param class 初始化类对象
	@usage
	]]
	function ClassExtend:initMkproprety(class)
		-- body
		local peer = tolua.getpeer(self)
		local mt = getmetatable(peer)
		local __index = mt.__index
		mt.__index = function(_, k)
			if type(class[k]) == "table" and class[k].proprety == true then
				return class[k].get(self)
			elseif __index then
				if type(__index) == "table" then
					return __index[k]
				elseif type(__index) == "function" then
					return __index(_, k)
				end
			end
		end
		mt.__newindex = function(_, k, v)
			if type(class[k]) == "table" and class[k].proprety == true then
				return class[k].set(self, v)
			else
				rawset(_, k, v)
			end
		end
	end


	--[[--
	刷新界面
	@usage
	]]
	function ClassExtend:updateView(data)

	end


	--[[--
	获取一个调度器对象
	@usage
	]]
	function ClassExtend:getScheduler()
	    -- body
	    return cc.Director:getInstance():getScheduler();
	end


	--[[--
	获取一个调度器对象
	@usage
	]]
	function ClassExtend:getSchedulerList()
	    -- body
	    if not self.schedulerList then
	    	self.schedulerList = {}
	    end
    	return self.schedulerList;

	end


	--[[--
	启动定时器
	@usage
	]]
	function ClassExtend:scheduler(fn,interval,paused)
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
	function ClassExtend:unScheduler(shid)
	    -- body
	    print("====unSchedulerTest======")
	    local schedulerList =  self:getSchedulerList();
	    if table.keyof(schedulerList,shid) then
	        self:getScheduler():unscheduleScriptEntry(shid);
	        table.remove(schedulerList,tostring(shid))
	    end
	end


	--[[--
	清除调度器
	@usage
	]]
	function ClassExtend:cancelAllSchedule()
	    if self.schedulerList then
	        for i,v in ipairs( self.schedulerList) do
	            if v then
	                self.scheduler:unscheduleScriptEntry(v);
	            end
	        end
	    end
	     self.schedulerList = nil;
	end


	function ClassExtend:dtor()
	    self:cancelAllSchedule()
	    self:unbindCtr();
	end

	--[[--
	系统清除数据
	@usage
	]]
	function ClassExtend:cleanup()
	    print("view cleanup");
	    self:dtor();
	end

end;


return BoyaaWidgetExtend;