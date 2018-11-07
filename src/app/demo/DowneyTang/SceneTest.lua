local function scene1()
    local ret = cc.Layer:create()
    
    --游戏介绍场景
    local function gameIntroScene(tag, pSender)
        --加载场景
        local creatorReader = creator.CreatorReader:createWithFilename('creator/scene1.ccreator');
        creatorReader:setup();
        local scene = creatorReader:getSceneGraph();
        cc.Director:getInstance():pushScene(scene)
        local s = cc.Director:getInstance():getVisibleSize()
        release_print("gameIntroScene")

        --UIScrollView
        local function scrollViewDidScroll(view)
            release_print("hahaha")
        end
		local scrollLayer = cc.LayerColor:create(cc.c4b(255,255,255,255));
		scrollLayer:setContentSize(cc.size(150,420));        --设置容器的尺寸大小
		for i = 1, 8 do                                      --容器中添加八个按钮
			local btn = cc.Sprite:create("Images/r1.png");
			btn:setPosition(cc.p(75, 420 - 50*i) );
            scrollLayer:addChild(btn);
            i = i+ 1
        end
        local scrollView = cc.ScrollView:create(cc.size(150, 280), scrollLayer) --设置ScrollView的尺寸大小
        scrollView:setPosition(s.width*0.75, s.height*0.5)
        scrollView:setBounceable(true);
        scrollView:setDelegate();
        scrollView:setDirection(kCCScrollViewDirectionVertical);    --设置为只能纵向滚动，也可以设置为数字，0是水平方向kCCScrollViewDirectionHorizontal
		scene:addChild(scrollView, 0, 2);                           --1是垂直方向kCCScrollViewDirectionVertical，2是水平垂直都可以kCCScrollViewDirectionBoth

        local slider = ccui.Slider:create("Images/bug12847_sprite.png","Images/sprites_test/sprite-0-2.png")
        :move(display.cx,display.cy)
        slider:addTo(scene)
        slider:setMaxPercent(100) --设置峰值
        slider:setPercent(50) --选中50%
        slider:addEventListenerSlider(function ( sender,selector )
            dump(selector, "selector == ")
            dump(sender:getPercent(), "百分之")
        end)

        --返回按钮
        local child = scene:getChildren()
        local canvas = child[2]
        local back_button = canvas:getChildByName("back_button")
        back_button:addClickEventListener(function()
            cc.Director:getInstance():popScene()
        end)
    end
    
    
    --游戏界面
    local function gameScene(tag, pSender)
        --加载场景
        local creatorReader = creator.CreatorReader:createWithFilename('creator/zzz.ccreator');
        creatorReader:setup();
        local scene = creatorReader:getSceneGraph();
        cc.Director:getInstance():pushScene(scene)
        local s = cc.Director:getInstance():getVisibleSize()
        release_print("gameScene")

        --UIImageView
        --精灵Sprite加载图片用的是setTexture,ImageView加载图片是用loadTexture
        local sprite1 = cc.Sprite:create("HelloWorld.png")
        sprite1:setPosition(s.width/4, s.height/2)
        --sprite1:setTexture("timg.png")
        local image1 = ccui.ImageView:create("HelloWorld.png")
        image1:setPosition(s.width*0.75, s.height/2)
        image1:addTo(scene)--子节点加入父节点的先后顺序影响子节点的显示，图像重叠时后加入会覆盖先加入的
        sprite1:addTo(scene)
        --image1:loadTexture("timg.png")
        --sprite的动作
        local  rotate = cc.RotateBy:create(2, 360)
        local moveByRight = cc.MoveTo:create(2.0, cc.p(s.width*0.75, s.height/2));
        local scaleBig = cc.ScaleBy:create(2, 2)
        local  rotate1 = cc.RotateBy:create(2, -360)
        local moveByLeft = cc.MoveTo:create(2.0, cc.p(s.width/4,s.height/2));
        local scaleSmall = cc.ScaleBy:create(2, 0.5)
        local mySequence = cc.Sequence:create(rotate, moveByRight, scaleBig, rotate1, moveByLeft, scaleSmall, nullptr)
        local  repeatAction = cc.RepeatForever:create(mySequence)
        sprite1:runAction(repeatAction)  

        --UIText
        local text1 = ccui.Text:create("hello", "Arial", 40)
        text1:addTo(scene)
        text1:setString("checkBox Test")                    --设置文字
        text1:setTextColor(cc.c4b(128, 128, 128, 255))      --设置颜色
        text1:setPosition(s.width/3, s.height/4)            --设置坐标
        text1:setFontSize(35)                               --设置字体尺寸
        local Label1 = cc.Label:createWithSystemFont("Touch Test", "Arial", 35)
        Label1:addTo(scene)
        Label1:setTextColor(cc.c4b(128, 128, 128, 255))
        Label1:setPosition(s.width/3, s.height/7)

        --UITextField
        --TextField没有输入框、光标难以辨别，EditBox带有输入框、光标且可以在cocos creator进行创建
        local function textEvent(sender, eventType)
            release_print("editing a TextField");
        end
        local textField1 = ccui.TextField:create("TextField Test","Arial",30)
        textField1:setPosition(s.width*0.65, s.height/4) 
        textField1:addTouchEventListener(textEvent)
        textField1:addTo(scene)
        --EditBox的创建及相关属性设置
        local function editboxHandle(eventType,sender)
            if eventType == "began" then
                release_print("editing began");                   --进入输入框显示光标，清空内容/选择全部
            elseif eventType == "ended" then
                release_print("editing ended");                   --当编辑框失去焦点并且键盘消失的时候被调用
            elseif eventType == "return" then
                release_print("editing return");                   --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
            elseif eventType == "changed" then
                release_print("editing changed");                   --输入内容改变时调用 
            end
        end
        local editBox1 = ccui.EditBox:create(cc.size(200,50), "Images/bug12847_sprite.png")--自定义编辑框，参数一尺寸大小，参数二背景图片
        editBox1:setPosition(s.width*0.65, s.height/11) 
        editBox1:setFontSize(40)                                    --设置输入设置字体的大小
        editBox1:setMaxLength(6)                                    --设置输入最大长度为6
        editBox1:setFontColor(cc.c4b(124,92,63,255))                --设置输入的字体颜色
        editBox1:setFontName("simhei")                              --设置输入的字体为simhei.ttf
        editBox1:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)       --设置输入为密码类型
        -- editBox1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)     --设置数字符号键盘
        editBox1:setPlaceHolder("EditBox Test")                     --设置预制提示文本
        -- editBox1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)      --输入键盘返回类型，done，send，go等KEYBOARD_RETURNTYPE_DONE
        -- editBox1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)     --输入模型，如整数类型，URL，电话号码等，会检测是否符合
        editBox1:registerScriptEditBoxHandler(editboxHandle)        --输入框的事件，主要有光标移进去，光标移出来，以及输入内容改变等
        -- editBox1:setHACenter()                                   --输入的内容锚点为中心，与anch不同，anch是用来确定控件位置的，而这里是确定输入内容向什么方向展开
        editBox1:addTo(scene)

        --UICheckBox
        local box =1
        local checkBox = ccui.CheckBox:create("Images/r1.png","Images/r2.png")
        checkBox:addTo(scene)
        checkBox:setScale(2)
        checkBox:setPosition(s.width/6, s.height/4)
        checkBox:addEventListener(function(sender, eventType)
            if box then
                text1:setString("蓝色")
                box =nil
            else
                text1:setString("绿色")
                box =1
            end
        end)
        
        --UIProgressTimer
        local testSprite = cc.Sprite:create("HelloWorld.png")
        local progressTest = cc.ProgressTimer:create(testSprite)
        local toFill = cc.ProgressTo:create(5, 100)
        local toZero = cc.ProgressFromTo:create(5, 100, 0)
        progressTest:setPosition(s.width/2, s.height/2)
        progressTest:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        local proSequence = cc.Sequence:create(toFill, toZero)
        progressTest:runAction(cc.RepeatForever:create(proSequence))
        progressTest:setPercentage(0)
        -- progressTest:setReverseDirection(true)   --设置是否反向
        progressTest:addTo(scene)

        local to1 = cc.ProgressTo:create(5, 100)
        local to2 = cc.ProgressFromTo:create(5, 100, 0)
        local left = cc.ProgressTimer:create(cc.Sprite:create("Images/bug12847_sprite.png"))
        left:setType(cc.PROGRESS_TIMER_TYPE_BAR)-- 设置进度条类型，这里是条形进度类型
        left:setMidpoint(cc.p(0, 0))            --设置进度条起始点
        left:setBarChangeRate(cc.p(1, 0))       --设置进度条动画方向的，（1,0）表示横方向变化，纵方向不变，（0,1）则相反
        left:setPosition(s.width*0.85, s.height*0.85)
        local proSequence1 = cc.Sequence:create(to1, to2)
        left:runAction(cc.RepeatForever:create(proSequence1))
        scene:addChild(left)

        --UILoadingBar
        local loadingBar1 = ccui.LoadingBar:create("Images/bug12847_sprite.png")
        -- loadingBar1:setDirection(LoadingBar.Direction:RIGHT);
        loadingBar1:setPercent(25);
        loadingBar1:setPercent(50);
        loadingBar1:setPosition(s.width*0.85, s.height*0.8)
        scene:addChild(loadingBar1);

        --UIButton及触摸事件
        local btn = ccui.Button:create("Images/sprites_test/sprite-0-2.png", "Images/sprites_test/sprite-1-2.png", "Images/sprites_test/sprite-0-2.png", 0)
        btn:setScale(4)
        btn:setPosition(s.width/6, s.height/7)
        btn:addTo(scene)
        local function touchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                Label1:setString("Touch Down")
            elseif eventType == ccui.TouchEventType.moved then
                Label1:setString("Touch Move")
            elseif eventType == ccui.TouchEventType.ended then
                Label1:setString("Touch Up")
            elseif eventType == ccui.TouchEventType.canceled then
                Label1:setString("Touch Cancelled")
            end
        end  
        btn:addTouchEventListener(touchEvent)  

        --定时器的使用,两种定时方式，第一种无法设定刷新时间间隔默认每帧刷新一次，推荐使用第二种
        local child = scene:getChildren()
        local canvas = child[2]
        local clock_bg_poker = canvas:getChildByName("clock_bg_poker")
        local timeText = clock_bg_poker:getChildByName("timeText")
        timeText:setTextColor(cc.c3b(255, 215, 0))

        local scheduler, myupdate
        local timer = 15
        local function update(dt)
            timer = timer - dt
            timeText:setString(timer)
            release_print("update: " .. timer) -- 输出log
            if timer <= 0 then                                  -- 倒计时结束后取消定时器
                -- self:unscheduleUpdate()                  -- 取消定时器
                scheduler:unscheduleScriptEntry(myupdate)   -- 取消定时器
            end
        end

        -- 每帧执行一次update,优先级为0
        -- self:scheduleUpdateWithPriorityLua(update, 0);

        -- 每秒执行一次update，会无限执行
        scheduler = cc.Director:getInstance():getScheduler()
        myupdate = scheduler:scheduleScriptFunc(update, 1, false)--参数一：刷新函数；参数二：刷新时间间隔；参数三：是否只执行一次，false为无限循环。
        
        --返回按钮
        local backItem = cc.MenuItemImage:create(s_pPathB1,s_pPathB1)
        backItem:registerScriptTapHandler(function()
             cc.Director:getInstance():popScene()
        end)
        backItem:setPosition(VisibleRect:rightBottom())
        backMenu = cc.Menu:create()
        backMenu:setPosition(s.width/2, s.height/15)
        backMenu:addChild(backItem)
        scene:addChild(backMenu)
    end


    --menu
    -- cc.Director:getInstance():runWithScene('scene')--用于加载第一个场景
    local  item1 = cc.MenuItemFont:create( "游戏介绍")
    item1:registerScriptTapHandler(gameIntroScene)
    local  item2 = cc.MenuItemFont:create( "开始游戏")
    item2:registerScriptTapHandler(gameScene)
    local  item3 = cc.MenuItemFont:create( "退出游戏")
    item3:registerScriptTapHandler(function(tag, pSender)
        cc.Director:getInstance():popScene()
    end)
    local  menu = cc.Menu:create(item1, item2, item3)
    menu:alignItemsVertically()
    ret:addChild(menu)
    --给节点绑定脚本组建
    -- local widgetComponent = cc.ComponentLua:create("app/DowneyTang/SceneTest.lua");
    -- checkBox:addComponent(widgetComponent)

    return ret
end

local function main()
    local scene = cc.Scene:create()

    scene:addChild(scene1())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main