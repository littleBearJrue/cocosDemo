-- @module: LayoutTest
-- @author: JoeyChen
-- @Date:   2018-10-19 10:46:48
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-19 11:38:02

local function createUI()
    local layout = ccui.Layout:create()
    layout:setContentSize(200,200)
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	layout:setBackGroundColor(cc.c3b(255, 255, 150));
	layout:setAnchorPoint(0.5,0.5)
    layout:setPosition(display.cx,display.cy)
    -- LAYOUT_LINEAR_VERTICAL(纵向排列)
    -- LAYOUT_LINEAR_HORIZONTAL(横向排列)
    layout:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)

    -- LinearLayoutParameter(线性布局参数)
    local parameter	=  ccui.LinearLayoutParameter:create()
    -- centerVertical(纵向居中)
    -- centerHorizontal(横向居中)
    parameter:setGravity(ccui.LinearGravity.centerVertical)
    -- 设置外边距
    parameter:setMargin({ left = 0, top = 0, right = 0, bottom  = 0 } )

    for i=1,5 do
	    local image = ccui.ImageView:create("JoeyChen/1.png")
	    layout:addChild(image)
	   	image:setLayoutParameter(parameter)
    end

	return layout
end 

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main