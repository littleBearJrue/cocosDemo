-- @Author: EdmanWang
-- @Date:   2018-10-23 11:59:26
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-24 15:12:54
-- YuXiaXie_Test
function main( ... )
	local scene = cc.Scene:create();

	local YuXiaXieCtr = import("app.EdmanWang.yuxiaxie.YuXiaXieCtr").new();
    local YuXiaXieView = YuXiaXieCtr:getView()
    YuXiaXieView:addTo(scene);
	return scene;
end

return main;