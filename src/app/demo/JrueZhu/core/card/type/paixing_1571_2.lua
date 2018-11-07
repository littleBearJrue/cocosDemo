--[[--ldoc desc
@module paixing_1571_2
@author SeryZeng

Date   2018-03-16 11:45:10
Last Modified by   SeryZeng
Last Modified time 2018-03-20 15:32:33
]]


local TongZhangDaiPai = import ("..base.TongZhangDaiPai")
local M = class(TongZhangDaiPai)

M.description = [[
三带二
3张牌点相同的牌+任意2张其它牌
]]

function M:ctor(data, ruleDao)
	TongZhangDaiPai.init(self,{3,2})
end

return M; 