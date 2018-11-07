-- @Author: EdmanWang
-- @Date:   2018-10-16 17:12:58
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-17 18:46:07

local function sprite_create ()
	--[[-
     总结sprite
         1:两种sprite的创建方式（quick中存在第三种（从缓存图像中创建sprite））
         2：sprite默认的锚点是（0.5，0.5） 注：锚点的概念很重要。
         3:display.newSprite 是cocso framework 中封装的创建sprite的方法，具体可以看源码 路径（cocos/framework）
	-]]
	-- 加载图片文件中创建一个sprite
	-- local sprite = display.newSprite(s_helloWorld); 
    local sprite = cc.Sprite:create(s_helloWorld);
    -- spriteFrame创建sprite

    return sprite


end

--[[-执行的主函数-]]
function main( ... )
    -- local sceneRoot = cc.Scene:create():addChild(sprite_create());
    local file = 'creator/wgx.ccreator'; -- res目录下需要加载的布局文件路径
    local creatorReader = creator.CreatorReader:createWithFilename(file);
    creatorReader:setup();

    local scene = creatorReader:getSceneGraph();
    -- sceneRoot:add(scene);
    local sprite = cc.Sprite:create(s_helloWorld);
    sprite:setPosition(200,200);
    scene:addChild(sprite, 1)
    -- scene:addTo(sceneRoot);
    -- sceneRoot:setPosition(100,100);
	scene:addChild(CreateBackMenuItem());
	return scene;
end

return main;

