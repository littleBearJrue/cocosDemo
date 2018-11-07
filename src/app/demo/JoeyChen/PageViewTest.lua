-- @module: PageViewTest
-- @author: JoeyChen
-- @Date:   2018-10-22 16:14:39
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-22 17:32:49

local function createUI()
	local pageView = ccui.PageView:create()
    -- 设置容器尺寸
    pageView:setContentSize(200,200)
    -- 设置能否触摸
    pageView:setTouchEnabled(true)
    pageView:setAnchorPoint(cc.p(0.5,0.5))
    pageView:setPosition(display.cx,display.cy)

	for i = 1, 5, 1 do
	    local layout = ccui.Layout:create()
	    layout:setContentSize(200,200)
		layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
		layout:setBackGroundColor(cc.c3b(255, 255, 150));
	    layout:setPosition(display.cx,display.cy)

	    local text = cc.Label:createWithSystemFont("第" .. i .. "页", "Arial", 30)
	    	:setTextColor(cc.c3b(0, 0, 0))
	    	:move(layout:getContentSize().width/2, layout:getContentSize().height/2)
	    	:addTo(layout)

	    pageView:addPage(layout)
	end

    -- 触摸回调
    local function callBackFunc(sender,event)
    	-- 翻页
        if event == ccui.PageViewEventType.turning then
        	-- 页码索引(索引从0开始，需加1)
        	local index = pageView:getCurrentPageIndex()
        	print("翻到了第" .. index + 1 .. "页")
        end
    end
    pageView:addEventListener(callBackFunc)

    -- 垂直翻页
    -- pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 翻到第3页(索引从0开始)
    pageView:scrollToPage(2)

	return pageView
end 

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main