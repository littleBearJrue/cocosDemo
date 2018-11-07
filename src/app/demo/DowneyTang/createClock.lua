local Createclock = {}
function Createclock:clock(tickTime, clockPos)
    local ret = cc.Layer:create()
    local clock = ccui.ImageView:create("DowneyTang/clock_bg_poker.png")
    clock:setPosition(clockPos)
    clock:addTo(ret)
    local timeText = ccui.Text:create(tickTime, "Arial", 18)
    timeText:setPosition(clockPos)
    timeText:addTo(ret)
    timeText:setTextColor(cc.c3b(255, 215, 0))
    local scheduler, myupdate
    local timer = tickTime
    local function update(dt)
        timer = timer - dt
        timeText:setString(timer)
        release_print("update: " .. timer)
        if not timeText then
             scheduler:unscheduleScriptEntry(myupdate)
        elseif timer <= 0 then
            scheduler:unscheduleScriptEntry(myupdate)
        end
    end
    scheduler = cc.Director:getInstance():getScheduler()
    myupdate = scheduler:scheduleScriptFunc(update, 1, false)
    return ret
end

-- function Clock:start(num)
--     self.txt.viv = true;
--     self.txt.text = num;

-- end

function Createclock:clearClock(ret)
    ret:getParent():removeChild(ret, true)
    -- ret:getParent():removeAllChildren(true)
    dump("789789")
end

function Createclock:main()
    local clockNode
    local scene = cc.Scene:create()
    self.scene  = scene

    --创建闹钟
    ret = self:clock(5, cc.p(300, 180))
    ret:addTo(scene)

    --移除闹钟
    local btn = ccui.Button:create(s_PlayNormal)
    btn:setPosition(200, 100)
    btn:addTo(scene)
    btn:addTouchEventListener(function(sender,eventType)
        self:clearClock(ret)
        release_print("clearClock")
    end) 
 
    scene:addChild(CreateBackMenuItem())
    return scene
end

return handler(Createclock, Createclock.main)