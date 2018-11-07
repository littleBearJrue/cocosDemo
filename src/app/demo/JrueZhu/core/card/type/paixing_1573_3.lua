--[[--ldoc desc
@module paixing_1573_3
@author SeryZeng

Date   2018-03-16 11:48:23
Last Modified by   CottonNie
Last Modified time 2018-08-28 15:37:45
]]

local ZuPaiDaiPai = import ("..base.ZuPaiDaiPai");
local M = class(ZuPaiDaiPai);

M.description = [[
	飞机带翅膀2
	3张牌点相同的牌算一组牌，【2】组牌起连
    连牌顺序【3-4-5-6-7-8-9-10-J-Q-K-A】不区分花色，只能单向连牌，不能循环连牌，同牌点的牌不能用2次
    每组牌可带【1】个对子
]]

function M:ctor(data, ruleDao)
	local args = {
		sameCount = 3,
		minLength = self.args[1],
		lineArgs = self.args[2],
		carryCount = self.args[3] * 2,
	};
	ZuPaiDaiPai.init(self,args);
end

-- function M:check(data)
--     self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao});
--     -- 长度判断
--     local size = #data.outCardInfo.cardList;
--     if not (size > 0 and (size / self.offset) >= self._args.minLength and (size % self.offset) == 0) then
--         return false;
--     end

--     -- 找主牌型
--     local findData = {};
--     findData.ruleDao = data.ruleDao;
--     findData.srcCardStack = new(CardStack,{cards = data.outCardInfo.cardList});
--     local mainCards = self:_findRightMainType(self.mainType, findData);
--     if mainCards then
--         findData.srcCardStack:removeCards(mainCards.cardList);
--         local subCardsNum = findData.srcCardStack:getNumber();
--         if not ((#mainCards.cardList / self._args.sameCount) >= self._args.minLength and 
--             subCardsNum == (#mainCards.cardList / self._args.sameCount) * self._args.carryCount) then
--             return false;
--         end

--         local numberValueMap = findData.srcCardStack:getNumberValueMap();
--         for k, v in pairs(numberValueMap) do
--         	if k ~= 2 then
--         		return false;
--         	end
--         end

--         data.outCardInfo.size = self.sortRule.args;
--         data.outCardInfo.byteToSize = self.byteToSize;
--         data.outCardInfo.cardByte = mainCards.cardList[1].byte;
--         data.outCardInfo.groupLenght = #mainCards.cardList / self._args.sameCount;
--         return true;
--     end
-- end

-- function M:find(data)
--     local tmpData = clone(data);
--     self:sort({cardInfo = {cardList = tmpData.srcCardStack:getCardList(true)}, ruleDao = tmpData.ruleDao});
--     -- 从压牌里面找主牌型
--     local targetCardInfo = tmpData.targetCardInfo;
--     if targetCardInfo then
--         local targetCardData = {
--             ruleDao = tmpData.ruleDao,
--             srcCardStack = new(CardStack,{cards = targetCardInfo.cardList}),
--         };
--         local targetmainInfo = self:_findRightMainType(self.mainType, targetCardData);
--         if targetmainInfo then
--             tmpData.targetCardInfo = targetmainInfo;
--         end 
--     end 

--     local mainCards = self:_findRightMainType(self.mainType, tmpData);
--     if mainCards then
--         tmpData.srcCardStack:removeCards(mainCards.cardList);
--         local subCards = tmpData.srcCardStack:getCardList();
--         -- 排序
--         self:sort({cardInfo = {cardList = subCards}, ruleDao = tmpData.ruleDao});

--         local subCardList = {};
--         local mainCardsNum = #mainCards.cardList;
--         local mainCardsStack = new(CardStack, {cards = mainCards.cardList});
--         local subCardsStack = new(CardStack, {cards = subCards});
--         local numberValueMap = subCardsStack:getNumberValueMap();
--         local maxIdx = 0;
--         for k, _ in pairs(numberValueMap) do
--             if k > maxIdx then
--                 maxIdx = k;
--             end
--         end
--         for i = 2, maxIdx do
--             if numberValueMap[i] then
--                 for k, targetVal in ipairs(numberValueMap[i]) do
--                     if mainCardsStack:getNumberByValue(targetVal) == 0 then
--                         local targetIdx = self:findIdxInCardListByValue(subCards, targetVal);
--                         for j = 1, 2 do
--                             table.insert(subCardList, table.remove(subCards, targetIdx));
--                         end

--                         if #subCardList == self._args.carryCount * (mainCardsNum / self._args.sameCount) then
--                             break;
--                         end
--                     end
--                 end

--                 if #subCardList == self._args.carryCount * (mainCardsNum / self._args.sameCount) then
--                     break;
--                 end
--             end
--         end

--         if #subCardList ~= self._args.carryCount * (mainCardsNum / self._args.sameCount) then
--             return;
--         end 

--         -- 保持从大到小排序
--         for i = #subCardList, 1, -1 do
--             table.insert(mainCards.cardList,subCardList[i]);
--         end

--         return {cardList = mainCards.cardList, cardByte = mainCards.cardList[1].byte, cardType = self.uniqueId};
--     end
-- end

-- function M:findIdxInCardListByValue(cards, value)
--     local idx;

--     for i = 1, #cards do
--         if cards[i].value == value then
--             idx = i;
--             break;
--         end
--     end

--     return idx;
-- end

return M; 