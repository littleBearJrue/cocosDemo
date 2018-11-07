-- @Author: EdmanWang
-- @Date:   2018-10-25 13:56:14
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-29 19:06:28
local ChipView = class("YuXiaXieView",cc.load("boyaa").mvc.BoyaaView);
local chip_Node = cc.Node:create();
function ChipView:ctor(value, type)
    print("ChipView:ctor")
    self.oneCount = 0;
    self.twoCount = 0;
    self.threeCount = 0;
    self.fourCount = 0;
    self.chipTexture = cc.SpriteBatchNode:create("Images/chip/dice_chip.png"):getTexture();
    self:createLayer();
end

-- 回调函数
function ChipView:initView()
	local layer = cc.Layer:create();
end

function ChipView:one_callback(sender)
	print("ChipView:one_callback");
    self.oneCount = self.oneCount + 1;
    local chip_data = {number = 1,count = self.oneCount};
    self.ctr:dispatcherEvent(chip_data);
end

function ChipView:two_callback( sender )
     local chip_data = {number = 2};
	 self.ctr:dispatcherEvent(chip_data);
end

function ChipView:three_callback( sender )
	local chip_data = {number = 3};
    self.ctr:dispatcherEvent(chip_data);
end

function ChipView:four_callback( sender )
	local chip_data = {number = 4};
    self.ctr:dispatcherEvent(chip_data);
end

function ChipView:createLayer()
	-- local layer = cc.Layer:create();
 --    layer:setAnchorPoint(0.5,0.5);
	local one_normalSprite = cc.Sprite:create("yuxiaxie/images/one.png");
	one_normalSprite:setScale(0.8)
	local one_selectSprite1 = cc.Sprite:create("yuxiaxie/images/chip_btn_light.png");

	local one_MenuItem = cc.MenuItemSprite:create(one_normalSprite,one_selectSprite1);
    one_MenuItem:registerScriptTapHandler(handler(self, self.one_callback));
  
    local two_normalSprite = cc.Sprite:create("yuxiaxie/images/two.png");
    two_normalSprite:setScale(0.8)
	local two_selectSprite1 = cc.Sprite:create("yuxiaxie/images/chip_btn_light.png");

	local two_MenuItem = cc.MenuItemSprite:create(two_normalSprite,two_selectSprite1);
    two_MenuItem:registerScriptTapHandler(handler(self, self.two_callback));

    local three_normalSprite = cc.Sprite:create("yuxiaxie/images/three.png");
    three_normalSprite:setScale(0.8)
	local three_selectSprite1 = cc.Sprite:create("yuxiaxie/images/chip_btn_light.png");

	local three_MenuItem = cc.MenuItemSprite:create(three_normalSprite,three_selectSprite1);
    three_MenuItem:registerScriptTapHandler(handler(self, self.three_callback));

    local four_normalSprite = cc.Sprite:create("yuxiaxie/images/four.png");
    four_normalSprite:setScale(0.8)
	local four_selectSprite1 = cc.Sprite:create("yuxiaxie/images/chip_btn_light.png");

	local four_MenuItem = cc.MenuItemSprite:create(four_normalSprite,four_selectSprite1);
    four_MenuItem:registerScriptTapHandler(handler(self, self.four_callback));

    local mn = cc.Menu:create(one_MenuItem,two_MenuItem,three_MenuItem,four_MenuItem);
    mn:alignItemsHorizontallyWithPadding(30);

    self:addChild(mn);
end

return  ChipView;