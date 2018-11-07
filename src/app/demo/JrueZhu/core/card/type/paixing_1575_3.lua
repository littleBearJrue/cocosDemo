--[[--ldoc desc
@module paixing_1575_3
@author SeryZeng

Date   2018-03-16 11:49:33
Last Modified by   SeryZeng
Last Modified time 2018-03-20 18:09:41
]]

local TongZhangDaiPai = import ("..base.TongZhangDaiPai")
local M = class(TongZhangDaiPai)

M.description = [[
四带1,四带2,四带3
4张牌点相同的的牌+任意1,2,3张其它牌
]]

function M:ctor(data, ruleDao)
	TongZhangDaiPai.init(self,{4,self.args[1]})
end

return M; 