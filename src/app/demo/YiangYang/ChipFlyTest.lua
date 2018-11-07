-- @Author: YiangYang
-- @Date:   2018-10-22 16:12:08
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 18:27:00

local function createUI()
	local ChipFly = import(".ChipFly")
	local chipFly = ChipFly:create()
	return chipFly
end


local function main()

    local scene = cc.Scene:create()
    local chipFly =  createUI()
    scene:addChild(chipFly)


    local function onClick()
    chipFly:playFlyChipAnim(cc.p(0,0),cc.p(display.cx+100,display.cy+100))
    	-- chipFly:removeAllChildrenWithCleanup(true)
    	local x1 = math.random(0,display.cx)
    	local y1 = math.random(0,display.cy)
    	local x2 = math.random(display.cx,display.width)
    	local y2 = math.random(display.cy,display.height)
    	dump(x1, "x1 = ")
    	dump(y1, "y1 = ")
    	dump(x2, "x2 = ")
    	dump(y2, "y2 = ")
    	-- chipFly:playFlyChipAnim(cc.p(0,0),cc.p(display.cx+100,display.cy+100))
    	-- chipFly:playFlyChipAnim(cc.p(x1,y1),cc.p(x2,y2))
    end

	-- local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal):move(display.cx, display.height-100)
	-- btn:addClickEventListener(onClick)
    
 --    scene:addChild(btn)
    scene:addChild(CreateBackMenuItem())


    return scene
end

return main