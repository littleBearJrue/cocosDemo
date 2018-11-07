local LineBase = import("..base.LineBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
	牌型：顺子
	特征：6张牌成顺，范围3-A，且级牌不能连
 	例如：(3 4 5 6 7)、(8 9 10)
 	范围：3-4-5-...-Q-K-A
]]

local patternConfig = {
	sameCount = 1,
	minLength = 6,
	lineArgs  = "3-4-5-6-7-8-9-10-J-Q-K-A",
}

function M:ctor(data,ruleDao)
	patternConfig.minLength = data.typeRule.args[1]
    LineBase.init(self, patternConfig)
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
