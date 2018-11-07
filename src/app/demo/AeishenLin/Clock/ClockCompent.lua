local ClockCompent = 
{  
    totalDt = 0,          --存储时间
    shakeDuration = 0.25, --摇晃换图时间间隔
    clockDuration = 1,    --计时间隔
    shakeFalg = false,    --用于切换
    shakeTime = 3;        --闹钟摇晃时间
    
    ---闹钟计时功能
    onEnter = function(self) 
        local owner = self:getOwner()
        local scheduler,clockTest = cc.Director:getInstance():getScheduler()
        local function clockUpdate(dt)
            if owner.timeText then  
                owner.timeText = owner.timeText - dt
                -- if owner.timeText <= 1 and owner.timeText > 0 then  
                --     local myEvent = cc.EventCustom:new("game over")
                --     math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
                --     myEvent.result = math.random(1,6)
                --     cc.Director:getInstance():getEventDispatcher():dispatchEvent(myEvent)                                           
                if owner.timeText <= 0 then 
                    owner:removeFromParent()                    --移除闹钟
                    scheduler:unscheduleScriptEntry(clockTest)  --置空计时处理脚本
                end
            end
        end
        clockTest = scheduler:scheduleScriptFunc(clockUpdate, self.clockDuration, false)
    end,
    

    -- ---闹钟摇晃变红效果
    -- update = function(self,dt)
    --     local owner = self:getOwner()
    --     if owner.timeText <= self.shakeTime and owner.timeText > 0 then                                             
    --         self.totalDt = self.totalDt + dt
    --         if self.totalDt >= self.shakeDuration then
    --             if not self.shakeFalg then
    --                 owner:setTexture("Images/AeishenLin/clock_anim_2.png") 
    --                 self.shakeFalg = true
    --             else
    --                 owner:setTexture("Images/AeishenLin/clock_anim_3.png") 
    --                 self.shakeFalg = false
    --             end
    --             self.totalDt = 0
    --         end
    --     end
    -- end,
   

    -- ---闹钟缩放效果
    -- update = function(self,dt)
    --     local owner = self:getOwner()
    --     if owner.timeText <= self.shakeTime and owner.timeText > 0 then                                             
    --         self.totalDt = self.totalDt + dt
    --         if self.totalDt > self.shakeDuration then
    --             if not self.shakeFalg then 
    --                 owner:setScale(2,2)
    --                 self.shakeFalg = true
    --             else 
    --                 owner:setScale(1,1)
    --                 self.shakeFalg = false
    --             end
    --             self.totalDt = 0
    --         end
    --     end
    -- end,
}

return ClockCompent