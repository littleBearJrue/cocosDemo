-- @Author: KevinZhang
-- @Date:   2017-11-14 21:02:00
-- @Last Modified by   KevinZhang
-- @Last Modified time 2018-02-27 11:12:51

local TongZhang = import("..base.TongZhang")
local CardBase = import("..base.CardBase")
local M = class(TongZhang)


M.bindingData = {
	set = {},
	get = {},
}

M.description = [[
功能描述说明：
	牌型：一个参数的同张牌型，根据参数决定是几同张
	特征：牌点相同的N张牌，不区分花色

	注意！！！牌张数必须 >= 2
]]
function M:ctor(data,ruleDao)
	local args = table.copyTab(data.typeRule.args)
	args[2] = args[1]
	TongZhang.init(self,args)
end

return M;
