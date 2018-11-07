local ClockWidget = class("ClockWidget",cc.load("boyaa").mvc.BoyaaView);

function ClockWidget:ctor()
	--灰色背景
	local grayBg = cc.Sprite:create("DowneyTang/CapsaSusun/grayBg.png")
	grayBg:addTo(self)
	--进度条
	local tickBg = cc.Sprite:create("DowneyTang/CapsaSusun/clockBg.png")
	local progressTest = cc.ProgressTimer:create(tickBg)
	progressTest:setPercentage(100)
	local toZero = cc.ProgressTo:create(60, 0)
	progressTest:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	progressTest:setReverseDirection(true) 
	progressTest:runAction(toZero)
	progressTest:addTo(self)
	--倒计时
	local tips = cc.Label:createWithSystemFont("点击或者拖动都可以交换牌哦", "Arial", 35)
	tips:setPosition(10,-80)
	tips:addTo(self)
	local tickLabel = cc.Label:createWithSystemFont("60", "Arial", 35)
	tickLabel:addTo(self)
	local scheduler, myupdate
	local timeCount = 60
    local function update(dt)
        if timeCount > 0 then
            timeCount = timeCount - dt
			tickLabel:setString(timeCount)
			if timeCount == 50 then
				tips:setString("快点啊，我等的花儿都谢了！")
			end
        else
			scheduler:unscheduleScriptEntry(myupdate)
			self.listener()
            -- ret:getParent():removeChild(ret, true)
            -- scene:removeChild(newClock, true)        --移除时钟节点
        end
    end
    scheduler = cc.Director:getInstance():getScheduler()
	myupdate = scheduler:scheduleScriptFunc(update, 1, false)
end


function  ClockWidget:setListener(fun)
	self.listener = fun;
end

return ClockWidget;