--[[--ldoc desc
@Module ClockAnimComponent.lua
@Author JasonLiu

Date: 2018-10-19 17:54:07
Last Modified by: JasonLiu
Last Modified time: 2018-10-19 18:33:19
]]

local ClockAnimComponent = {

    countdown = function(self, callback, count, isPlayAnim)
        local function clockAnim()
            local animation = cc.Animation:create()
            animation:addSpriteFrameWithFile("Images/clock/clock_anim_2_1.png")
            animation:addSpriteFrameWithFile("Images/clock/clock_anim_1_2.png")
            -- should last 2.8 seconds. And there are 14 frames.
            animation:setDelayPerUnit(2 * 0.1 / 2)
            animation:setRestoreOriginalFrame(true)
            local action = cc.Animate:create(animation)

            return cc.RepeatForever:create(cc.Sequence:create(action, action:reverse()))
        end

        print("ClockAnimComponent countdown")
        local c = count or self._data.count
        self:stopActions()
        self.time:setString(c)
        schedule(self.time, function()  
            c = c - 1
            self.time:setString(c)
            if c == 0 then
                self:stopActions()
                callback()
            elseif c == 5 and isPlayAnim then
                self.bg:runAction(clockAnim())
            end
        end, 1) 
    end,
    
    onEnter = function(self)
        print("ClockAnimComponent onEnter")
        local owner = self:getOwner()
        owner.countdown = self.countdown
    end,
}

return ClockAnimComponent
