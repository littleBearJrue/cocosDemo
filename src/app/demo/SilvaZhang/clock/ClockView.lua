local ClockView = class("CardView",cc.Layer)

function ClockView:ctor( time )
	self.time = time or 10
	local clock = cc.Sprite:create("Images/clock/clock_default.png")
	self:addChild(clock)
	local clockLabel = cc.Label:createWithTTF(self.time.."", s_arialPath, 40)
	self:addChild(clockLabel)
	self:setScheduler(clockLabel)
end

function ClockView:exit(  )
	local scheduler = cc.Director:getInstance():getScheduler()
	scheduler:unscheduleScriptEntry(self.clockScheduleId)
end

function ClockView:setScheduler( clockLabel )
	local function update( dt )
		if self.time > 0 then
			self.time = self.time - 1
			clockLabel:setString(self.time.."")
		end
	end
	local scheduler = cc.Director:getInstance():getScheduler()
	self.clockScheduleId = scheduler:scheduleScriptFunc(update, 1, false)
end

return ClockView