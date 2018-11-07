
local function createUI()
	local pageView = ccui.PageView:create()

    -- 这里创建8页page
    for i = 1,8 do
        -- 创建layout,内容添加到layout
        local layout = ccui.Layout:create()
        -- layout大小
        layout:setContentSize(200,200)
        -- 相对于PageView的位置
        layout:setPosition(0,0)

        --纵向排列
        -- layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
        --横向排列
        layout:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)

        -- 在layout中置入一张图片
        local image = ccui.ImageView:create("HelloWorld.png")
        image :setPosition(cc.p(layout:getContentSize().width / 2,layout:getContentSize().height / 2))
        layout:addChild(image)
        local sp = ccui.ImageView:create("yiang/caishen.png")
        layout:addChild(sp)

        -- 将layout(即pageView中的一页)加入pageView
        pageView:addPage(layout)
    end

    -- 设置PageView容器尺寸
    pageView:setContentSize(200,200)
    -- 设置可触摸 若设置为false 则不能响应触摸事件
    pageView:setTouchEnabled(true)
    pageView:setAnchorPoint(cc.p(0.5,0.5))
    pageView:setPosition(cc.p(display.cx,display.cy))

    -- 触摸回调
    local function PageViewCallBack(sender,event)
        -- 翻页时
        if event==ccui.PageViewEventType.turning then
        -- getCurrentPageIndex() 获取当前翻到的页码 打印
           print("当前页码是"..pageView:getCurrentPageIndex())
        end
    end
    pageView:addEventListener(PageViewCallBack)

    -- 水平翻页
    -- pageView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    -- 垂直翻页
    -- pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 翻到第5页
    pageView:scrollToPage(5)


    return pageView
end


local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main