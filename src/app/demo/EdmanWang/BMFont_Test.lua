-- @Author: EdmanWang
-- @Date:   2018-10-16 20:59:37
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-17 18:45:10

--[[-
    static LabelBMFont * create(const std::string& str,  -- 显示的文本
                                const std::string& fntFile,  -- 文本的fnt文件
                                -- coscos-lua中没有集成LabelBMFont以下的属性
                                float width = 0, 
                                TextHAlignment alignment = TextHAlignment::LEFT,
                                const Vec2& imageOffset = Vec2::ZERO);

-]]
local function BMFont_create()
	local scene = display.newScene("BMFont");
	local labelBMFont = cc.LabelBMFont:create("35a",s_helvetica);
	labelBMFont:setPosition(100,100);
    labelBMFont:addTo(scene);
    return scene;
end 

function main(  )
    local scene = BMFont_create();
     scene:addChild(CreateBackMenuItem());
	return scene
end

return main;