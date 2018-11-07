-- @Author: XiongmeiLai
-- @Date:   2018-04-23 16:19:56
-- @Last Modified by:   XiongmeiLai
-- @Last Modified time: 2018-04-23 16:23:27

local TongZhangNotAllLaizi = import("..base.TongZhangNotAllLaizi")
local CardBase = import("..base.CardBase")
local M = class(TongZhangNotAllLaizi)


M.bindingData = {
	set = {},
	get = {},
}

M.description = [[
功能描述说明：
	牌型：三个参数的同张牌型，args[1]=最短数量，args[2]=最长数量, args[3]=最少原生牌数量
	特征：牌点相同的N张牌，不区分花色

	注意！！！牌张数必须 >= 2
]]
function M:ctor(data,ruleDao)
	local args = table.copyTab(data.typeRule.args)
	TongZhangNotAllLaizi.init(self,args)
end

return M;