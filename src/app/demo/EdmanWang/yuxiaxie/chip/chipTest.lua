-- @Author: EdmanWang
-- @Date:   2018-10-24 10:11:18
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-24 10:13:56
function main()
	local scene = cc.Scene:create();
	-- 默认创建一张牌
	local ChipView = import("app.EdmanWang.yuxiaxie.chip.ChipView").new();
	-- 通过属性值去修改牌
	-- 性能测试
	-- for i=0,3 do
	-- 	CardView.color = i;
	-- 	for j=1,10 do
	-- 		CardView.value = j;
	-- 	end
	-- end
    -- CardView.color = 1;
	-- CardView.value = 10;
	ChipView:addTo(scene);
	return scene;
end

return main;