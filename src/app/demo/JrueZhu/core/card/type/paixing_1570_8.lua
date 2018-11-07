-- @Author: KevinZhang
-- @Date:   2017-11-14 20:59:20
-- @Last Modified by   LucasZhen
-- @Last Modified time 2018-07-03 16:39:49

local LineBase = import("..base.LineBase")
local M = class(LineBase)

function M:ctor(data)
	local typeArgs = data.typeRule.args
	local args = {}
	args.sameCount = 1
	args.minLength = typeArgs[1]
	args.lineArgs = typeArgs[2]
	LineBase.init(self,args)
end

M.description = [[
功能描述说明：
	牌型：顺子/单龙
	特征：$1张相连的单牌 连牌顺序【$2】不区分花色，，只能单向连牌，不能循环连牌，同牌点的牌不能用2次
 	例如：(3 4 5)、(6 7 8 9 10)
 	范围：3-4-5-...-Q-K-A

]]



function M:check(data)
	if #data.outCardInfo.cardList ~= self.minNum then
		return false
	end
	return self.super.check(self,data)
end

function M:find(data)
	local newData = clone(data)
	if not newData.targetCardInfo or not newData.targetCardInfo.cardList then
		newData.targetCardInfo = {}
		newData.targetCardInfo.cardList = {}
		for i =1,self.minNum do 
			table.insert(newData.targetCardInfo.cardList,Card.new(0x03))
		end
	else 
		if #newData.targetCardInfo.cardList ~= self.minNum then 
			return
		end
	end

	return self.super.find(self,newData)
end



M.bindingData = {
	set = {},
	get = {},
}

return M;