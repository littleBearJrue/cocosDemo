--[[--ldoc desc
@module paixing_1570_5
@author OjorsOu

Date   2018-04-26 12:05:55
Last Modified by   KevinZhang
Last Modified time 2018-05-16 18:15:25
]]

local LineBase = import("..base.LineBase")
local CardBase = import("..base.CardBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
	牌型：顺子/单龙
	特征：$1张及以上相连的单牌，连牌顺序【$2】不区分花色
 	例如：3 4 5 6
 	范围：3-4-5-...-Q-K-A
]]

function M:ctor(data)
    local typeArgs = data.typeRule.args
	local args = {}
	args.sameCount = 1
	args.minLength = tonumber(typeArgs[1])
    args.lineArgs = typeArgs[2]
	LineBase.init(self, args)
end

M.bindingData = {
	set = {},
	get = {},
}

return M;