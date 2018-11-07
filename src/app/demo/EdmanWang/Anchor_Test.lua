-- @Author: EdmanWang
-- @Date:   2018-10-16 18:16:58
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-17 18:44:41
--[[-
  锚点的测试:
          知识点：层Layer默认的锚点是（0,0）
-]]

local function anchor_test_01()
	 --创建一个scene
	local scene = display.newScene("anchor");
	-- 创建一个layer
	local red =  cc.LayerColor:create(cc.c4b(255, 100, 100, 128));
	-- 设置区域大小
    red:setContentSize(display.width/2,display.height/2);
    -- 创建一个layer
    local green =  cc.LayerColor:create(cc.c4b(100, 255, 100, 128));
    -- 设置区域大小
    green:setContentSize(display.width/4,display.height/4);
    red:addTo(scene);
    green:addTo(red);
    return scene ;
end 

local function anchor_test_02()
	 --创建一个scene
	local scene = display.newScene("anchor");
	-- 创建一个layer
	local red =  cc.LayerColor:create(cc.c4b(255, 100, 100, 128));
	-- 设置区域大小
    red:setContentSize(display.width/2,display.height/2);
    --设置位置
    red:setPosition(display.width/2,display.height/2);
    --[[-
        设置锚点
        计算公式：realPositionX = positionX + （0.5 - anchor.x）* Nodesize.x
                 realPositionY = positionY + （0.5 - anchor.y）* Nodesize.y
                 得到节点的中点坐标
    -]]
    red:setAnchorPoint(0.5,0.5);
    -- 接受对锚点的修改
    red:ignoreAnchorPointForPosition(false) -- 如果去掉这两句话会有什么样的效果，留给你了；哈哈
    -- 创建一个layer
    local green =  cc.LayerColor:create(cc.c4b(100, 255, 100, 128));
    -- 设置区域大小
    green:setContentSize(display.width/4,display.height/4);
    -- green:setPosition(display.width/4,display.height/4);  -- 测试加上这句话的变化你会发现上面的计算公式是对的
    green:ignoreAnchorPointForPosition(false)  --如果去掉这两句话会有什么样的效果，留给你了；哈哈
    green:setAnchorPoint(1,1);
    red:addTo(scene);
    green:addTo(red);
    return scene ;
end 


function anchor()
	-- 测试anchor_test_01
	-- return anchor_test_01();
    local scene = anchor_test_01();
    local scene = anchor_test_02();
    scene:addChild(CreateBackMenuItem())
	return scene;
end

return anchor;