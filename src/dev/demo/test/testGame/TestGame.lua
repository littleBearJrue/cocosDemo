
require "dev.demo.scenes.layers.PopupLayer"

local TestPlayer = require "dev.demo.test.testGame.TestPlayer"
local TestRoad = require "dev.demo.test.testGame.TestRoad"

local TestGame = class("TestGame", PopupLayer)


local winSize = cc.Director:getInstance():getWinSize()




function TestGame:ctor()
	PopupLayer.ctor(self)
	self.m_starScroe = 0
	self:init()
	ViewSys:regEventHandler(1000000,self.onTouchStar,self)
end

function TestGame:dtor()
	ViewSys:unregEventHandler(1000000,self.onTouchStar,self)
	SoundManager:stopMusic()
end

function TestGame:init()

	SoundManager:playMusic("test/sounds/winter_music.mp3",true)
	self:initData()
	self:initBg()
	self:initRoad()
	self:initPlayer()
	self:initControl()
	
	

	local _onUpdate = function ( dt )
		self:updateBg(dt)
		self:updatePlayer(dt)
		self:updateRoad(dt)
    end
      
    self:scheduleUpdate(_onUpdate)
end

function TestGame:initData()
	 self.m_bestScore = cc.UserDefault:getInstance():getIntegerForKey("BestScore",0)
end

function TestGame:saveData()
	cc.UserDefault:getInstance():setIntegerForKey("BestScore",self.m_bestScore)
end

function TestGame:initBg()
	self.m_nodeBgs = {}
	for i=1,2 do
		self.m_nodeBgs[i] = NodeUtils:getRootNodeInCreator('creator/Scene/7_game/bg.ccreator')
		self:addChild(self.m_nodeBgs[i],0,-1)
		self.m_nodeBgs[i]:setPosition(0,0)
		self.m_nodeBgs[i]:setAnchorPoint(cc.p(0,0))
		local bg = NodeUtils:seekNodeByName(self.m_nodeBgs[i],'back_winter') 
		bg:setContentSize(winSize)
		--local x,y = self.m_nodeBgs[i]:getPosition()
		self.m_nodeBgs[i]:setPositionX(winSize.width*(i-1))
	end
end

function TestGame:updateBg(dt)
	for i=1,2 do
		local x, y = self.m_nodeBgs[i]:getPosition()
		x = x - dt*10
		if x <= -winSize.width then
			self.m_nodeBgs[i]:setPositionX(winSize.width)
		else

			self.m_nodeBgs[i]:setPositionX(x)
		end
	end

end

function TestGame:initControl()

	
	self.m_nodeControl = NodeUtils:getRootNodeInCreator('creator/Scene/7_game/control.ccreator')
	self:addChild(self.m_nodeControl,1,2)


	self.m_labelScore = NodeUtils:seekNodeByName(self.m_nodeControl,'label_score') 
	self.m_labelScore:setString("0")

	self.m_labelBest = NodeUtils:seekNodeByName(self.m_nodeControl,'label_best') 
	self.m_labelBest:setString(tostring(self.m_bestScore))
	

	local btExit = NodeUtils:seekNodeByName(self.m_nodeControl,'bt_exit') 

	btExit:setPressedActionEnabled(true)
	btExit:addClickEventListener(function(sender)
		self:exitPopupLayer()
		end)

	local btJump = NodeUtils:seekNodeByName(self.m_nodeControl,'btnJump') 


	btJump:addClickEventListener(function(sender)
			local action = cc.JumpBy:create(1.0,cc.p(0,0),100,1)

			self.m_player:runAction(action)
			end)
		
end

function TestGame:initRoad()

	self.m_arrangeNode = cc.Node:create()
	self:addChild(self.m_arrangeNode)


	self.m_nodeRoads = {}
	for i=1,2 do
		self.m_nodeRoads[i] = TestRoad:create()
		self.m_arrangeNode:addChild(self.m_nodeRoads[i])

		self.m_nodeRoads[i]:setPositionX(winSize.width*(i-1))
	end
end

function TestGame:updateRoad()
	local p = self.m_arrangeNode:convertToNodeSpace( cc.p(display.cx,display.cy))
    local playerX,playerY = self.m_player:getPosition()
    local dx = playerX - p.x
    local dy = playerY - p.y

	local x,y = self.m_arrangeNode:getPosition()
	x = x - dx
	if x >0 then
		x = 0
	end
	self.m_arrangeNode:setPositionX(x)

	for i=1,2 do
		local pos = self.m_nodeRoads[i]:convertToWorldSpace(cc.p(0,0))
		if pos.x < -winSize.width then
			local rx = self.m_nodeRoads[i]:getPosition()
			self.m_nodeRoads[i]:setPositionX(rx+2*winSize.width)
			self.m_nodeRoads[i]:genRandomStars()
		end
		self.m_nodeRoads[i]:checkCollider(self.m_player)
	end

end



function TestGame:initPlayer()

	self.m_player = TestPlayer:create()

	self.m_arrangeNode:addChild(self.m_player)

	self.m_player:setPosition(100,170)
end

function TestGame:updatePlayer(dt)
	local x,y = self.m_player:getPosition()
	x = x+ dt*150
	self.m_player:setPositionX(x)
end

function TestGame:onTouchStar(star)

	SoundManager:playEffect("test/sounds/point.mp3")

	local vPos = star:convertToWorldSpace(cc.p(0,0))
	local nodePos = self:convertToNodeSpace(vPos)
	

	local star2 = cc.Sprite:create("test/star.png")

	self:addChild(star2)
	star2:setPosition(nodePos)



	local wp = self.m_labelScore:convertToWorldSpace(cc.p(0,0))
	local targetPos = self:convertToNodeSpace(wp)

	local temFunc = function ( dt )
		star2:removeFromParent(true)

		self.m_starScroe = 	self.m_starScroe + 1
		self.m_labelScore:setString(tostring(self.m_starScroe ))
		if self.m_starScroe > self.m_bestScore then
			self.m_bestScore = self.m_starScroe
			self.m_labelBest:setString(tostring(self.m_bestScore))
			self:saveData()
		end
    end
	local actionFunc = cc.CallFunc:create(temFunc)


	local action = cc.MoveTo:create(0.3,cc.p(targetPos.x,targetPos.y))

	local sq = cc.Sequence:create(action,actionFunc)


	star2:runAction(sq)

	
end


return TestGame
