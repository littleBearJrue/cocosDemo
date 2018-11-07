--[[--ldoc desc
@module paixing_2222_1
@author WahidZhang

Date   2018-01-09 19:35:02
Last Modified by   VincentZhang
Last Modified time 2018-05-28 15:32:42
]]

local CardBase = import("..base.CardBase")
local M = class(CardBase)

--[[
	功能描述说明：
 	牌型：甩牌
 	特征：由同花色顶大的单牌、对子、姐妹对、超级姐妹对任意组合构成(此牌型中，所有的主牌算主花色)
 	其他补充：	需要保证每个单独牌型（单牌、对子、姊妹对、超级姊妹对）
 				都是当前所有人的手牌中最大，否则强制出比别人小的牌型，如果两种以上牌型比别人小，则只保留牌点数最小的组合。 第二
 				家主牌压副牌的甩牌时，需全部组合牌型相同，则压制者大与首出者，否者首出者大，第三家主牌甩牌与第二家主牌甩牌进行比
 				较时，若组合牌型相同，则按照超级姊妹对>姊妹对>对子>单牌的优先级进行比较，只比较一组牌型，该牌型大则该甩牌大。
]]  


--[[
	甩牌牌型必须配优先级参数
	在牌型里面去拿拆牌优先级
]]


function M:getSubTypeList( ... )
	if not self.m_typeList then
		self.m_typeList = g_ParseUtils.getCardRuleByNameSplit(self.ruleDao, self.args[1], ">")
	end
	return self.m_typeList;
end

function M:check(data)
	local ruleDao = data.ruleDao;
	local cardList = data.outCardInfo.cardList
	if #cardList <= 1 then
		return false
	end
	local markColor = CardUtils.getCardLogicColor(ruleDao, cardList[1]);
	for i=2,#cardList do
		local color = CardUtils.getCardLogicColor(ruleDao, cardList[i]);
		if color ~= markColor then
			return false;
		end
	end
	local allCardRule = g_ParseUtils.getCardRuleByNameSplit(ruleDao, self.args[1], ">")
	for _,cardRule in ipairs(allCardRule) do
		if cardRule:check(data) then
			return false
		end
	end
	return true;
end

function M:find( ... )
	-- body
end

return M;