--[[--ldoc desc
@module paixing_1572_2
@author SeryZeng

Date   2018-01-16 20:36:09
Last Modified by   AmyGuo
Last Modified time 2018-05-31 19:52:14
]]

local LineBase = import("..base.LineBase")
local M = class(LineBase)

M.description = [[
	飞机
	二个及以上点数相邻的三张牌
]]


function M:ctor(data,ruleDao)
	local patternConfig = {
		sameCount = 3,
		minLength = data.typeRule.args[1],
		lineArgs = data.typeRule.args[2],
	}
	LineBase.init(self,patternConfig)
end

function M:getNewLineArgs(valueName)
	local str = patternConfig.lineArgs
	local rStr = ""
	local rTable = {}
	for w in string.gmatch(str, "(%w+)") do
		local symbol = w==valueName and "/" or "-"
		if w == valueName then
			rTable[#rTable] = "/"
		else
			rTable[#rTable+1] = w
			rTable[#rTable+1] = "-"
	 	end
	end
	rTable[#rTable] = ""
	for i,v in ipairs(rTable) do
		rStr = rStr..v
	end
	return rStr
end

function M:refresh(ruleDao)
	local mainValue = ruleDao:getMainValue()
	local valueName = Card.ValueMap:getValueByKey(mainValue)
	local args = {}
	args.sameCount	= patternConfig.sameCount
	args.minLength	= patternConfig.minLength
	args.lineArgs 	= self:getNewLineArgs(valueName)
    LineBase.init(self, args)
end

return M;