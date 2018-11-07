-- @Author: KevinZhang
-- @Date:   2017-11-14 20:47:22
-- @Last Modified by   CottonNie
-- @Last Modified time 2018-07-16 15:41:40

local CardBase = import("..base.CardBase")
local M = class(CardBase)


M.description = [[
功能描述说明：
	纯五十K：由一张5，一张10，一张K组成的牌型，并且花色一样
	花色指：黑、红、梅、方四种花色
]]


function M:ctor(data, ruleDao)
	local sortRule = {};
    sortRule.args = {'K>10>5'};
    sortRule.id = 'PDK_paidiandaxiao_1579_1';
	self.sortRule = {sortRule};
	self.minNum = 3;
	-- self.fiveTenKValues = {5, 10, 13};
	self.fiveTenKValues = {13, 10, 5};
end

M.bindingData = {
	set = {},
	get = {},
}

function M:check(data)
	--出牌检验和最后一手牌校验，分别走这里的时候，排序可能相反，导致其中一种校验失败
	self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao});
	local outCardList = data.outCardInfo.cardList;

	if #outCardList ~= self.minNum then return false; end

	local cardColor;
	--牌值符合，颜色相同--出牌检验和最后一手牌校验，分别走这里的时候，排序可能相反，导致其中一种校验失败
	table.sort(outCardList, function(a, b)
		return a.value > b.value;
	end);
	for k, card in ipairs(outCardList) do
		if self.fiveTenKValues[k] ~= card.value then
			return false;
		end
		if cardColor and card.color ~= cardColor then
			return false;
		end
		cardColor = card.color;
	end

	data.outCardInfo.size = self.sortRule.args;
	data.outCardInfo.byteToSize = self.byteToSize;
	data.outCardInfo.cardByte = outCardList[1].byte;
	return true;
end

-- 还有其他用不上的数据也传过来，未列出
function M:compare(data)
	--纯五十K相互之间不能压牌
	return false;
end

---查找符合牌型的手牌，以及移除掉手牌后剩下的牌
--data.cardInfo    {cardStack, cardList, size, byteToSize}
function M:find(data)
	if data.targetCardInfo and data.targetCardInfo.cardType == self.uniqueId then return; end

	local sortData = {cardInfo = {}, ruleDao = data.ruleDao};
	sortData.cardInfo.cardList = data.srcCardStack:getCardList();
	self:sort(sortData); --当前手牌排序

	local handCardList = {};
	table.copyTo(handCardList, sortData.cardInfo.cardList);

	local fiveList = {}; --保存手牌中的所有5牌值的牌
	local tenList = {}; --保存手牌中的所有10牌值的牌
	local kList = {}; --保存手牌中的所有k牌值的牌
	local fiveTenKList = {
		[1] = fiveList,
		[2] = tenList,
		[3] = kList,
	};
	for _, card in ipairs(handCardList) do
		if card.value == 5 then
			table.insert(fiveList, card);
		elseif card.value == 10 then
			table.insert(tenList, card);
		elseif card.value == 13 then
			table.insert(kList, card);
		end
	end

	if #fiveList == 0 or #tenList == 0 or #kList == 0 then return; end --三张牌中缺其一，直接返回空

	table.sort(fiveTenKList, function(a, b)
		return #a < #b;
	end); --{{10, 10}, {5, 5, 5}, {13, 13, 13, 13}}
	
	local result, cards = self:findFitCards(fiveTenKList);

	if not result then return; end --没有符合条件的牌型，返回空

	--从手牌中删除找到的牌

	return {cardList = cards, cardByte = cards[1].byte, cardType = self.uniqueId};
end

--传入{{10, 10}, {5, 5, 5}, {13, 13, 13, 13}}
function M:findFitCards(sourceList)
	local copyTbl = {}; --防止原表元素的变动
	table.copyTo(copyTbl, sourceList);
	local curColor, curIndex, isColorChanged = nil, 1, false; --当前需要寻找的牌值和花色
	local pickedCards = {}; --符合条件的牌
	local fitCards = {};

	local function addToPickedCards(card)
		for _, v in ipairs(pickedCards) do
			if v.value == card.value then
				return false;
			end
		end

		table.insert(pickedCards, card);
		return true;
	end

	local function removeFromPickedCards()
		table.remove(pickedCards, #pickedCards);
	end

	local function pickCard()
		if curIndex > 3 then
			fitCards = pickedCards;
			return;
		end

		--只有前后牌花色相同才会提出牌，出现不同花色的话curIndex不可能大于3。
		for _, card in ipairs(copyTbl[curIndex]) do
			isColorChanged = curColor and curColor ~= card.color or false;
			if not isColorChanged then
				if addToPickedCards(card) then
					curColor = card.color;
					curIndex = curIndex + 1;
					pickCard();
					if #fitCards >= 3 then break; end
					curIndex = curIndex - 1;
					removeFromPickedCards();
				end
			end
		end
	end

	pickCard();

	if #fitCards < 3 then return false; end

	table.sort(fitCards, function(a, b)
		return a.value > b.value;
	end);
	return true, fitCards;
end

return M;