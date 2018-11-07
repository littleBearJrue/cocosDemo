--[[--ldoc desc
@module paixing_1569_3
@author name

Date   2018-02-27 18:05:16
Last Modified by   LucasZhen
Last Modified time 2018-03-19 16:11:46
]]


local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
牌型：双龙/连队/双顺
特征：至少有三组牌点相邻的牌，每组由两张牌点相同的牌，不区分花色
例如：(33 44 55)、(77 88 99 1010 JJ QQ)
范围：3-4-5-...-Q-K-A

]]

function M:ctor(data)
    local args = {}
    args.sameCount = 2
    args.minLength = 2
    args.lineArgs = "5-6-7-8-9-10-J-Q-K-A-2-3-4"
    LineBase.init(self, args)
end

M.bindingData = {
    set = {}, 
    get = {}, 
}

return M; 