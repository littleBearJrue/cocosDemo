--[[--ldoc desc
@module BoyaaWidgetExtend
@author ShuaiYang

Date   2018-10-30 10:03:58
Last Modified by   ShuaiYang
Last Modified time 2018-11-01 14:48:04
]]
local BoyaaWidgetExtend

---组件扩展接口，可以让一个表支持组件机制
BoyaaWidgetExtend = function(ClassExtend)

	-- local ordGm = getmetatable(ClassExtend);
	-- ordGm.__index();
	-- local newGm = {};
	-- newGm.__index = function (mytable, key)
	-- 	-- body
		
	-- end

	---获取控制器对象
	function ClassExtend:getCtr()
		 return self.ctr;
	end

	--[[--
	绑定对应的控制器
	@param class 控制器的class对象
	@usage
	]]
	function ClassExtend:bindCtrClass(class)
		if class then
			self.ctr = class.new();
	        self.ctr:setView(self);
		end
	end
	--[[--
	绑定对应的控制器
	@param ctr 控制器的对象
	@usage
	]]
	function ClassExtend:bindCtr(ctr)
		if class then
	        self.ctr = ctr
	        self.ctr:setView(self);
    	end
	end

	--[[--
	解绑定对应的控制器
	@usage
	]]
	function ClassExtend:unbindCtr()
		-- body
		if self.ctr then
			self.ctr = nil;
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