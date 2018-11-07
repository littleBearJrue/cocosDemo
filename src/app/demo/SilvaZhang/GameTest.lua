local director = cc.Director:getInstance()
local view = director:getOpenGLView()
local designSize = view:getDesignResolutionSize()
local GameTest = {}
--星星类
local Star = class("Star")
--玩家类
local Player = class("Player")

--初始化星星数据
function Star:initData( ... )
	-- 星星持续时间
	self.maxStarDuration = 6
	-- 出现的最大高度
	self.maxHeight = designSize.height/3
end

--创建星星视图
function Star:createView( )
	local starView = cc.Sprite:create("Images/DemoGame/star.png")
	--记录视图
	self.starView = starView
	starView:setScale(0.5,0.5)
	starView:setAnchorPoint(0.5,0)
	self:setStartMove( )
	return starView
end

--设置星星的移动
function Star:setStartMove( )
	local function update( dt )
		--游戏结束
		local function isOver( ... )
			local myEvent=cc.EventCustom:new("gameOver")
			local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
       		customEventDispatch:dispatchEvent(myEvent)
		end
		local starView = self.starView 
		--如果有action，先停止action
		if self.starAction then
			starView:stopAction(self.starAction)
		end
		local size = starView:getContentSize()
		starView:setCascadeOpacityEnabled(true)
		starView:setOpacity(255)
        local ramdomX = math.random(size.width/4, designSize.width - size.width/4)
        local ramdomY = math.random(designSize.height/3, designSize.height/3 + self.maxHeight)
        --设置随机位置
        starView:setPosition(ramdomX,ramdomY)
        --保存位置
        self.starViewX = ramdomX
        self.starViewY = ramdomY
        --执行淡出action，如果执行完，说明玩家没捉到，游戏结束。
        self.starAction = starView:runAction(cc.Sequence:create(cc.FadeOut:create(dt), cc.CallFunc:create(isOver)))
	end 
	local scheduler = cc.Director:getInstance():getScheduler()
	--如果已经有定时器，先停止
	if self.starScheduleId then
		scheduler:unscheduleScriptEntry(self.starScheduleId)
	end
	update(self.maxStarDuration)
	--每个maxStarDuration调用一次update
	self.starScheduleId = scheduler:scheduleScriptFunc(update, self.maxStarDuration, false)
end

--初始化玩家数据
function Player:initData( )
	-- 加速度方向开关
    self.accLeft = false;
    self.accRight = false;
    -- 主角当前水平方向速度
    self.xSpeed = 0;
    -- 跳跃高度
    self.jumpHeight = designSize.height/3 + 20
	-- 主角跳跃持续时间
	self.jumpDuration = 0.3
	-- 最大移动速度
	self.maxMoveSpeed = designSize.width/3
	-- 加速度
	self.accel = designSize.width/4
end

--创建玩家视图
function Player:createView( )
	local playerView = cc.Sprite:create("Images/DemoGame/PurpleMonster.png")
	playerView:setScale(0.5,0.5)
	playerView:setAnchorPoint(0.5,0)
	playerView:setPosition(designSize.width/2,designSize.height/3)
	self.playerView = playerView
	self:setPlayerJumpAction()
	self:setPlayerKeyEvent()
	self:setPlayerMove()
	return playerView
end

--玩家上下跳动
function Player:setPlayerJumpAction( )
 	--跳跃上升
    local jumpUp = cc.EaseCubicActionOut:create(cc.MoveBy:create(self.jumpDuration, cc.p(0, self.jumpHeight)));
    --下落
    local jumpDown = cc.EaseCubicActionIn:create(cc.MoveBy:create(self.jumpDuration, cc.p(0, -self.jumpHeight)));
    --不断重复
    local action = cc.RepeatForever:create(cc.Sequence:create(jumpUp, jumpDown));
    self.playerView:runAction(action)
end

--键盘事件控制玩家左右加速度
function Player:setPlayerKeyEvent( )
	local function keyboardPressed(keyCode, event)
		if keyCode == 124 then
			self.accLeft = true
		elseif keyCode == 127 then
			self.accRight = true
		end
	end
 	
	local function keyboardReleased(keyCode, event)
		if keyCode == 124 then
			self.accLeft = false
		elseif keyCode == 127 then
			self.accRight = false
		end
	end
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	listener:registerScriptHandler(keyboardReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
	local eventDispatcher = self.playerView:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.playerView )
end

--计算玩家左右移动值
function Player:setPlayerMove( )
	local function update( dt )
		local x,y = self.playerView:getPosition()
		local size = self.playerView:getContentSize()
		--根据当前加速度方向每帧更新速度
        if (self.accLeft) then
            self.xSpeed = self.xSpeed - self.accel * dt;
        elseif (self.accRight) then
            self.xSpeed = self.xSpeed + self.accel * dt;
        end
        --限制主角的速度不能超过最大值
        if ( math.abs(self.xSpeed) > self.maxMoveSpeed ) then
            -- if speed reach limit, use max speed with current direction
            self.xSpeed = self.maxMoveSpeed * self.xSpeed / math.abs(self.xSpeed);
        end
        --根据当前速度更新主角的位置
        x = x + self.xSpeed * dt;
        if x < 0 + size.width/4 then
        	x = 0 + size.width/4
        elseif x > designSize.width - size.width/4 then
        	x = designSize.width - size.width/4
        end
        self.playerView:setPosition(x,y)
        --记录位置
        self.playerViewX = x
        self.playerViewY = y
	end
	--每帧回调
	self.playerView:scheduleUpdateWithPriorityLua(update, 1)
end

--判断是否抓到星星
function GameTest:judgeGrapStar( )
	local function update( dt )
		if math.abs(self.playerObj.playerViewX - self.starObj.starViewX) < self.pickRadius 
			and math.abs(self.playerObj.playerViewY - self.starObj.starViewY) < self.pickRadius then
			self.starObj:setStartMove()
			self.score = self.score + 10
			self.scoreLabel:setString("score:"..self.score)
		end
	end
	local scheduler = cc.Director:getInstance():getScheduler()
	self.judgeScheduleId = scheduler:scheduleScriptFunc(update, 1/60, false)
end

--点击游戏开始按钮
function GameTest:gameStart( )
	self:initData()
	--分数板
	self.scene:addChild(self:createScoreLabel())
	--玩家
	self.playerObj = Player:create()
	self.playerObj:initData()
	self.scene:addChild(self.playerObj:createView())
	--星星
	self.starObj = Star:create()
	self.starObj:initData()
	self.scene:addChild(self.starObj:createView())
	--判断是否抓住
	self:judgeGrapStar()
end

function GameTest:ContinueCallBack( )
	self:releaseView()
	self:createGameStartBtn()
end

function GameTest:releaseView( )
	local scheduler = cc.Director:getInstance():getScheduler()
    if self.starObj and self.starObj.starScheduleId then
		scheduler:unscheduleScriptEntry(self.starObj.starScheduleId)
	end
	if self.judgeScheduleId then
		scheduler:unscheduleScriptEntry(self.judgeScheduleId)
	end
	if self.playerObj and self.playerObj.playerView then
		self.playerObj.playerView:stopAllActions()
		self.playerObj.playerView:removeFromParent()
		self.playerObj = nil
	end
	if self.starObj and self.starObj.starView then
		self.starObj.starView:stopAllActions()
		self.starObj.starView:removeFromParent()
		self.starObj = nil
	end
	if self.scoreLabel then
		self.scoreLabel:removeFromParent()
		self.scoreLabel = nil
	end
end

--游戏结束
function GameTest:setReGameStart( )
	local listenerCustom=cc.EventListenerCustom:create("gameOver",handler(self,self.ContinueCallBack))
    local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
end

--创建开始按钮
function GameTest:createGameStartBtn( )
	local callback = function(tag)
		self.gameStartBtn:setVisible(false)
		self:gameStart()
    end
    if not self.gameStartBtn or tolua.isnull(self.gameStartBtn) then
		local gameStartBtn = ccui.Button:create("Images/DemoGame/btn_play.png","Images/DemoGame/btn_play.png")
		self.gameStartBtn = gameStartBtn
		gameStartBtn:setAnchorPoint(0.5,0.5)
		gameStartBtn:setPosition(designSize.width/2,designSize.height - 100)
		gameStartBtn:addClickEventListener(callback)
		self.scene:addChild(gameStartBtn)
	else
		self.gameStartBtn:setVisible(true)
	end
end

--创建积分
function GameTest:createScoreLabel( )
	local scoreLabel = cc.Label:createWithTTF("Score:"..self.score, s_arialPath, 24)
	self.scoreLabel = scoreLabel
	scoreLabel:setAnchorPoint(0.5,0.5)
	scoreLabel:setPosition(designSize.width/2,designSize.height - 50)
	return scoreLabel
end

--创建背景
function GameTest:createBackGround( )
	local background = cc.Sprite:create("Images/DemoGame/background.jpg")
	background:setContentSize(designSize.width,designSize.height)
	background:setAnchorPoint(0.5,0.5)
	background:setPosition(designSize.width/2,designSize.height/2)
	return background
end

--创建地板
function GameTest:createGround( )
	local ground = cc.Sprite:create("Images/DemoGame/ground.png")
	ground:setContentSize(designSize.width,designSize.height/3)
	ground:setAnchorPoint(0,0)
	ground:setPosition(0,0)
	return ground
end

function GameTest:initData( ... )
	-- 消失距离
	self.pickRadius = 30
	-- 分数
	self.score = 0
end

--主流程
function GameTest:main( ... )
	local scene = cc.Scene:create()
	self.scene = scene
    local function onNodeEvent(event)
        if event == "exit" then
      		self:releaseView()
        elseif event == "enter" then
            scene:addChild(self:createBackGround())
			scene:addChild(self:createGround())
			self:createGameStartBtn()
			--设置游戏结束事件回调函数
			self:setReGameStart()
    		scene:addChild(CreateBackMenuItem())
        end
    end
    scene:registerScriptHandler(onNodeEvent)
    return scene
end

return handler(GameTest, GameTest.main)