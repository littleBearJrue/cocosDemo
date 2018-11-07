--[[--ldoc desc
@module paixing_2504_1
@author name

Date   2018-02-27 18:05:16
Last Modified by   LucasZhen
Last Modified time 2018-07-03 16:41:50
]]


local LineBase = import("..base.LineBase")
local M = class(LineBase)

M.description = [[
功能描述说明：
牌型：连炸
特征：$1组牌点相连，且每组相同牌点的牌有$2张 连牌顺序【$3】不区分花色，只能单向连牌，不能循环连牌，同牌点的牌不能用2次
例如：(3333 4444 5555)、(77 88 99 1010 JJ QQ)
范围：4-5-6-7-8-9-10-J-Q-K-A

]]

function M:ctor(data)
    local args = {}
    args.sameCount = data.typeRule.args[2]
    args.minLength = data.typeRule.args[1]
    args.lineArgs = data.typeRule.args[3]
    LineBase.init(self, args)
end

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