local LineBase = import('.LineBase')
local CardBase = import('.CardBase')
local LineBase3 = class(CardBase)

function LineBase3:ctor(data, ruleDao)
	self.initData = data
end

------------初始化函数，初始化顺子序列,子类需自己调用完成初始化
function LineBase3:init(data, ruleDao)
	local function getSameCountList()
		local sameCountList = {}
		for i = data.minSameCount, data.maxSameCount do 
			table.insert(sameCountList,i)
		end
		return sameCountList
	end
	self.lineArgs			= data.lineArgs
	self.minLength 			= data.minLength
	self.sameCountList 		= getSameCountList()
	self.linePatterns 		= {}
	
	for i,sameCount in ipairs(self.sameCountList) do
		local args = {
			sameCount 	= sameCount,
			minLength 	= self.minLength,
			lineArgs 	= self.lineArgs,
		}
		local pattern = new(LineBase,self.initData,ruleDao)
		pattern:init(args)
		self.linePatterns[sameCount] = pattern
	end
end

function LineBase3:check(data)
	local checkData = {
		ruleDao		= data.ruleDao,
		outCardInfo = {
			cardList 	= data.outCardInfo.cardList,-- 好像没有发现对cardLis的添加删除，所以不copyTo了
		},
	}
	for i,sameCount in ipairs(self.sameCountList) do
		local pattern 	= self.linePatterns[sameCount]
		local result	= pattern:check(data)
		if result then
			return true,sameCount
		end
	end
	return false
end

function LineBase3:compare(data)
	local outData = {
		ruleDao		= data.ruleDao,
		outCardInfo = {
			cardList 	= data.outCardInfo.cardList,-- 好像没有发现对cardLis的添加删除，所以不copyTo了
			cardStack	= data.outCardInfo.cardStack or new(CardStack, {cards = data.outCardInfo.cardList}),
		},
	}
	local result,outSameCount = self:check(outData)
	if not result then
		return false
	end

	local targetData = {
		ruleDao		= data.ruleDao,
		outCardInfo = {
			cardList 	= data.targetCardInfo.cardList,-- 好像没有发现对cardLis的添加删除，所以不copyTo了
			cardStack	= data.targetCardInfo.cardStack or new(CardStack, {cards = data.targetCardInfo.cardList}),
		},
	}
	local result,targetSameCount = self:check(targetData)
	if not result then
		return false
	end

	return outSameCount==targetSameCount and self.linePatterns[outSameCount]:compare(data)
end

function LineBase3:find(data)
	if data.targetCardInfo and table.nums(data.targetCardInfo)~=0 then
		local targetData = {
			ruleDao		= data.ruleDao,
			outCardInfo = {
				cardList 	= data.targetCardInfo.cardList,-- 好像没有发现对cardLis的添加删除，所以不copyTo了
				cardStack	= data.targetCardInfo.cardStack or new(CardStack, {cards = data.targetCardInfo.cardList}),
			},
		}
		local result,targetSameCount = self:check(targetData)
		if result then
			local pattern 	= self.linePatterns[targetSameCount]
			local out 	= pattern:find(data)
			if out then
				return out
			end
			return
		end
	end

	local queue		= data.queue
	local startPos 	= queue~=1 and #self.sameCountList or 1
	local endPos 	= queue~=1 and 1 or #self.sameCountList
	local step		= queue~=1 and -1 or 1 
	for i = startPos,endPos,step do
		local sameCount = self.sameCountList[i]
		local pattern 	= self.linePatterns[sameCount]
		-- Log.v("LineBase3:find",data.srcCardInfo.cardList)
		local out 	= pattern:find(data)
		if out then
			return out
		end
	end
end

return LineBase3