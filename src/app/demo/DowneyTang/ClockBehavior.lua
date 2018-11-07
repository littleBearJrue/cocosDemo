local ClockBehavior = class("ClockBehavior",cc.load("boyaa").behavior.BehaviorBase);

local exportInterface = {
    -- "updateView",
    "clockCount",
    "clockShake",
}

local timer = nil
function ClockBehavior:clockCount(object, timeCount)
    local scheduler, myupdate
    object.setTime = timeCount
    local function update(dt)
        if timeCount > 0 then 
            timeCount = timeCount - dt
            object.setTime = timeCount
            timer = timeCount
        else
            scheduler:unscheduleScriptEntry(myupdate)
            -- ret:getParent():removeChild(ret, true)
            -- scene:removeChild(newClock, true)        --移除时钟节点
        end
    end
    scheduler = cc.Director:getInstance():getScheduler()
    myupdate = scheduler:scheduleScriptFunc(update, 1, false)
end

function ClockBehavior:clockShake(object, shakeTime)
	local scheduler1, myupdate1
    local shakeClock = true
    local function update1(dt)
        print("timer"..timer)
        if timer <= shakeTime then
            if timer <= 0 then 
                scheduler1:unscheduleScriptEntry(myupdate1)
            else
                if shakeClock then
                    object:loadTexture("DowneyTang/clock_anim_3.png")
                    shakeClock = nil
                elseif not shakeClock then
                    object:loadTexture("DowneyTang/clock_anim_2.png")
                    shakeClock = true
                end
            end
        end
    end
    scheduler1 = cc.Director:getInstance():getScheduler()
    myupdate1 = scheduler1:scheduleScriptFunc(update1, 1/3, false)
end


function ClockBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true,false);
        -- object:bindMethod(self, v, handler(self, self[v]));
    end 
end

function ClockBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end


return ClockBehavior;