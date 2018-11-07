-- @module: ScrollViewTest
-- @author: JoeyChen
-- @Date:   2018-10-22 10:31:02
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-22 15:52:25

local function createUI()
	local scrollview = ccui.ScrollView:create()
	-- 能否触摸
	scrollview:setTouchEnabled(true)
	-- 能否弹回
	scrollview:setBounceEnabled(true)
	-- 滚动方向
	scrollview:setDirection(ccui.ScrollViewDir.vertical)
	-- 设置位置
	scrollview:setPosition(cc.p(display.cx,display.cy)) 
	scrollview:setAnchorPoint(cc.p(0.5,0.5))
	-- 设置滚动条宽度 
	scrollview:setScrollBarWidth(20)
	-- 设置滚动条颜色 
	scrollview:setScrollBarColor(cc.RED)
	-- 设置背景色
    scrollview:setBackGroundColor(cc.c3b(255, 255, 150));
    scrollview:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- 设置滚动条水平位置和垂直位置
	scrollview:setScrollBarPositionFromCorner(cc.p(10,10))
	-- 设置大小
	scrollview:setContentSize(cc.size(200 ,300))
	

	local svSize, size = nil
	local index = 0
	for i = 1, 16, 1 do
		local s = cc.Sprite:create("JoeyChen/1.png")
		svSize = scrollview:getContentSize()
		size = s:getContentSize()
		s:setPosition(svSize.width/2, (size.height + 10) * 16 - (size.height + 10) * (i - 0.5))
		s:addTo(scrollview)

		index = index + 1
	end

	scrollview:setInnerContainerSize(cc.size(svSize.width, (size.height + 10) * index))

	return scrollview
end 

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main