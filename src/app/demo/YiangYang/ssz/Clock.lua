-- @Author: YiangYang
-- @Date:   2018-10-31 09:54:43
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-11-02 15:24:31
local scheduler = cc.Director:getInstance():getScheduler()
local PlistRoot = "yiang/clock/clocknew.plist"
local imageRoot = "yiang/clock/play_countdown/"

local Clock = class("ExchangeCardView",cc.load("boyaa").mvc.BoyaaLayout)

--time 开始时间
--intervalTime 间隔时间
function Clock:ctor(time,intervalTime)
	self.time = time or 9
	self.intervalTime = intervalTime or 1
	self:checkData(self.time,self.intervalTime)
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
function Clock:checkData(time,intervalTime)

	if time and type(time) == "number" and time > 0 then
		if time%1 ~= 0 then
			error("倒计时时间参数有误，不能有小数点")
		else
			self.time = time
		end
	else
		error("倒计时时间参数有误")
		self.time = 9
	end

	if intervalTime and type(time) == "number" and intervalTime <= time and intervalTime > 0 then
		if intervalTime%1 ~= 0 then
			error("倒计时间隔时间参数有误")
		else
			self.intervalTime = intervalTime
		end
	else
		error("倒计时间隔时间参数有误")
		self.intervalTime = 1
	end

end


--初始化界面布局
function Clock:initView()
	--使用plist拼图，加载进缓存
	cc.SpriteFrameCache:getInstance():addSpriteFrames(PlistRoot)

	local bg = ccui.ImageView:create()
	bg:loadTexture("placecard_countdownbg.png",ccui.TextureResType.plistType)
	self:addChild(bg)

	self:setContentSize(bg:getContentSize())

	self.timeText = ccui.Text:create("0",s_arialPath,50) --用text做时间显示

	local centerParameter = ccui.RelativeLayoutParameter:create()
	centerParameter:setAlign(ccui.RelativeAlign.centerInParent)
	self.timeText:setLayoutParameter(centerParameter)
	self:addChild(self.timeText)

	local quan = cc.Sprite:create(imageRoot.."placecard_countdown.png")

    self.progress = cc.ProgressTimer:create(quan):addTo(self)
    
    self.progress:setReverseDirection(true)

    self.timeText:setString(tostring(self.time))
    self.progress:setPercentage(100)
end

--最后几秒的状态
function Clock:onLastTimeState()
	-- body
end

--设置回调函数
--cb1 倒计时结束回调
--cb2 进入最后时间计时回调
function Clock:setCallback(cb1,cb2)
	self.cb1 = cb1
	self.cb2 = cb2
end


--开始倒计时
function Clock:start()

	local canChange = true
	local percent = 100
	local fen = percent/self.time -- 100% 分成多少分时间
	--每帧刷新圆圈
	self:scheduleUpdateWithPriorityLua(function (dt)
		percent = percent - (fen*dt)
		if percent < 0 then
			return
		end
		self.progress:setPercentage(percent)
		if canChange and  percent <= 50 then
            self.progress:setSprite(cc.Sprite:create(imageRoot.."placecard_countdown_red.png"))
            self.progress:setReverseDirection(true)
            canChange = false
            if self.cb2 then
            	self.cb2()
            end
        end
	end,0)
	
	--调度器回调
	local function onTime( dt )
		self.time = self.time - self.intervalTime
		if self.time <= 0 then
			if self.callbackEntry then
				scheduler:unscheduleScriptEntry(self.callbackEntry)
				self.callbackEntry = nil
				self:removeAllChildren() --清除所有子节点
				self.time = 0
				self.intervalTime = 0
				if self.cb1 then
	            	self.cb1()
	            end
			end
		else
			self.timeText:setString(tostring(self.time))
		end
	end 
	
	self.callbackEntry = scheduler:scheduleScriptFunc(onTime,self.intervalTime,false)

end

--结束闹钟
function Clock:stop()
	if self.callbackEntry then
		--注销相应调度器
		scheduler:unscheduleScriptEntry(self.callbackEntry)
		self.callbackEntry = nil
		--移除plist纹理
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(imageRoot)
		self:removeAllChildren() --清除所有子节点
	end
	self.time = 0
	self.intervalTime = 0
end

return Clock