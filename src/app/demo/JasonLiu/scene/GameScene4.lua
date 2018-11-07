----------------------ScrollView
local function createScrollView()
    local scrollview = ccui.ScrollView:create() 
    scrollview:setTouchEnabled(true) 
    scrollview:setBounceEnabled(true) 
    scrollview:setDirection(ccui.ScrollViewDir.vertical) --设置滚动的方向 
    scrollview:setContentSize(cc.size(100, display.height)) --设置尺寸 
    scrollview:setPosition(cc.p(scrollview:getContentSize().width / 2, display.height - scrollview:getContentSize().height / 2)) 
    scrollview:setAnchorPoint(cc.p(0.5, 0.5)) 
    scrollview:setScrollBarWidth(1) --滚动条的宽度 
    scrollview:setScrollBarColor(cc.RED) --滚动条的颜色 
    scrollview:setScrollBarPositionFromCorner(cc.p(2,2)) 
    scrollview:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
    scrollview:setBackGroundColor(cc.WHITE)

    local totalHeight = 0
    for i = 1, 100 do
        local button = ccui.Button:create("Images/btn-play-normal.png", "Images/btn-play-selected.png") --创建一个button加在scrollview上
        button:setPosition(cc.p(scrollview:getContentSize().width / 2, button:getContentSize().height / 2 + button:getContentSize().height * (i - 1)))
        totalHeight = totalHeight + button:getContentSize().height
        scrollview:addChild(button)
        button:addTouchEventListener(function (sender, event)  
            if event == ccui.TouchEventType.began then
                print(i .. "  Button TouchEventType.began")
            end
            if event == ccui.TouchEventType.ended then
                print(i .. "  Button TouchEventType.ended")
            end
        end)
    end

    scrollview:setInnerContainerSize(cc.size(scrollview:getContentSize().width, totalHeight))
    scrollview:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
            print("ScrollView ScrollviewEventType.scrollToBottom")
        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
            print("ScrollView ScrollviewEventType.scrollToTop")
        end
    end)

    return scrollview
end

----------------------TableView
--滚动事件
local function scrollViewDidScroll(view)
    print("scrollViewDidScroll")
end

local function scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

--cell点击事件
local function tableCellTouched(table, cell)
    print("cell touched：" .. cell:getIdx())
end

--cell的大小，注册事件就能直接影响界面，不需要主动调用
local function cellSizeForTable(table, idx) 
    return 50, 25
end

--设置cell个数，注册就能生效，不用主动调用
local function numberOfCellsInTableView(table)
   return 100
end

--显示出可视部分的界面，出了裁剪区域的cell就会被复用
local function tableCellAtIndex(table, idx)
    local strValue = string.format("%d", idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        print("new cell")
        cell = cc.TableViewCell:new()

        --添加cell内容
        local sprite = cc.Sprite:create("Images/Pea.png")
        sprite:setAnchorPoint(cc.p(0, 0))
        sprite:setPosition(cc.p(30, 0))
        cell:addChild(sprite)

        label = cc.Label:createWithSystemFont(strValue , "Helvetica", 16)
        label:setPosition(cc.p(5, 0))
        label:setAnchorPoint(cc.p(0, 0))
        label:setColor(cc.c3b(255, 255, 255))
        label:setTag(111)
        cell:addChild(label)
    else
        print("get cell child")
        label = cell:getChildByTag(111)
        if nil ~= label then
            label:setString(strValue)
        end
    end

    return cell
end

local function createTableViewHorizontal()
    --创建TableView
    local tableView = cc.TableView:create(cc.size(display.width - 150, 25))
    --设置滚动方向  水平滚动
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(150, display.height / 2))
    tableView:setDelegate()
    tableView:setAnchorPoint(cc.p(0, 0))
    --cell个数
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    --滚动事件
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    --cell点击事件
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    --cell尺寸、大小
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    --显示出可视部分的cell
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    --调用这个才会显示界面
    tableView:reloadData()

    return tableView
end

local function createTableViewVerTical()
    local tableView = cc.TableView:create(cc.size(50, display.height))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(100, 0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    return tableView
end

----------------------Shedule
local function createLabelTestShedule1()
    local label = cc.Label:createWithSystemFont("Hello World", "Arial", 14):move(display.cx, display.cy + 100)

    label:scheduleUpdateWithPriorityLua(function(dt) -- 该方法默认为每帧都刷新一次，无法自定义刷新时间间隔, dt：Delta Time的缩写，两帧之间的时间差
        label:setString(dt)
    end, 0) -- 刷新函数, 刷新优先级

    return label
end

local function createLabelTestShedule2()
    local time = 0
    local label = cc.Label:createWithSystemFont(string.format( "Time：%d", time), "Arial", 14):move(display.cx + 150, display.cy + 100)

    schedule(label, function()  
        time = time + 1
        label:setString(string.format( "Time：%d", time))
    end, 1)  
    -- local scheduler = cc.Director:getInstance():getScheduler()
    -- local schedulerId = scheduler:scheduleScriptFunc(function ()
    --     time = time + 1
    --     label:setString("Time："..time)
    -- end, 1, false) -- 刷新函数, 每次刷新的时间间隔,是否只执行一次, false为无限次。

    -- scheduler:scheduleScriptFunc(function ()
    --     if time > 10 then
    --         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerId)
    --     end
    -- end, 1, false) 

    return label
end

-- 在引擎根目录/cocos/scripting/lua-bindings/script 的extern.lua文件中定义了 schedule 和 performWithDelay 两个函数
-- function performWithDelay(node, callback, delay)
--     local delay = cc.DelayTime:create(delay)
--     local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
--     node:runAction(sequence)

--     return sequence
-- end
-- function schedule(node, callback, delay)
--     local delay = cc.DelayTime:create(delay)
--     local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
--     local action = cc.RepeatForever:create(sequence)
--     node:runAction(action)
--     return action
-- end

local function createLabelTestShedule3()
    local label = cc.Label:createWithSystemFont("Hello World !", "Arial", 14):move(display.cx + 150, display.cy - 80)
    
    performWithDelay(label, function()  
        label:setString("Game Over !")
    end, 2)  

    -- local time = 0
    -- schedule(label, function()  
    --     time = time + 1
    --     label:setString(string.format( "Time：%d", time))
    -- end, 1)  

    return label
end

local function main()
    local scene = cc.Scene:create()
    
    scene:addChild(createScrollView()) 
    scene:addChild(createTableViewHorizontal())
    scene:addChild(createTableViewVerTical())
    scene:addChild(createLabelTestShedule1())
    scene:addChild(createLabelTestShedule2())
    scene:addChild(createLabelTestShedule3())
    scene:addChild(CreateBackMenuItem())
    
    return scene
end

return main