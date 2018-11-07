local Clock = class("Clock", function()
	clockBg = ccui.ImageView:create("DowneyTang/clock_bg_poker.png")
	return clockBg
end)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
BehaviorExtend(Clock);

--倒计时
function Clock:clockCount(timeCount)
	
end

--闹钟摇晃
function Clock:clockShake(shakeTime)
	
end

--初始化，创建时钟的时间文本
function Clock:init()
    self.timeText = ccui.Text:create("", "Arial", 18)
    self.timeText:setTextColor(cc.c3b(255, 215, 0))
	self.timeText:addTo(self)
	self.timeText:setPosition( cc.p(VisibleRect:center().x-206, VisibleRect:bottom().y +35) );
end

local mkproprety = function(getFun, setFun)
	local instance = {proprety = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
		error(1)
	end})
	return instance
end

--设置时间
Clock.setTime = mkproprety(function(self)
	return self._data.tickTime
end,function(self, setTime)
	self._data.tickTime = setTime
	self:update({tickTime = setTime})
end)

function Clock:update(data)
	if data.tickTime then
		print("updateTickTime", data.tickTime)
    	self.timeText:setString(data.tickTime)
	end
end


-- --设置背景
-- Clock.setBg = mkproprety(function(self)
-- 	return self._data.tickBg
-- end,function(self, setBg)
-- 	self._data.tickBg = setBg
-- 	self:update1({tickBg = setBg})
-- end)

-- function Clock:update1(data)
-- 	if data.tickBg then
-- 		Clock.updateTickBg(self, data.tickBg)
-- 	end
-- end

-- Clock.updateTickBg = function(clock, tickBg)
-- 	local self = clock
--     print("updateTickBg", tickBg)
--     self.clockBg:loadTexture(tickBg)
-- end


function Clock:ctor()
    self:init()
    local peer = tolua.getpeer(self)
	local mt = getmetatable(peer)
	local __index = mt.__index
	mt.__index = function(_, k)
		if type(Clock[k]) == "table" and Clock[k].proprety == true then
			return Clock[k].get(self)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(Clock[k]) == "table" and Clock[k].proprety == true then
			return Clock[k].set(self, v)
		else
			rawset(_, k, v)
		end
    end
    self._data = {
        tickTime = 15,
        -- tickBg = "DowneyTang/clock_bg_poker.png",
	}
end

return Clock;