-- @Author: EdmanWang
-- @Date:   2018-10-19 09:29:14
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-19 10:49:22

local function create_node( ... ) 
   local node = cc.Node:create()
                :setPosition(300,100)
                :setAnchorPoint(0.5,0.5)
                :setColor(cc.c3b(255, 0, 0))
                :setVisible(true)
       
   return node;
end 

function main()
	local scene = cc.Scene:create();
	local  node = create_node();
	local sprite = cc.Sprite:create("HelloWorld.png");
    --[[-
        函数： 将精灵节点挂到node节点上去。
        参数：childNode --- 子节点
              Zorder --- 层级
              tagname --- tag值
    -]]
	node:addChild(sprite, 0, 1)
	-- 通过tag得到子节点
	local nodeOne =  node:getChildByTag(1);
    -- 删除childNode子节点
    -- node:removeChild(nodeOne, cleanup)
	print("wgx-----------------",nodeOne);

	--[[-
         cocos-lua中的node(节点) 调度器
         scheduleUpdateWithPriorityLua(handle ,priority)  -- 每一个node对象只要调用了这个函数，就会在定时再每一帧调用handle 函数
                                                          priority：表示优先级：priority 的值越小，就会越先执行 默认的优先级是0
         unscheduleUpdate() 停止对 scheduleUpdateWithPriority 的调度
	-]]
	node:scheduleUpdateWithPriorityLua(function ( ... )
		print("优先级1的调度")
	end,1)
	sprite:scheduleUpdateWithPriorityLua(function ( ... )
		print("优先级2的调度")
	end,2)
	-- node:unscheduleUpdate();
	sprite:unscheduleUpdate();
	node:addTo(scene);
	scene:addChild(CreateBackMenuItem())
	return scene;
end

return main;