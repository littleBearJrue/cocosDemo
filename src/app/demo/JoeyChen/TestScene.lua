local isDrag = false

local function beginAction(head, text)
    text:setString("快不快乐")
    local pMove1 = cc.MoveTo:create(0.5,cc.p(80,display.height/2))
    local pMove2 = cc.MoveTo:create(0.5,cc.p(display.width/2,display.height-100))
    local pMove3 = cc.MoveTo:create(0.5,cc.p(display.width-80,display.height/2))
    local pMove4 = cc.MoveTo:create(0.5,cc.p(display.width/2,50))
    local pMove5 = cc.MoveTo:create(0.5,cc.p(display.center))

    local function callback()
        text:setString("溜了溜了")

        head:runAction(cc.Spawn:create(cc.FadeOut:create(1),cc.ScaleTo:create(1, 0)))
        text:runAction(cc.FadeOut:create(1))
    end

    head:runAction(cc.Sequence:create(pMove1,pMove2,pMove3,pMove4,pMove5,cc.CallFunc:create(callback)))
end

local function initUI(isDrag)
	local head = cc.Sprite:create("JoeyChen/1.png")
	head:setPosition(display.cx, display.cy)
    head:setName("head")
    local str = ""
    str = not isDrag and "点我试试" or "拖我试试"
    local text =  cc.Label:createWithSystemFont(str, "Arial", 30)
        :move(cc.p(15,50))
        :addTo(head)

    local function onTouchBegan(touch,event)
        local point = touch:getLocation()
        local rect = head:getBoundingBox()
        if (cc.rectContainsPoint(rect,point)) then
            return true;
        end
    
        return false;
    end
    local function onTouchEnded(touch,event)
        if not isDrag then 
            beginAction(head, text)
        else
            text:setString("拖我试试")
        end
    end
    local function onTouchMoved(touch, event)
        if isDrag then
            local posX,posY = head:getPosition()  --获取当前的位置
            local delta = touch:getDelta() --获取滑动的距离
            head:setPosition(cc.p(posX + delta.x, posY + delta.y)) --给精灵重新设置位置

            text:setString("开不开心")
        end
    end
 
    local listener = cc.EventListenerTouchOneByOne:create()  --创建一个单点事件监听
    listener:setSwallowTouches(true)  --是否向下传递
    --注册三个回调监听方法
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    
    local eventDispatcher = head:getEventDispatcher() --事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, head) --分发监听事件

    return head
end

local function createButton1()
    local button1 = ccui.Button:create("JoeyChen/2.png","JoeyChen/3.png","JoeyChen/3.png")
        :move(cc.p(100,50))
        --按钮文字
        button1:setTitleText("还原")
        --字体大小
        button1:setTitleFontSize(25)
        --字体颜色
        button1:setTitleColor(cc.c3b(255, 255, 255))
        --按钮的回调函数
        button1:addClickEventListener(function()
            local scene = display.getRunningScene()
            local head = scene:getChildByName("head")
            if head then
                head:removeSelf()
            end
            scene:addChild(initUI(isDrag))
        end)

    return button1
end

local function createButton2()
    local str = ""
    str = not isDrag and "点击还原为点击模式" or "点击还原为拖动模式"
    local scene = display.getRunningScene()
    local text =  cc.Label:createWithSystemFont(str, "Arial", 20)
        :move(cc.p(350,50))

    local button2 = ccui.Button:create("JoeyChen/2.png","JoeyChen/3.png","JoeyChen/3.png")
        :move(cc.p(200,50))
        --按钮文字
        button2:setTitleText("点击/拖动")
        --字体大小
        button2:setTitleFontSize(20)
        --字体颜色
        button2:setTitleColor(cc.c3b(255, 255, 255))
        --按钮的回调函数
        button2:addClickEventListener(function()
            isDrag = not isDrag and true or false
            text:setString(not isDrag and "点击还原为点击模式" or "点击还原为拖动模式")
        end)

    return button2,text
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(initUI())
    scene:addChild(createButton1())
    local button2,text = createButton2()
    scene:addChild(button2)
    scene:addChild(text)
    scene:addChild(CreateBackMenuItem())

    return scene
end

return main