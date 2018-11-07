--[[--ldoc desc
@module paixing_1572_1
@author SeryZeng

Date   2018-01-16 20:36:09
Last Modified by   chenshanyi
Last Modified time 2018-03-08 10:57:27
]]

local LineBase = import("..base.LineBase")
local M = class(LineBase)

M.description = [[
	飞机
	二个及以上点数相邻的三张牌，2和王不可以连
]]
local patternConfig = {
	sameCount = 3,
	minLength = 2,
	lineArgs = "3-4-5-6-7-8-9-10-J-Q-K-A"
}

function M:ctor(data,ruleDao)
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