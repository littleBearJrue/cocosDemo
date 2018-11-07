-- @Author: EdmanWang
-- @Date:   2018-10-24 19:10:06
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-25 11:33:24

--[[-
   鱼虾蟹的工具类
    1:用于计算不同区域的
-]]

local YXX_util = class("YXX_util", function ( ... )
	return cc.Scene:create();
end)

function YXX_util:ctor( ... )
	self.imageView = nil;
	self.imageViewSize = nil;
end

function YXX_util:initView()
	local layer = cc.Layer:create();
	-- 加载背景
    self.imageView = ccui.ImageView:create("yuxiaxie/images/room_bg.jpg");
    self.imageView:setPosition(display.width/2,display.height/2);
    self.imageView:setScale(0.9);
    layer:addChild(self.imageView);
	-- 加载下注界面
	-- self.imageViewSize = self.imageView:getContentSize();
    local imageSprite = cc.Sprite:create("yuxiaxie/images/koprok_dice_bet.png");
    imageSprite:setPosition(self.imageView:getContentSize().width/2,self.imageView:getContentSize().height/2+22);
    imageSprite:setScale(0.7,0.68)
    imageSprite:addTo(self.imageView);
    return layer;
end

function YXX_util:getOne_left(  )
end

return YXX_util;