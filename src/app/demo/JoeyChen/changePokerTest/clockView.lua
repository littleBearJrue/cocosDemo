local clockView = class("clockView",cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

BehaviorExtend(clockView);

function clockView:ctor(timer, callBackTimer, callBackFun)
	self.clockScheduler = nil
	self.timeCount = timer
	self:init(timer, callBackTimer, callBackFun)
end

function clockView:dtor()
    self:cancelAllSchedule()
    self:unbindCtr();

	self:cleanAll()
end

function clockView:init(timer, callBackTimer, callBackFun)
	local bg = cc.Sprite:create("creator/Texture/JoeyChen/placecard_countdownbg.png")
		:move(display.cx,display.cy + 280)
		:setAnchorPoint(0.5,0.5)
		:addTo(self)

	-- 创建并初始化进度,第一个参数是duration持续时间，100为进度  
	local to = cc.ProgressTo:create(timer, 0) 

	local size = bg:getContentSize()
	local img = cc.Sprite:create("creator/Texture/JoeyChen/placecard_countdown.png")
	self.clock = cc.ProgressTimer:create(img)
		:move(size.width/2,size.height/2)
		:setAnchorPoint(0.5,0.5)
		:addTo(bg)
	self.clock:setReverseProgress(true)
	self.clock:setPercentage(100)
	-- 设置进度计时的类型，这里是绕圆心  
	self.clock:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)   
	-- 运行动作  
	self.clock:runAction(cc.RepeatForever:create(to))

	self.clockText = cc.Label:createWithSystemFont(timer, "Arial", 50)
		:move(size.width/2,size.height/2)
		:setAnchorPoint(0.5,0.5)
		:addTo(bg)
	self:createScheduler(timer, callBackTimer, callBackFun)
end

function clockView:createScheduler(timer, callBackTimer, callBackFun)
    local function update(dt)
        if self.timeCount > 0 then
        	self.timeCount = self.timeCount - dt
        	self.clockText:setString(self.timeCount)
        	if self.timeCount == callBackTimer then
        		self.clock:setSprite(cc.Sprite:create("creator/Texture/JoeyChen/placecard_countdown_red.png"))
        		callBackFun()
        	end
        else
        	self:unScheduler(self.clockScheduler)
        end
    end
	self.clockScheduler = self:scheduler(update,1,false)
end

function clockView:cleanAll()
	self:unScheduler(self.clockScheduler)
	self:removeAllChildren()
end

return clockView;