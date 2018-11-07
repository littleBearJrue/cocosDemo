-- @Author: EdmanWang
-- @Date:   2018-10-19 16:47:41
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-23 14:10:30

function main()
	local scene = cc.Scene:create();
	-- 默认创建一张牌
	local CardView = import("app.EdmanWang.CardView_Test").new(0x3d);
	-- 通过属性值去修改牌
	-- 性能测试
	-- for i=0,3 do
	-- 	CardView.color = i;
	-- 	for j=1,10 do
	-- 		CardView.value = j;
	-- 	end
	-- end
    CardView.color = 1;
	-- CardView.value = 10;
	CardView:addTo(scene);
	return scene;
end

return main;