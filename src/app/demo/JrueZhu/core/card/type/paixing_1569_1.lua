--[[--ldoc desc
@module paixing_1569_1
@author LisaChen

Date   2018-01-09 19:35:02
Last Modified by   LisaChen
Last Modified time 2018-06-28 18:41:06
]]
local LineBase2 = import("..base.LineBase2")
local M = class(LineBase2)

M.description = [[
	paixing_1569_1: 2对及以上两张牌点花色都相同的牌，只要牌点大小相邻能压，就能相连
]]

function M:ctor(data,ruleDao)
	local minLength = data.typeRule.args[1];
    local args = {sameCount = 2,minLength = minLength or 2};
    LineBase2.init(self,args)
end

return M