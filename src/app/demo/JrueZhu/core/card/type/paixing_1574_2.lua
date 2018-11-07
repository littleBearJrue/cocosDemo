--[[--ldoc desc
@module paixing_1574_2
@author VincentZhang

Date   2018-08-28 11:32:50
Last Modified by   VincentZhang
Last Modified time 2018-09-05 10:58:02
]]
local TongZhang = import("..base.TongZhang")
local CardBase = import("..base.CardBase")
local M = class(TongZhang)

local ParseUtils = require(g_BasePath.."core.ParseUtils");

M.bindingData = {
	set = {},
	get = {},
}

M.description = [[
功能描述说明：
	名称：假杠
	牌型：两个参数的同张牌型，参数3决定几同张，参数1是附带的特殊的牌的张数,参数2是特殊牌
	特征：牌点相同的N张牌，不区分花色

	注意！！！牌张数必须 >= 2

	【1张黑桃Q】+任意【3张】牌点相同的的牌。
]]
function M:ctor(data,ruleDao)
	-- 初始化 3同章
    local args = table.copyTab(data.typeRule.args)
    Log.v("假杠牌型 初始化 ctor -------------- ",args)
    local mainArgs = {}
    mainArgs[1] = tonumber(args[3]);
    mainArgs[2] = tonumber(args[3]);
    self.mainType = new(TongZhang, data, ruleDao) --该牌型中的同张称为主牌型
    self.mainType:init(mainArgs)
    self.ruleDao = ruleDao
    self.specialCount = tonumber(args[1]) --特殊牌的张数
    local byte = Card.ByteMap:getKeyByValue(args[2]);
    self.specialCard = Card.new(byte);
    self.count = tonumber(args[3]) + tonumber(args[1]) --牌型总张数
end

function M:check(data)
	Log.v("假杠牌型 check --------------outCardInfo ",data.outCardInfo)
	-- 先调用排序方法
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao});
    -- 首先先判断Cards数组的大小
    local count = #data.outCardInfo.cardList;
    if count ~= self.count then
        return false;
    end

    for _,v in ipairs(data.outCardInfo.cardList) do
        if not self:isValidCard(v) then
            return false;
        end
    end

    --将牌分为两部分 特殊牌部分和同张部分
    local special = {};
    local same = {};
    local localCardStack = new (CardStack,{cards = data.outCardInfo.cardList});

    local special = table.selectall(localCardStack:getCardList(),function (i,v)
            return v.byte == self.specialCard.byte;
    end)

    if #special ==  self.specialCount then
        --有足够的特殊牌（如1张黑桃Q) 找同牌
        localCardStack:removeCards(special);
        local findData = {
            ruleDao = data.ruleDao,
            srcCardStack = new (CardStack,{cards = localCardStack:getCardList()}),
        }
        same = self.mainType:find(findData);
        if same and #same.cardList == #localCardStack:getCardList() then
            return true;
        else
            return false;
        end
    else
        return false
    end
end

--
function M:compare(data)
	-- 排序
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao})
    self:sort({cardInfo = data.targetCardInfo, ruleDao = data.ruleDao})
    -- 牌张数检测
    local outCardList = data.outCardInfo.cardList
    local targetCardList = data.targetCardInfo.cardList
    if #outCardList ~= #targetCardList then 
        return false
    end

    return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte]
end

function M:find(data)
	--阳泉三五反用牌只有一副 因此假杠只会有一组 不存在能相互压的情况 暂不考虑找能压的组合
	local queue = data.queue or 0; --0表示从大到小找
	--亮三五反后的牌 不能组成假杠 为无效的牌
	local validCardList, invalidCardList = self:getValidCard(data.srcCardStack:getCardList());
	local srcCardStack = new (CardStack,{cards = validCardList});
	local sortData = {cardInfo = {}, ruleDao = data.ruleDao};
	sortData.cardInfo.cardList = validCardList;
	self:sort(sortData);

	--找特殊牌
	local specialList = table.selectall(validCardList,function (i,v)
				return v.byte == self.specialCard.byte;
	end)
	if #specialList >= self.specialCount then
		specialList = #specialList == self.specialCount and specialList or table.selectall(specialList, function (i,v)
					return i <= self.specialCount;
		end)
	else
		Log.v("假杠牌型 find  没有足够的特殊牌 -----------")
		return --没有足够的特殊牌
	end
	srcCardStack:removeCards(specialList);
	Log.v("假杠牌型 find  special  -----------",specialList,srcCardStack)

	--找同张牌
	local findData = {
		ruleDao = data.ruleDao,
		srcCardStack = srcCardStack,
		queue = queue
	}	
	local sameList = self.mainType:find(findData) ;
	if sameList and #sameList.cardList > 0 then
		local cardList = table.merge2(sameList.cardList, specialList)
		return {cardList = cardList, cardByte = sameList.cardList[1].byte, cardType = self.uniqueId}
	else
		Log.v("假杠牌型 find 找不到同张 -------------- ")
		return
	end

end

return M;