-- @Author: KevinZhang
-- @Date:   2017-11-14 21:02:00
-- @Last Modified by   KevinZhang
-- @Last Modified time 2018-01-22 11:25:16

local TongZhang = import("..base.TongZhang")
local CardBase = import("..base.CardBase")
local M = class(TongZhang)


M.description = [[
功能描述说明：
	牌型：三条(三同张)，（梅花3，方块3，黑桃3）
	特征：牌点相同的三张牌，不区分花色
	
]]

M.bindingData = {
	set = {},
	get = {},
}
function M:ctor(data,ruleDao)
	local args = {3,3}
	TongZhang.init(self,args)
end

return M;