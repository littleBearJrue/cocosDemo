local LineBase3 = import("..base.LineBase3")
local M = class(LineBase3)

M.description = [[
功能描述说明：
	4张以上的连张
	maxSameCount 最大同张张数,12
	minSameCount 最小同张张数,4
	minLength 	 最小点数连续长度
]]
local patternConfig = {
	lineArgs 		= "3-4-5-6-7-8-9-10-J-Q-K-A"
}

function M:ctor(data,ruleDao)
	patternConfig.maxSameCount	= data.typeRule.args[3]
	patternConfig.minSameCount	= data.typeRule.args[2]
	patternConfig.minLength 	= data.typeRule.args[1]
	LineBase3.init(self,patternConfig,ruleDao)
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
	args.maxSameCount	= patternConfig.maxSameCount
	args.minSameCount	= patternConfig.minSameCount
	args.minLength		= patternConfig.minLength
	args.lineArgs 		= self:getNewLineArgs(valueName)
    LineBase3.init(self,args,ruleDao)
end

return M;
