
local function initListView()

	local lv = ccui.ListView:create();
	lv:setPosition(display.cx,0)
	lv:setAnchorPoint(cc.p(0.5, 0))
	lv:setContentSize(cc.size(100, display.height)); --以lv坐标原点撑开的大小，添加的item项从最高点开始往下
	lv:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	lv:setBounceEnabled(true);
	lv:setItemsMargin(10)
	lv:setScrollBarEnabled(false) 

	for i = 1, 5 do
		local layout = ccui.Layout:create();
		layout:setContentSize(cc.size(100, 100));
		layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
		layout:setBackGroundColor(cc.c3b(255, 255, 0));
		lv:pushBackCustomItem(layout);
 		local sp = display.newSprite("yiang/caishen.png")
 		:setPosition(cc.p(50,80))
 		layout:addChild(sp,1)
 		local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal, 0)
	    :move(50, 50)
    	layout:addChild(btn)
    	local testLabel = cc.Label:createWithTTF("hello world", s_arialPath, 15)
    	:move(50, 30)
    	layout:addChild(testLabel)
    	testLabel:setString("say hi "..i)

    	btn:addTouchEventListener(function ( sender,event )
    		--event : 0->按下；1->移动；2->按下松开；3->移动后松开，即取消
    		-- dump(event,"event == ")
    		if event == 2 then
    			btn:setTitleText("点击第"..i.."个")
    			sender:getParent():setBackGroundColor(cc.c3b(math.random(1,255),math.random(1,255),math.random(1,255)));
    			-- dump(sender:getParent():getChildren()[3],"number = ")
    			-- sender:getParent():getChildren()[3]:setString("改变文本")
    		end
    	end)
	end

	-- lv:selectedItemEvent(function ( event )
	-- 	dump(event,"event == ")
	-- end)
	-- lv:interceptTouchEvent(function ( event,sender,touch )
	-- 	-- dump(event,"event == ")
	-- end)

	-- lv:addEventListener(function(sender, eventType)
	-- 	dump(eventType,"eventType == ")
 --        local event = {}
 --        if eventType == 0 then
 --            event.name = "ON_SELECTED_ITEM_START"
 --        else
 --            event.name = "ON_SELECTED_ITEM_END"
 --        end
 --        event.target = sender
 --    end)


	return lv
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(initListView())
    scene:addChild(CreateBackMenuItem())
    return scene
end
return main