
local function createUI()
	 local tests = {
        "水瓶座",
        "双鱼座",
        "白羊座",
        "金牛座",
        "双子座",
        "巨蟹座",
        "狮子座",
        "处女座",
        "天平座",
        "天蝎座",
        "射手座",
        "摩羯座",      
        "XX座",      
        "YY座",      
    }
    
	local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true) 
	scrollview:setBounceEnabled(true) --这句必须要不然就不会滚动
	scrollview:setDirection(ccui.ScrollViewDir.vertical) --设置滚动的方向 
	-- scrollview:setContentSize(cc.size(800,500)) --设置尺寸 
	scrollview:setPosition(cc.p(display.cx,0)) 
	scrollview:setAnchorPoint(cc.p(0.5,0)) 
	scrollview:setScrollBarWidth(30) --滚动条的宽度 
	scrollview:setScrollBarColor(cc.RED) --滚动条的颜色 
	scrollview:setScrollBarPositionFromCorner(cc.p(10,10))  

    local total = 0
    local btnSize = nil
    for i = #tests, 1, -1 do
        local btn = ccui.Button:create()
        btn:setTitleText(tests[i])
        btn:setTitleFontSize(24)
        btn:addTouchEventListener(function(sender, eventType)
            if 2 == eventType then
                print(i)
            end
        end)
        if not btnSize then
            btnSize = btn:getContentSize()
        end
        btn:move((display.width - btnSize.width) / 2 + btnSize.width / 2,
                btnSize.height * total + btnSize.height / 2)
        total = total + 1
 
        scrollview:addChild(btn)
    end
 
    local totalHeight = btnSize.height * total
    scrollview:setInnerContainerSize(cc.size(display.width, totalHeight)) --若不设置，则当内容高度超过sv高度时不会显示完整
    -- local winSize = cc.Director:getInstance():getWinSize()
    local scrollHeight = display.height
    -- if totalHeight < scrollHeight then
    --     scrollHeight = totalHeight
    -- end
    scrollview:setContentSize(cc.size(display.width, scrollHeight))

    return scrollview
end


local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main