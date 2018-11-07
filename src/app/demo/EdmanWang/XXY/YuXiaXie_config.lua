-- @Author: EdmanWang
-- @Date:   2018-10-26 10:21:14
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-26 13:28:25
--[[-
    抽出相关的区域项作为配置
-]]

--[[-
  local one_left = ccui.Button:create("yuxiaxie/images/1.png");
  local size = one_left:getContentSize();
  one_left:setOpacity(1);
  one_left:setPosition(TARGET_POINT_X,TARGET_POINT_Y);
  one_left:addClickEventListener(function ( ... )
       local number_x ,number_y = self:createRandomNumber();
       local sprite = cc.Sprite:create(self.path);
       sprite:setPosition(135,-12);
       sprite:setScale(0.5);
       sprite:addTo(xiaZhuSprite);
       sprite:runAction(cc.MoveTo:create(1,cc.p(TARGET_POINT_X+number_x,TARGET_POINT_Y+number_y)))
    end)

    local four_left = ccui.Button:create("yuxiaxie/images/2.png");
    four_left:setOpacity(1);
    four_left:setPosition(tar_x ,tar_y);
    local small_size = four_left:getContentSize();
    four_left:addClickEventListener(function ( ... )
       local number_x , number_y = self:createRandomNumber();
       local sprite = cc.Sprite:create(self.path);
       sprite:setScale(0.5);
       sprite:setPosition(135,-12);
       sprite:addTo(xiaZhuSprite);
       sprite:runAction(cc.MoveTo:create(1,cc.p(tar_x+number_x,tar_y+number_y)))
    end)

      local tar_x = 48;
     local tar_y = 148;
-]]

local YuXiaXie_config = {}

YuXiaXie_config.imagePaths = {
    -- 这里可以自定义添加你想要图片
	image = "yuxiaxie/images/1.png";  
  image_two = "yuxiaxie/images/2.png";
}

YuXiaXie_config.area = {
    fly_start_position  = cc.p(135,-12);
    -- 确定开始的第一个区域坐标 (根据实际情况去定位置坐标)
    ["one"] = {
        count = 6,
        gap = 2,
        TARGET_POINT_X = 73,
        TARGET_POINT_Y = 416,
    },
    ["two"] = {
       count = 6,
       tar_x= 48,
       tar_y = 148,
       gap = 2,
    },
    ["three"] = {
       count = 2,
       tar_x= 4,
       tar_y = 120,
       gap = 2,
    },
    ["four"] = {
       count = 4,
       tar_x= 48,
       tar_y = 18,
       gap = 2,
    },
    ["five"] = {
       count = 3,
       tar_x= 35,
       tar_y = 148,
       gap = 2,
    }
}

return YuXiaXie_config;