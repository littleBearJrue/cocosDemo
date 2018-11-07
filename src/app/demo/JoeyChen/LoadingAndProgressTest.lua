-- @module: LoadingAndProgressTest
-- @author: JoeyChen
-- @Date:   2018-10-19 12:14:36
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-19 15:53:35

local num = 25

local function createUI()
    local loading = ccui.LoadingBar:create("Images/cocos2dbanner.png",num)
    loading:setName("loading")
    -- loading:setDirection(LoadingBar.Direction:RIGHT);  -- 进度条方向
    loading:setPosition(display.cx - 50, display.cy + 100)

	return loading
end 

local function createButton(loadingBar)
	local btn = ccui.Button:create("JoeyChen/2.png","JoeyChen/3.png")
		:move(display.cx + 100, display.cy + 100)
		:setTitleText("增加")
		:setTitleFontSize(20)
	btn:addClickEventListener(function ()
		num = num >= 100 and 0 or num + 25
        local scene = display.getRunningScene()
        local loadingBar = scene:getChildByName("loading")
		loadingBar:setPercent(num);
	end)

	return btn
end

local function createProgressTimer()
	-- 创建并初始化进度,第一个参数是duration持续时间，100为进度  
	local to1 = cc.ProgressTo:create(3, 100)  
	local to2 = cc.ProgressTo:create(3, 100)  
	  
	-- ProgressTimer是Node的子类。 该类根据百分比来渲染显示内部的Sprite对象。 变化方向包括径向，水平或者垂直方向。  
	local left1 = cc.ProgressTimer:create(cc.Sprite:create("JoeyChen/1.png"))  
	-- 设置进度计时的类型，这里是绕圆心  
	left1:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)  
	-- 设置显示位置  
	left1:setPosition(cc.p(100, 100))  
	-- 运行动作  
	left1:runAction(cc.RepeatForever:create(to1))  

	local right1 = cc.ProgressTimer:create(cc.Sprite:create("JoeyChen/4.png"))  
	-- 设置进度计时的类型  
	right1:setType(cc.PROGRESS_TIMER_TYPE_RADIAL) 
	-- 设置反向 
	right1:setReverseDirection(true)
	-- 设置位置  
	right1:setPosition(cc.p(200,100))  
	-- 运行动作，无限循环  
	right1:runAction(cc.RepeatForever:create(to2))   
	 	 
	-- 创建进度条  
	local to3 = cc.ProgressTo:create(3, 100)  
	local to4 = cc.ProgressTo:create(3, 100)  
	   
	local left = cc.ProgressTimer:create(cc.Sprite:create("JoeyChen/1.png"))  
	-- 设置进度条类型，这里是条形进度类型  
	left:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	-- 起点左边 
	left:setMidpoint(cc.p(0, 0))    
	left:setBarChangeRate(cc.p(1, 0))  
	left:setPosition(cc.p(100, 200))  
	left:runAction(cc.RepeatForever:create(to3))  
	      
	local right = cc.ProgressTimer:create(cc.Sprite:create("JoeyChen/4.png"))  
	-- 设置渲染类型  
	right:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	-- 起点右边 
	right:setMidpoint(cc.p(1, 0))    
	right:setBarChangeRate(cc.p(1, 0))   
	right:setPosition(cc.p(200, 200))   
	right:runAction(cc.RepeatForever:create(to4))

	return left, right, left1, right1
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(createButton())
    local left, right, left1, right1 = createProgressTimer()
    scene:addChild(left)
    scene:addChild(right)
    scene:addChild(left1)
    scene:addChild(right1)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main