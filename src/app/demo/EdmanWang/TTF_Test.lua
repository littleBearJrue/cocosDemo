-- @Author: EdmanWang
-- @Date:   2018-10-16 19:50:39
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-17 18:47:36
--[[-测试TTFLabel-]]

--[[-
    总结：display 中常用的几个new
         1:newScene
         2:newLayer
         3:newSpriteFrame
         4:newFrames
         5:newAnimation
         6:newNode
         7:newSprite
-]]

--[[-
  LabelTTF* LabelTTF::create(const std::string& string,   -- 需要展示的文字
                             const std::string& fontName, -- 展示文字的字体
                             float fontSize,              --展示文字的大小
                             -- 下面的三个属性在lua语言中设置无效，待解决 预计出现的问题是在bindingLua的问题
                             const Size &dimensions, 
                             TextHAlignment hAlignment, 
                             TextVAlignment vAlignment)
-]]
local function create_TTFLabel( ... )
	local scene = display.newScene();
	local label = cc.LabelTTF:create("wgx", "Arial", 40);
	label:setPosition(100,100);
	label:addTo(scene);
    -- cc.Label:creaeWithTTF()
	return scene;
end 

function main()
    local scene =  create_TTFLabel();
    scene:addChild(CreateBackMenuItem())
	return scene;
end

return main;