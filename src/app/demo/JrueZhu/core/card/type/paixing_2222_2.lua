--[[--ldoc desc
@module paixing_2222_2
@author CelineJiang

Date   2018-04-28 20:28:01
Last Modified by   VincentZhang
Last Modified time 2018-09-07 14:13:39
]]
local CardBase = import("..base.CardBase")
local M = class(CardBase)
-----贵州通用升级特殊的甩牌规则

--[[
功能描述说明：
	牌型：甩牌
	特征：由同花色顶大的单牌、对子、连对组合构成,组合的方式只能是以下四种：1、多张单牌2、一张单牌和一个对子3、一张单牌和一个连对4、多个连对
	其他补充：	需要保证每个单独牌型（单牌、对子、连对）
				都是当前所有人的手牌中最大，否则强制出比别人小的牌型，如果两种以上牌型比别人小，则只保留牌点数最小的组合。 第二
				家主牌压副牌的甩牌时，需全部组合牌型相同，则压制者大与首出者，否者首出者大，第三家主牌甩牌与第二家主牌甩牌进行比
				较时，若组合牌型相同，则按照连对>对子>单牌的优先级进行比较，只比较一组牌型，该牌型大则该甩牌大。


    
  
-- ]]
------甩牌牌型必须配优先级参数
----在牌型里面去拿拆牌优先级

function M:getSubTypeList( ... )
	if not self.m_typeList then
		self.m_typeList = {};
		for i,v in ipairs(string.split(self.args[3], ">")) do
			self.m_typeList[i] = CardUtils.getCardRuleByName(self.ruleDao, v);
		end
	end
	return self.m_typeList;
end

local patternCheckFuncMap = {
	[1] = "isSameCombine", 		---组合方式1：任意多组的【拖拉机/单牌】可以甩 
	[2] = "isDiffCombine",		---组合方式2：只有一组【单牌+对子,单牌+拖拉机】
}

----获取保牌数据
function M:getReserveCards(ruleDao,cardStack)
	local allCardRule = g_ParseUtils.getCardRuleByNameSplit(ruleDao, self.args[3], ">")
	local priority = {}
	for i=1,#allCardRule do
		table.insert(priority, allCardRule[i])
	end
	local reserveCards = CardUtils.getReserveCards(ruleDao,cardStack, priority)
	return reserveCards
end

----第一种组合的判断>>>>组合方式1：任意多组的【拖拉机/单牌】可以甩
function M:isSameCombine(ruleDao,reserveCards,cardList,args)
	Log.v(" M:isSameCombine(ruleDao,reserveCards,cardList,args)",cardList,args,reserveCards)
	local allCardAll = g_ParseUtils.getCardRuleByNameSplit(ruleDao, args, "/")
	for _, v in ipairs(allCardAll) do
		local find = reserveCards[v.uniqueId]
		local len = 0
		for _, v in ipairs(find) do
			len = #v.cardList + len
		end
		if #find > 1 and len == #cardList then
			return true
		end
	end
	return false
end 

---第二种组合的判断>>>组合方式2：只有一组【单牌+对子,单牌+拖拉机】
function M:isDiffCombine(ruleDao,reserveCards,cardList,args)
	if not args or #args == 0 then
		return false
	end
	for _, typeArr in ipairs(string.split(args,",")) do
		local allCardAll = g_ParseUtils.getCardRuleByNameSplit(ruleDao, typeArr, "+")
		local num = 0
		local len = 0
		for _, v in ipairs(allCardAll) do
			local find = reserveCards[v.uniqueId]
			if #find ~= 1 then
				break
			end
			len = #find[1].cardList + len
		end
		if len == #cardList then
			return true
		end
	end
	return false
end

---是否为甩牌规定的组合
function M:isTheRightPatternCombine(data,ruleDao)
	local reserveCards = self:getReserveCards(ruleDao,data.outCardInfo.cardStack)
	for i = 1, #self.args-1 do
		if self[patternCheckFuncMap[i]](self,ruleDao,reserveCards,data.outCardInfo.cardList,self.args[i]) then
			return true
		end
	end
	return false
end


--[[
data = {outCardInfo = {
	cardList = ,
	cardStack = ,
	cardColor = ,
	opData = ,
	opCode = ,
}}
]]

function M:check(data)
	local ruleDao = data.ruleDao;
	local cardList = data.outCardInfo.cardList
	if #cardList < 2 then
		return false
	end 
	if not data.outCardInfo.cardStack then
		----超时的时候，传过来的data里面没有cardStack
		data.outCardInfo.cardStack = new(CardStack, {cards = data.outCardInfo.cardList})
	end
    
    ----判断是否为同花色
	local markColor = CardUtils.getCardLogicColor(ruleDao, cardList[1]);
	for i=2,#cardList do
		local color = CardUtils.getCardLogicColor(ruleDao, cardList[i]);
		if color ~= markColor then
			return false;
		end
	end
	--是否为正确的牌型组合 
	Log.v("M:check",data.outCardInfo.cardStack)
	if not self:isTheRightPatternCombine(data,ruleDao) then
		return false
	end
	return true;
end

function M:find( ... )
	-- body
end

return M;
