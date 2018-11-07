--[[--ldoc desc
@module paixing_1570_4
@author name

Date   2018-02-27 18:01:40
Last Modified by   LucasZhen
Last Modified time 2018-03-20 17:37:09
]]


local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local M = class(LineBase)

function M:ctor(data)
    local args = {}
    args.sameCount = 1
    args.minLength = 3
    args.lineArgs = "5-6-7-8-9-10-J-Q-K-A/A-2-3-4"
    LineBase.init(self, args)
end

M.description = [[
功能描述说明：
牌型：顺子/单龙
特征：由3组牌点相邻的牌组成，每组都由1张牌组成，对花色无要求
 例如：(3 4 5)、(6 7 8 9 10)
 范围：3-4-5-...-Q-K-A

]]

M.bindingData = {
    set = {}, 
    get = {}, 
}

return M; 