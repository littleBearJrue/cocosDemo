-- @Author: EdmanWang
-- @Date:   2018-10-25 14:41:29
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-30 12:26:14
local YuXiaXieView = class("YuXiaXieView",cc.load("boyaa").mvc.BoyaaView);
local YuXiaXie_config = require("app.EdmanWang.XXY.YuXiaXie_config");
function YuXiaXieView:ctor( ... )
    self.Sprite = nil;
    self.chipView = nil ;
    self.path = "yuxiaxie/images/one.png";
    self.areaPosition = YuXiaXie_config.area;
    self.imagePaths = YuXiaXie_config.imagePaths;
    self.chipTexture = cc.SpriteBatchNode:create("Images/chip/dice_chip.png"):getTexture();
    self:initView();
end

function YuXiaXieView:initView()
    local layer =  self:createLayer();
	layer:addTo(self);
	return self;
end	

function YuXiaXieView:createSprite(params)
    if  params and params.number == 1 then
       print("点击的次数",params.count)
      self.path = "yuxiaxie/images/one.png"
    end
    if  params and params.number == 2 then
      self.path = "yuxiaxie/images/two.png"
    end
    if  params and params.number == 3 then
      self.path = "yuxiaxie/images/three.png"
    end
    if  params and params.number == 4 then
      self.path = "yuxiaxie/images/four.png"
    end
end
function YuXiaXieView:createRandomNumber()
      math.newrandomseed()
      local number_x = math.random(110);
      if number_x >= 25 then
        number_x = math.random(15)  + 1
      end
      if number_x <= 8 then
        number_x = math.random(5)  + 1
      end
      local number_y = math.random(60) ;
      if number_y >= 20 then
        number_y = math.random(15)  + 1
      end 
      if number_y <= 12 then
        number_y = math.random(5)  + 1
      end
      return number_x,number_y
end

function YuXiaXieView:createLayer()
	local layer = cc.Layer:create();
	-- 加载背景
  local imageView = ccui.ImageView:create("yuxiaxie/images/room_bg.jpg");
  imageView:setPosition(display.width/2,display.height/2);
  imageView:setAnchorPoint(0.5,0.5);
  layer:addChild(imageView);
	-- 加载下注界面
	local imageViewSize = imageView:getContentSize();
  self.xiaZhuSprite = cc.Sprite:create("yuxiaxie/images/koprok_dice_bet.png");
  self.xiaZhuSprite:setPosition(display.width/2,display.height/2);
  self.xiaZhuSprite:setScale(0.7,0.68)
  self.xiaZhuSprite:addTo(imageView);

  local ChipCtr = require("app.demo.EdmanWang.XXY.chip.ChipCtr").new();
  ChipCtr:initView();
  self.chipView = ChipCtr:getView();
  -- 不能使用硬编码
  self.chipView:setAnchorPoint(0.5,0.5);
  print("这一点的节点坐标是",self.chipView:getPosition():convertToWorldSpace(nodePoint));
  self.chipView:addTo(imageView);
  self:createAreaSprite_one();
  self:createAreaSprite_two();
  return layer;
end
function YuXiaXieView:createAreaSprite_one()  --self.areaPosition["one"].count
  local x = self.areaPosition["one"].TARGET_POINT_X;
  local y = self.areaPosition["one"].TARGET_POINT_Y;
  local gap = self.areaPosition["one"].gap;
    for i=1, 6 do
     local btn = ccui.Button:create(self.imagePaths.image);
     local size = btn:getContentSize();
     btn:addTo(self.xiaZhuSprite);
     btn:setOpacity(1);
      if i % 2 == 1 then
         btn:setPosition(x,y-size.height*(i-1)/2 - (i-1)/2* gap);
      else
         btn:setPosition(x + size.width +gap,y - size.height * (i-2)/2 -(i-2)/2 * gap);
      end
     btn:addClickEventListener(function ( ... )
       local number_x ,number_y = self:createRandomNumber();
       local sprite = cc.Sprite:create(self.path);
       sprite:setPosition(self.areaPosition.fly_start_position);
       sprite:setScale(0.5);
       sprite:addTo(self.xiaZhuSprite);
       if i %2  ==1 then
          sprite:runAction(cc.MoveTo:create(1,cc.p(x + number_x , y-size.height*(i-1)/2 + number_y)));
       else
          sprite:runAction(cc.MoveTo:create(1,cc.p(x + size.width + number_x , y- size.height *(i-2)/2 + number_y)));
       end
      end)
    end
end

function YuXiaXieView:createAreaSprite_two()  
  local x = self.areaPosition["two"].tar_x;
  local y = self.areaPosition["two"].tar_y;
  local gap = self.areaPosition["two"].gap;
    for i=1, 6  do
     local btn = ccui.Button:create(self.imagePaths.image_two);
     local size = btn:getContentSize();
     btn:addTo(self.xiaZhuSprite);
     btn:setOpacity(1);
      if i <= 3 then
         btn:setPosition(x + size.width * (i-1) + gap *(i-1),y);
      else
         btn:setPosition(x + size.width *(i-4) +gap * (i-4)  , y - size.height - gap);
      end
     btn:addClickEventListener(function ( ... )
       local number_x ,number_y = self:createRandomNumber();
       local sprite = cc.Sprite:create(self.path);
       sprite:setPosition(self.areaPosition.fly_start_position);
       sprite:setScale(0.5);
       sprite:addTo(self.xiaZhuSprite);
       if i <= 3 then
          sprite:runAction(cc.MoveTo:create(0.5,cc.p(x + size.width * (i-1) + gap *(i-1) + number_x , y + number_y)));
       else
          sprite:runAction(cc.MoveTo:create(0.5,cc.p(x + size.width *(i-4) +gap * (i-4) + number_x , y - size.height- gap + number_y)));
       end
      end)
    end
end
return YuXiaXieView;