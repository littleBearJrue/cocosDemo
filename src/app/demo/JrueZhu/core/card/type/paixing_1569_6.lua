--[[--ldoc desc
@module paixing_1569_6
@author name

Date   2018-02-27 18:05:16
Last Modified by   LucasZhen
Last Modified time 2018-04-03 17:47:44
]]


local LineBase = import("..base.LineBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
牌型：双顺
特征：3个及以上相连的对子， 连牌顺序【4-5-6-7-8-9-10-J-Q-K-A】不区分花色
例如：(33 44 55)、(77 88 99 1010 JJ QQ)
范围：4-5-6-7-8-9-10-J-Q-K-A

]]

function M:ctor(data)
    local args = {}
    args.sameCount = 2
    args.minLength = data.typeRule.args[1]
    args.lineArgs = data.typeRule.args[2]
    LineBase.init(self, args)
end

M.bindingData = {
    set = {}, 
    get = {}, 
}

return M; 