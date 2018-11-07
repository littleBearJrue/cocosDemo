-- @Author: KevinZhang
-- @Date:   2017-11-14 20:58:55
-- @Last Modified by   KevinZhang
-- @Last Modified time 2018-01-22 11:23:31

local TongZhang = import("..base.TongZhang")
local CardBase = import("..base.CardBase")
local M = class(TongZhang)

-- 牌型：对子
-- 特征：牌点相同的两张牌，不区分花色

function M:ctor(data,ruleDao)
	local args = {2,2}
	TongZhang.init(self,args)
end

return M;