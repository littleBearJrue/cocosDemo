-- @Author: EdmanWang
-- @Date:   2018-10-23 16:51:15
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-25 11:51:37
local ChipView = class("YuXiaXieView",cc.load("boyaa").mvc.BoyaaView);
local chip_Node = cc.Node:create();
function ChipView:ctor(value, type)
    print("ChipView:ctor")
    local layerout = self:createChip();
    layerout:addTo(self);
    return self;
end

--[[
    @function initView      初始化View
    @param #value int       筹码的值
    @param #type int        筹码的类型 大：0 小 1
]] 
function ChipView:initView(value, type)
	self._data = {
        value = value or 1,
        type = type or 0,
	}
    local chipTexture = cc.SpriteBatchNode:create("Images/chip/dice_chip.png"):getTexture()
    if self._data.type == 1 then
        self.chip = self:getSmallChip(chipTexture, self._data.value)
    else
        self.chip = self:getBigChip(chipTexture, self._data.value)
    end
    -- self:addChild(self.chip)
    return self.chip;
end

local function onTouchBegan(touch ,event)
    print("touchInTarget----began>>>>>>>>");
    local node = event:getCurrentTarget();
    local locationInNode = node:convertToNodeSpace(touch:getLocation());
    local size = node:getContentSize();
    local rect = cc.rect(0,0,size.width,size.height);
    if cc.rectContainsPoint(rect,locationInNode) then
        -- print("sprite x = %d,y = %d",locationInNode.x,locationInNode.y);
        local node_bg  = cc.Sprite:create("yuxiaxie/images/chip_btn_light.png");
        -- local node_bg1  = cc.Sprite:create("yuxiaxie/images/chip_btn_light.png");
        node_bg:setPosition(size.width/2,size.height/2);
        
        node_bg:addTo(node);
        -- node_bg1:runAction(cc.MoveTo(2, 200, 200));
        return true;
    end
end 

local function touchMoved( touch ,event )
    print(".......touchMoved.......")
end

local function touchEnded( touch ,event )
    print("touchEnded---edned",event)
    chip_Node:removeAllChildren();
    ChipView:createChip();
end

function ChipView:createChip(  )
    -- 创建layout,内容添加到layout
    self.chip_one = self:initView(1,0); -- 是一个sprite
    self.chip_one:setTag(2);
    -- chip_one:setTag(1);
    self.chip_two = self:initView(2,0); -- 是一个sprite
    -- chip_two:setTag(2);
    self.chip_three = self:initView(3,0); -- 是一个sprite
    self.chip_four = self:initView(4,0); -- 是一个sprite
    self.chip_five = self:initView(5,0); -- 是一个sprite

    self.double_node = cc.Sprite:create("yuxiaxie/images/dice_room_double_btn.png");
    self.repeat_node = cc.Sprite:create("yuxiaxie/images/dice_room_repeat_en_US.png");

    chip_Node:setPosition(display.width/2 - 169,13);
    local gap = 42;
    -- self.chip_one:addTo(chip_Node);
    chip_Node:addChild(self.chip_one, 1, 1);
    self.chip_one:setPosition(1 * gap,5)

    self.chip_two:addTo(chip_Node);
    self.chip_two:setPosition(2 * gap,5)

    self.chip_three:addTo(chip_Node);
    self.chip_three:setPosition(3 * gap,5)

    self.chip_four:addTo(chip_Node);
    self.chip_four:setPosition( 4 * gap,5)

    self.chip_five:addTo(chip_Node);
    self.chip_five:setPosition( 5 * gap,5)

    self.double_node:addTo(chip_Node);
    self.double_node:setPosition( 6 * gap,5)

    self.repeat_node:addTo(chip_Node);
    self.repeat_node:setPosition(chip_Node:getContentSize().width + 7 * gap,5)

    -- print("jjjjjjjjjjjjjj",chip_Node:getContentSize().width,chip_Node:getContentSize().height)

    local listener_one = cc.EventListenerTouchOneByOne:create();
    listener_one:setSwallowTouches(true);
    listener_one:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN);
    listener_one:registerScriptHandler(touchMoved,cc.Handler.EVENT_TOUCH_MOVED);
    listener_one:registerScriptHandler(touchEnded,cc.Handler.EVENT_TOUCH_ENDED);

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
 
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener_one, self.chip_one);
    local listener_two = listener_one:clone();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener_two, self.chip_two);

    local listener_three = listener_two:clone();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener_three, self.chip_three);

    local listener_four = listener_three:clone();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener_four, self.chip_four);

    local listener_five = listener_four:clone();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener_five, self.chip_five);
    return chip_Node;
end



function ChipView:getBigChip(chipTexture, value)
    local map = {
        [1] = 9, [2] = 3, [3] = 6, [4] = 2, [5] =  8, [6] = 7, [7] = 5, [8] = 4,
    }
    local l = math.modf( map[value] / 3 )
    local m = math.fmod( map[value] , 3 )
    print("hhhhhhhhhhhhhhiii",l,m);
    if m == 0 then
        m = 3
        l = l - 1
    end
    local chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (m - 1), 6 + 42 * l, 31, 31))
    return chip
end

function ChipView:getSmallChip(chipTexture, value)
    local map = {
        [1] = 5, [2] = 1, [3] = 6, [4] = 2, [5] =  7, [6] = 3, [7] = 8, [8] = 4,
    }
    local l = math.modf( map[value] / 2 )
    local m = math.fmod( map[value] , 2 )
    if m == 0 then
        m = 2
        l = l - 1
    end
    local chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(128 + 17 * (m - 1), 44 + 17 * l, 14, 14))
    return chip
end

return ChipView