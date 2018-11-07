-- @Author: YiangYang
-- @Date:   2018-10-22 09:34:43
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-31 09:51:47

local scheduler = cc.Director:getInstance():getScheduler()
local imageRoot = "yiang/clock.plist"

local AlarmClock = class("AlarmClock",function ( )
	local layout = ccui.Layout:create()
	--相对布局排列
    layout:setLayoutType(ccui.LayoutType.RELATIVE)
	return layout
end)

--time 开始时间
--intervalTime 间隔时间
function AlarmClock:ctor(time,intervalTime)
	self.time = time or 9
	self.intervalTime = intervalTime or 1
	self:checkData(time,intervalTime)
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
function AlarmClock:checkData(time,intervalTime)

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
function AlarmClock:initView()
	--使用plist拼图，加载进缓存
	cc.SpriteFrameCache:getInstance():addSpriteFrames(imageRoot)

	local bg = ccui.ImageView:create()
	bg:loadTexture("clock_bg.png",ccui.TextureResType.plistType)
	self:addChild(bg)

	self:setContentSize(bg:getContentSize())

	-- self.timeSprite = ccui.ImageView:create() --用image 做时间显示，仅限个位数
	self.timeText = ccui.Text:create("0",s_arialPath,25) --用text做时间显示

	local centerParameter = ccui.RelativeLayoutParameter:create()
	centerParameter:setAlign(ccui.RelativeAlign.centerInParent)
	-- self.timeSprite:setLayoutParameter(centerParameter)
	self.timeText:setLayoutParameter(centerParameter)

	-- self:addChild(self.timeSprite)
	self:addChild(self.timeText)

end

--开始倒计时
function AlarmClock:start()
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
			end
		else
			-- self.timeSprite:loadTexture(self.time..".png",ccui.TextureResType.plistType)
			self.timeText:setString(tostring(self.time))
		end
	end 
	--设置倒计时图片，并开始调度计时
	-- self.timeSprite:loadTexture(self.time..".png",ccui.TextureResType.plistType)
	self.timeText:setString(tostring(self.time))
	self.callbackEntry = scheduler:scheduleScriptFunc(onTime,self.intervalTime,false)
end

--结束闹钟
function AlarmClock:stop()
	if self.callbackEntry then
		--注销相应调度器
		scheduler:unscheduleScriptEntry(self.callbackEntry)
		self.callbackEntry = nil
		--移除plist纹理
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(imageRoot)
	end

	self:removeAllChildren() --清除所有子节点
	self.time = 0
	self.intervalTime = 0
end

return AlarmClock