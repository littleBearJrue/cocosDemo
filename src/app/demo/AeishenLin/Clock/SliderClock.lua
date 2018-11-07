local ImagePath = "Images/AeishenLin/chip/btn/"

local SliderClock = class("SliderClock",function()
    return cc.Sprite:create(ImagePath.."placecard_countdownbg.png")
end);

function SliderClock:ctor()
    self.time = 60
    self.clockDuration = 1
    self:initTimeText()
    self:initView()
    self:updateTime()
end

function SliderClock:initView()
    self.tickBg = cc.Sprite:create(ImagePath.."placecard_countdown.png")
    local progress = cc.ProgressTimer:create(self.tickBg)
    progress:setPercentage(100)
    local toFill = cc.ProgressTo:create(self.time, 0)
    progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    progress:setReverseDirection(true) 
    progress:runAction(toFill)
    self:addChild(progress)
    progress:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
end
function SliderClock:initTimeText()
    self.clockTimeText = cc.Label:createWithSystemFont(self.time,"Arial",40)
    self:addChild(self.clockTimeText)
    
	self.clockTimeText:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self.clockTimeText:setColor(cc.c3b(255,210,0))
end
function SliderClock:updateTime()
    local scheduler,clockTest = cc.Director:getInstance():getScheduler()
    local function clockUpdate(dt)
        if self.time then  
            self.time = self.time - dt
            self.clockTimeText:setString(self.time)    
            if self.time <= 10 then
                self.tickBg:setTexture(ImagePath.."placecard_countdown_red.png"):setContentSize(104, 104)
            end                
            if self.time <= 0 then 
                local myEvent = cc.EventCustom:new("time out")
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(myEvent) 
                self:removeFromParent()                    --移除闹钟
                scheduler:unscheduleScriptEntry(clockTest)  --置空计时处理脚本
            end
        end
    end
    clockTest = scheduler:scheduleScriptFunc(clockUpdate, self.clockDuration, false)
end

return  SliderClock