-- @Author: EdmanWang
-- @Date:   2018-10-23 11:31:06
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-25 17:12:55
--[[-
    要求: 显示不同筹码，默认选中最小筹码，可选中其他筹码
         点击下注界面，筹码能飞到对应下注区域中即可
         头像等其他元素忽略。
-]]

--[[-
   思路：1：页面布局显示
         1.1：下注界面
         1.2：筹码界面
        2：划分每一个区域
           每一个区域对应的回调函数
        3：动画
-]]
local YuXiaXieView = class("YuXiaXieView",cc.load("boyaa").mvc.BoyaaView);

-- 构造函数，初始化相关数据，并实现页面布局的加载
function YuXiaXieView:ctor( ... )
    self.chipView = nil ;
	local layer =  self:createLayer();
	layer:addTo(self);
	return self;
end
local function touchBegan(touch ,event)
    local chipTexture = cc.SpriteBatchNode:create("Images/chip/dice_chip.png"):getTexture()
    local WIDTH_SIZE = 28;
    local HEIGHT_SIZE = 28;
    local TARGET_WIDTH = 80;
    local TARGET_HEIGHT = 52;
    local gap = 2;
    local TARGET_THREE_CENTER = cc.p(196,178);
    local node = event:getCurrentTarget();
    local locationInNode = touch:getLocation();
    dump(locationInNode, "hhhhh")
    local size = node:getContentSize();
    local rect_one = cc.rect(120,1,WIDTH_SIZE,HEIGHT_SIZE);
    local rect_two = cc.rect(158,1,WIDTH_SIZE,HEIGHT_SIZE);
    local rect_three = cc.rect(196,1,WIDTH_SIZE,HEIGHT_SIZE);
    local rect_four = cc.rect(234,1,WIDTH_SIZE,HEIGHT_SIZE);
    local rect_five = cc.rect(272,1,WIDTH_SIZE,HEIGHT_SIZE);

    local target_one_left = cc.rect(160,264,TARGET_WIDTH,TARGET_HEIGHT);
    local target_one_right = cc.rect(160 + TARGET_WIDTH + gap,264,TARGET_WIDTH,TARGET_HEIGHT);

    local target_two_left = cc.rect(160,264 - TARGET_HEIGHT - gap ,TARGET_WIDTH,TARGET_HEIGHT);
    local target_two_right = cc.rect(160 + TARGET_WIDTH + gap ,264 - TARGET_HEIGHT - gap,TARGET_WIDTH,TARGET_HEIGHT);

    local target_three_left = cc.rect(160,264 -2*TARGET_HEIGHT - gap,TARGET_WIDTH,TARGET_HEIGHT);
    local target_three_right = cc.rect(159 + TARGET_WIDTH,153,TARGET_WIDTH,TARGET_HEIGHT);
    
    -- local random = math.random(10)
    -- local endPosition;
    if cc.rectContainsPoint(target_three_left,locationInNode) then
        local endPosition = TARGET_THREE_CENTER
        local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 2, 31, 31))
        fly_chip:setScale(0.5);
        -- 首先判断属于哪个区域，得到区域以后，得到中心点。位置在随即上下左右一下
        fly_chip:setPosition(-110,1)
        fly_chip:addTo(node);
        -- local endPosition = TARGET_THREE_CENTER
        fly_chip:runAction(cc.MoveTo:create(2,cc.p(-36,158)));
        return true;
    end

    if cc.rectContainsPoint(target_three_right,locationInNode) then
        local endPosition = TARGET_THREE_CENTER
        local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 2, 31, 31))
        fly_chip:setScale(0.5);
        -- 首先判断属于哪个区域，得到区域以后，得到中心点。位置在随即上下左右一下
        fly_chip:setPosition(-110,1)
        fly_chip:addTo(node);
        -- local endPosition = TARGET_THREE_CENTER
        fly_chip:runAction(cc.MoveTo:create(2,cc.p(38,158)));
        return true;
    end

    if cc.rectContainsPoint(target_two_left,locationInNode) then
        local endPosition = TARGET_THREE_CENTER
        local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 2, 31, 31))
        fly_chip:setScale(0.5);
        -- 首先判断属于哪个区域，得到区域以后，得到中心点。位置在随即上下左右一下
        fly_chip:setPosition(-110,1)
        fly_chip:addTo(node);
        -- local endPosition = TARGET_THREE_CENTER
        fly_chip:runAction(cc.MoveTo:create(2,cc.p(-36,158+TARGET_HEIGHT)));
        return true;
    end

    if cc.rectContainsPoint(target_two_right,locationInNode) then
        local endPosition = TARGET_THREE_CENTER
        local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 2, 31, 31))
        fly_chip:setScale(0.5);
        -- 首先判断属于哪个区域，得到区域以后，得到中心点。位置在随即上下左右一下
        fly_chip:setPosition(-110,1)
        fly_chip:addTo(node);
        -- local endPosition = TARGET_THREE_CENTER
        fly_chip:runAction(cc.MoveTo:create(2,cc.p(38,158+TARGET_HEIGHT)));
        return true;
    end

    if cc.rectContainsPoint(target_three_right,locationInNode) then
        local endPosition = TARGET_THREE_CENTER
        local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 2, 31, 31))
        fly_chip:setScale(0.5);
        -- 首先判断属于哪个区域，得到区域以后，得到中心点。位置在随即上下左右一下
        fly_chip:setPosition(-110,1)
        fly_chip:addTo(node);
        -- local endPosition = TARGET_THREE_CENTER
        fly_chip:runAction(cc.MoveTo:create(2,cc.p(38,158)));
        return true;
    end

    -- local fly_chip ;
    -- if cc.rectContainsPoint(rect_one,locationInNode) then
    --     fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 2, 31, 31))
    --     fly_chip:setScale(0.8);
    --     -- 首先判断属于哪个区域，得到区域以后，得到中心点。位置在随即上下左右一下
    --     fly_chip:setPosition(-110,1)
    --     fly_chip:addTo(node);
    --     local endPosition;
    --     if cc.rectContainsPoint(target_three_left,locationInNode) then
    --          endPosition = TARGET_THREE_CENTER;
    --          fly_chip:runAction(cc.MoveTo:create(2,endPosition));
    --     end    
    --     -- local endPosition = cc.p(68,150);
    --     return true;
    -- end
    -- if cc.rectContainsPoint(rect_two,locationInNode) then
    --     local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 0, 31, 31))
    --     fly_chip:setScale(0.8);
    --     fly_chip:setPosition(-72,1)
    --     fly_chip:addTo(node);
    --     local endPosition = cc.p(40,130);
    --     fly_chip:runAction(cc.MoveTo:create(2,endPosition));
    --     return true;
    -- end
    -- if cc.rectContainsPoint(rect_three,locationInNode) then
    --     local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (3 - 1), 6 + 42 * 1, 31, 31))
    --     fly_chip:setScale(0.8);
    --     fly_chip:setPosition(-34,1)
    --     fly_chip:addTo(node);
    --     local endPosition = cc.p(70,100);
    --     fly_chip:runAction(cc.MoveTo:create(2,endPosition));
    --     return true;
    -- end
    -- if cc.rectContainsPoint(rect_four,locationInNode) then
    --     local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (2 - 1), 6 + 42 * 0, 31, 31))
    --     fly_chip:setScale(0.8);
    --     fly_chip:setPosition(4,1)
    --     fly_chip:addTo(node);
    --     local endPosition = cc.p(30,140);
    --     fly_chip:runAction(cc.MoveTo:create(2,endPosition));
    --     return true;
    -- end
    -- if cc.rectContainsPoint(rect_five,locationInNode) then
    --     local fly_chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (2 - 1), 6 + 42 * 2, 31, 31))
    --     fly_chip:setScale(0.8);
    --     fly_chip:setPosition(42,1)
    --     fly_chip:addTo(node);
    --     local endPosition = cc.p(50,120);
    --     fly_chip:runAction(cc.MoveTo:create(2,endPosition));
    --     return true;
    -- end
end 

local function touchMoved( touch ,event )

    local node = event:getCurrentTarget();
    local locationInNode = touch:getLocation();
    print(".......touchMoved.......",locationInNode);
    dump(locationInNode, "hhhhh");
end

local function touchEnded( touch ,event )
    print("touchEnded---",event)
end

function YuXiaXieView:createLayer()
	local layer = cc.Layer:create();
    local gap = 2;
    local TARGET_POINT_Y =  416;
    local TARGET_POINT_X = 73;
	-- 加载背景
    local imageView = ccui.ImageView:create("yuxiaxie/images/room_bg.jpg");
    imageView:setPosition(display.width/2,display.height/2);
    imageView:setScale(0.9);
    layer:addChild(imageView);
	-- 加载下注界面
	local imageViewSize = imageView:getContentSize();
    local xiaZhuSprite = cc.Sprite:create("yuxiaxie/images/koprok_dice_bet.png");
    -- print("jjjjjjjjjjjjjjjjjjjjjj----",xiaZhuSprite:getContentSize().width,xiaZhuSprite:getContentSize().height)
    xiaZhuSprite:setPosition(imageViewSize.width/2,imageViewSize.height/2+22);
    xiaZhuSprite:setScale(0.7,0.68)
    -- xiaZhuSprite:setScale(0.5,0.5)
    xiaZhuSprite:addTo(imageView);

    local target_one_left = cc.Sprite:create("yuxiaxie/images/1.png");
    local target_one_right_size = target_one_left:getContentSize();
    target_one_left:setOpacity(110);
    target_one_left:setPosition(TARGET_POINT_X,TARGET_POINT_Y);
 
    local target_one_right = cc.Sprite:create("yuxiaxie/images/1.png");
    target_one_right:setOpacity(110);
    target_one_right:setPosition(TARGET_POINT_X + target_one_right_size.width + gap,TARGET_POINT_Y);

    local target_two_left = cc.Sprite:create("yuxiaxie/images/1.png");
    target_two_left:setOpacity(110);
    target_two_left:setPosition(TARGET_POINT_X ,TARGET_POINT_Y - target_one_right_size.height - gap);

    local target_two_right = cc.Sprite:create("yuxiaxie/images/1.png");
    target_two_right:setOpacity(110);
    target_two_right:setPosition(TARGET_POINT_X + target_one_right_size.width + gap ,TARGET_POINT_Y - target_one_right_size.height - gap);

    local target_three_left = cc.Sprite:create("yuxiaxie/images/1.png");
    target_three_left:setOpacity(110);
    target_three_left:setPosition(TARGET_POINT_X ,TARGET_POINT_Y - 2 * target_one_right_size.height -2*gap);

    local target_three_right = cc.Sprite:create("yuxiaxie/images/1.png");
    target_three_right:setOpacity(110);
    target_three_right:setPosition(TARGET_POINT_X + target_one_right_size.width + gap ,TARGET_POINT_Y - 2 * target_one_right_size.height -2* gap);


    target_one_left:addTo(xiaZhuSprite);
    target_one_right:addTo(xiaZhuSprite);

    target_two_left:addTo(xiaZhuSprite);
    target_two_right:addTo(xiaZhuSprite);

    target_three_left:addTo(xiaZhuSprite);
    target_three_right:addTo(xiaZhuSprite);
    local ChipCtr = import("app.EdmanWang.yuxiaxie.chip.ChipCtr").new();
    self.chipView = ChipCtr:getView();
    self.chipView:setPosition(imageViewSize.width/2-231,imageViewSize.height/2-175);
    self.chipView:addTo(imageView);
    
    



    local node = cc.Node:create();
    node:setPosition(display.width/2,imageViewSize.height/2-160);
    
    local listener_one = cc.EventListenerTouchOneByOne:create();
    listener_one:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN);
    listener_one:registerScriptHandler(touchMoved,cc.Handler.EVENT_TOUCH_MOVED);
    listener_one:registerScriptHandler(touchEnded,cc.Handler.EVENT_TOUCH_ENDED);

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener_one, node);
    
    node:addTo(layer)
	return layer;
end

return YuXiaXieView;