-- @Author: YiangYang
-- @Date:   2018-10-31 09:54:43
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-11-02 15:24:31
local scheduler = cc.Director:getInstance():getScheduler()

local ClockView = class("ClockView",cc.load("boyaa").mvc.BoyaaLayout)

--time 开始时间
function ClockView:ctor(time,data)
    self.data = data
    self:setAnchorPoint(0.5,0.5)
    self:checkData(time)
    local function onNodeEvent(event) --监听进入及退出事件
        if event == "exit" then
            self:stop()
        elseif event == "enter" then
            self:initView()
            self:start()
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

--校验数据
function ClockView:checkData(time)
    if time and type(time) == "number" then
        self.time = time
    else
        self.time = 9
    end
end


--初始化界面布局
function ClockView:initView()
    local bg = ccui.ImageView:create()
    bg:loadTexture("creator/Texture/SilvaZhang/SwapRes/placecard_countdownbg.png")
    self:addChild(bg)
    self:setContentSize(bg:getContentSize())
    self.timeText = ccui.Text:create("0",s_arialPath,50) --用text做时间显示
    local centerParameter = ccui.RelativeLayoutParameter:create()
    centerParameter:setAlign(ccui.RelativeAlign.centerInParent)
    self.timeText:setLayoutParameter(centerParameter)
    self.timeText:setString(tostring(self.time))
    self:addChild(self.timeText)
    local quan = cc.Sprite:create("creator/Texture/SilvaZhang/SwapRes/placecard_countdown.png")
    self.progress = cc.ProgressTimer:create(quan):addTo(self)
    self.progress:setReverseDirection(true)
    self.progress:setPercentage(100)
end

--设置回调函数
--cb1 倒计时结束回调
--cb2 进入最后时间计时回调
function ClockView:setCallback(cb1,cb2)
    self.cb1 = cb1
    self.cb2 = cb2
end


--开始倒计时
function ClockView:start()
    local percent = 100
    local lastTime = 0
    local s = 0
    local fen = percent/self.time -- 100% 分成多少分时间
    --每帧刷新圆圈
    self:scheduleUpdateWithPriorityLua(function (dt)
        percent = percent - (fen*dt)
        lastTime =  percent * self.time *0.01
        self.progress:setPercentage(percent)
        for i,v in ipairs(self.data) do
            if v.procent and percent <= v.procent and not v.flag then
                v.func()
                v.flag = true
            end
            if v.time and lastTime <= v.time and not v.flag then
                if v.style then
                    self.progress:setSprite(cc.Sprite:create("creator/Texture/SilvaZhang/SwapRes/placecard_countdown_red.png"))
                    self.progress:setReverseDirection(true)
                end
                v.func()
                v.flag = true
            end
        end
        local floorLastTime = math.floor(lastTime)
        if floorLastTime ~= s then
            s = floorLastTime
            self.timeText:setString(tostring(floorLastTime))
        end
    end,0)
end

--结束闹钟
function ClockView:stop()
    if self.callbackEntry then
        --注销相应调度器
        scheduler:unscheduleScriptEntry(self.callbackEntry)
        self.callbackEntry = nil
        --移除plist纹理
        self:removeAllChildren() --清除所有子节点
    end
    self.time = 0
end

return ClockView