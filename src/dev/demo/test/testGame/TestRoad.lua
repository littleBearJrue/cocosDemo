


local TestRoad = class("TestRoad", cc.Node)

local winSize = cc.Director:getInstance():getWinSize()

function TestRoad:ctor()
	self:init()
end

function TestRoad:dtor()

end

function TestRoad:init()

	local node = NodeUtils:getRootNodeInCreator('creator/Scene/7_game/road.ccreator')
	self:addChild(node)
	node:setPosition(0,0)
	node:setAnchorPoint(cc.p(0,0))
		--node:setPositionX(winSize.width*(i-1))

	self.m_nodeStars = cc.Node:create()
	self:addChild(self.m_nodeStars)
	self.m_nodeStars:setPosition(0,200)
	self:genRandomStars()
end


function TestRoad:genRandomStars()
	self.m_nodeStars:removeAllChildren()
	local count = math.random(5,10)
	local y = math.random(60,100)
	for i=1,count do
		local star = cc.Sprite:create("test/star.png")
		self.m_nodeStars:addChild(star)
		star:setPosition(i*100,y)
	end
end

function TestRoad:checkCollider(player)
	local playerPos = player:convertToWorldSpace(cc.p(0,0))
	local playerRect = cc.rect(playerPos.x,playerPos.y,60,80)
	local children = self.m_nodeStars:getChildren()
	for k,v in pairs(children) do

		local vPos = v:convertToWorldSpace(cc.p(0,0))
		local vRect = cc.rect(vPos.x,vPos.y,40,40)
		if cc.rectIntersectsRect(playerRect,vRect) then
			
			ViewSys:onEvent(1000000,v)
			v:removeFromParent(true)
		end
	end
end

return TestRoad
