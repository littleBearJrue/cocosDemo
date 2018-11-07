-- @Author: YiangYang
-- @Date:   2018-10-22 10:35:24
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 18:24:50

local function createUI()
	local AlarmClock = import(".AlarmClock")
	local clock = AlarmClock:create(11,1)
	clock:setPosition(display.cx,display.cy)
	clock:setAnchorPoint(cc.p(0.5,0.5))
	return clock
end


local function main()
	
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main