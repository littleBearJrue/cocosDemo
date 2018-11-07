-- @module: ScheduleTest
-- @author: JoeyChen
-- @Date:   2018-10-19 18:08:10
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-19 19:17:10

local timer = 5

local function createSchedule1()
    local label = cc.Label:createWithSystemFont("", "Arial", 20)
    	:move(display.cx, display.cy + 50)
    label:scheduleUpdateWithPriorityLua(function(dt)
        label:setString("每帧时间差" .. dt)
    end, 0)

    return label
end 

local function createSchedule2()
	local scheduler, schedulerTest

    local label = cc.Label:createWithSystemFont(timer, "Arial", 20)
    	:move(display.cx, display.cy - 50)

    local function updateTest(dt)
        timer = timer - dt
        label:setString(timer)
        if timer <= 0 then
            scheduler:unscheduleScriptEntry(schedulerTest)
            label:setString("倒计时结束")
        end
    end

    scheduler = cc.Director:getInstance():getScheduler()
    schedulerTest = scheduler:scheduleScriptFunc(updateTest, 1, false)

    return label
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createSchedule1())
    scene:addChild(createSchedule2())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main