


local TestPlayer = class("TestPlayer", cc.Node)

local winSize = cc.Director:getInstance():getWinSize()


local STATE_RUN = 1
local STATE_JUMP = 2
local STATE_SLIDE = 3


function TestPlayer:ctor()

	self:init()

end

function TestPlayer:dtor()

end

function TestPlayer:init()

	
	self.m_jump = cc.Sprite:create()
	self.m_ani = projectx.lcc_playFrameAni(self,0,0,100,true)
	
	local _onUpdate = function ( dt )
		self:onMyUpdate(dt)
    end
      
    self:scheduleUpdate(_onUpdate)
end

function TestPlayer:onMyUpdate(dt)
end


function TestPlayer:changeState(state)
	if self.m_status == state then
		return 
	end

	self.m_status = state
end


return TestPlayer
