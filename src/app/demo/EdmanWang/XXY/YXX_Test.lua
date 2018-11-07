-- @Author: EdmanWang
-- @Date:   2018-10-23 11:59:26
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-29 18:31:59
-- YuXiaXie_Test
local function main()
	local scene = cc.Scene:create();
	local YuXiaXieCtr = require("app.demo.EdmanWang.XXY.YuXiaXieCtr").new();
	YuXiaXieCtr:initView();
    local YuXiaXieView = YuXiaXieCtr:getView()
    YuXiaXieView:addTo(scene);
	return scene;
end

return main;