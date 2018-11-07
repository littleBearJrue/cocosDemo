--[[--ldoc desc
@module paixing_1573_2
@author SeryZeng

Date   2018-03-16 11:48:23
Last Modified by   SeryZeng
Last Modified time 2018-03-21 14:40:43
]]

local ZuPaiDaiPai = import ("..base.ZuPaiDaiPai")
local M = class(ZuPaiDaiPai)

M.description = [[
	飞机带翅膀2,飞机带翅膀1
	3张牌点相同的牌算一组牌，2组牌起连 连牌顺序【3-4-5-6-7-8-9-10-J-Q-K-A】不区分花色 每组牌可带 1 张单牌
]]

function M:ctor(data, ruleDao)
	local args = {
		sameCount = 3,
		minLength = self.args[1],
		lineArgs = self.args[2],
		carryCount = self.args[3]
	}
	ZuPaiDaiPai.init(self,args)
end

return M; 