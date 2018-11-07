-- @Author: KevinZhang
-- @Date:   2017-11-14 20:59:20
-- @Last Modified by   KevinZhang
-- @Last Modified time 2018-01-22 12:03:36

local LineBase = import("..base.LineBase")
local M = class(LineBase)

function M:ctor(data)
	local args = {}
	args.sameCount = 1
	args.minLength = 5
	args.lineArgs = "3-4-5-6-7-8-9-10-J-Q-K-A"
	LineBase.init(self,args)
end

M.description = [[
功能描述说明：
	牌型：顺子/单龙
	特征：至少由5组牌点相邻的牌组成，每组都由1张牌组成，对花色无要求
 	例如：(3 4 5 6 7)、(6 7 8 9 10)
 	范围：3-4-5-...-Q-K-A

]]

M.bindingData = {
	set = {},
	get = {},
}

return M;