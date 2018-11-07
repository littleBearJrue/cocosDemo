local scheduler = cc.Director:getInstance():getScheduler();
local numberLib = g_numberLib;
local Schedule = class("Schedule")


function Schedule:ctor()

end

function Schedule:dtor()

end

--[[
	调度 fn 每隔 delay``(秒)执行一次，共执行 ``count 次。
	delay 默认为不传入， 表示下一次循环立即开始执行。
	count 默认为 -1， 表示执行无数次。
	返回值是 Event 对象。
]]
function Schedule:schedule(fn,delay,count)
	local eventObj;
	delay = numberLib.valueOf(delay);
	count = numberLib.valueOf(count);
	local runCount = 0;
	local runTime = 0;
	local sleep_time = 0;

	local extend = {
		eventObj = nil,
		isPause = false,
		sleepTime = 0,
		pause = function(self)
			print("定时器暂停了",os.time());
			self.isPause = true;
		end,
		resume = function(self)
			print("定时器恢复了",os.time());
			self.isPause = false;
		end,
		sleep = function(self,delay)
			print("定时器休眠",delay)
			self.sleepTime = delay;
			sleep_time = 0;
		end,
		cancel = function(self)
			print("定时器停止",os.time())
			if self.eventObj then
				scheduler:unscheduleScriptEntry(self.eventObj);
				self.eventObj = nil;
			end
		end
	};
	
 	extend.eventObj = scheduler:scheduleScriptFunc(function (dt)
 		if extend.isPause then
 			return;
 		end
 		if extend.sleepTime > 0 then
 			sleep_time = sleep_time + dt;
 			if sleep_time < extend.sleepTime then
 				-- 休眠中
 				return;
	 		else
	 			-- 休眠时间到
	 			extend.sleepTime = 0;
	 			sleep_time = 0;
	 		end
 		end
 		runTime = runTime + dt;
 		if runTime < delay then
 			return;
 		end
 		runTime = 0;
		fn();
 		runCount = runCount + 1;
 		if count == 0 then
 			-- 只执行一次，立即停止
 			extend:cancel();
		elseif runCount >= count then
			-- 执行count次，停止
			extend:cancel();
		end
	end,1/60,false)
 	return extend;
end

-- 停止计时器
function Schedule:cancel(eventObj)
	if eventObj then
		scheduler:unscheduleScriptEntry(eventObj);
		eventObj = nil;
	end
end

--[[
-- 扩展定时器，只执行一次。默认下一帧执行回调
	调度 fn 延时 delay (秒)执行一次。
	delay 默认为不传入， 表示下一次循环立即开始执行。
	返回值是 Event 对象。
]]
function Schedule:schedulerOnce(fn,delay)
	delay = numberLib.valueOf(delay);
	local onceScheduler;
 	onceScheduler = scheduler:scheduleScriptFunc(function (dt)
			fn();
			if onceScheduler then
				scheduler:unscheduleScriptEntry(onceScheduler);
				onceScheduler = nil;
			end
		end,delay,false)
 	return onceScheduler;
end

return Schedule;