-- @Author: XiongmeiLai
-- @Date:   2018-04-23 16:15:07
-- @Last Modified by:   XiongmeiLai
-- @Last Modified time: 2018-04-23 16:18:26
--[[--ldoc desc
@module paixing_1567_4
]]

local TongZhangNotAllLaizi = import("..base.TongZhangNotAllLaizi")
local CardBase = import("..base.CardBase")
local M = class(TongZhangNotAllLaizi)

-- 牌型：对子
-- 特征：牌点相同的两张牌，不区分花色

function M:ctor(data,ruleDao)
	local args = {2,2,1}
	TongZhangNotAllLaizi.init(self,args)
end

return M;	