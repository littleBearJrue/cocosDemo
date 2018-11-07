-- @Author: EdmanWang
-- @Date:   2018-10-16 18:11:49
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-22 10:48:41
local function label_create( ... )
	local size = cc.Director:getInstance():getWinSize();
	--[[-
	   label的三种创建方式
          1：使用系统的字体
          2：使用TTF格式
          3：使用BMFont格式 ：需要一个xxx.png 和 xxx.fnt 两个文件，放在统一的目录下，并规范命名
	-]]
   local gap = 50;
   local layer = cc.Layer:create();
   -- 系统文字  Arial 为系统字体
   local systemLabel = cc.Label:createWithSystemFont("HelloWrold","Arial",36);
   systemLabel:setPosition(cc.p(size.width/2,size.height-gap));
   layer:addChild(systemLabel,1,1);

   -- 使用TTF格式的创建 需要记载一个xxx.ttf文件
   local TTFLabel = cc.Label:createWithTTF("帅哥您好","fonts/STLITI.ttf",36)
   TTFLabel:setPosition(cc.p(size.width/2,size.height-2*gap));
   layer:addChild(TTFLabel, 1, 2);

   local ttfConfig = {};
   ttfConfig.fontFilePath = "fonts/Marker Felt.ttf";  -- 加载xxx.tt的文件路径
   ttfConfig.fontSize = 32;   --设置文字大小
   local TTFLabelWithConfig = cc.Label:createWithTTF(ttfConfig,"HelloWrold");
   TTFLabelWithConfig:setPosition(cc.p(size.width/2,size.height-3*gap));
   layer:addChild(TTFLabelWithConfig, 1, 3);

   ttfConfig.outlineSize = 4;
   local TTFLabelWithConfig1 = cc.Label:createWithTTF(ttfConfig,"HelloWrold1");
   TTFLabelWithConfig1:setPosition(cc.p(size.width/2,size.height-4*gap));
   TTFLabelWithConfig1:setColor(cc.c3b(255, 0, 0));
   TTFLabelWithConfig1:enableShadow(cc.c4b(255, 255, 255, 128), cc.size(4,-4));
   layer:addChild(TTFLabelWithConfig1, 1, 4);

   -- 使用BMFont创建label字体
   --[[-
       准备：需要体格xxx.fnt和xxx.png两个文件
   -]]
   local BMFontLabelOne = cc.Label:createWithBMFont("fonts/bitmapFontChinese.fnt","中国");
   BMFontLabelOne:setPosition(cc.p(size.width/2,size.height - 5*gap));
   layer:addChild(BMFontLabelOne, 1, 5);

   local BMFontLabelTwo = cc.Label:createWithBMFont("fonts/BMFont.fnt","HelloWrold");
   BMFontLabelTwo:setPosition(cc.p(size.width/2,size.height - 6*gap));
   layer:addChild(BMFontLabelTwo, 1, 6);

   -- 使用labelAtlas 创建label labelAtlas 使用图集，书速度比TTF速度更快
   -- local labelAtlas = cc.LabelAtlas:create("fonts/tuffy_bold_italic-charmap.png","Hello World");
   -- labelAtlas:setPosition(cc.p(size.width/2,size.height - 7*gap));
   -- layer:addChild(labelAtlas, 1);
   return layer;
end

function main( ... )
	local scene = cc.Scene:create();
	local layer = label_create();
	scene:addChild(layer);
	scene:addChild(CreateBackMenuItem());
	return scene;
end

return main;