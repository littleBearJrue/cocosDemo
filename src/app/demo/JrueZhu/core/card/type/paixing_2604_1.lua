--[[--ldoc desc
@module paixing_2604_1
@author name

Date   2018-02-27 18:05:16
Last Modified by   CottonNie
Last Modified time 2018-07-26 14:48:10
]]


local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
	牌型：同花
	特征：5张花色相同的牌型
]]

function M:ctor(data)
    self.minNum = data.typeRule.args[1];
end

M.bindingData = {
    set = {}, 
    get = {}, 
}

function M:check(data)
	self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao});
	local outCardList = data.outCardInfo.cardList;

	if #outCardList ~= self.minNum then return false; end

	local cardColor;
	for _, card in ipairs(outCardList) do
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

function M:compare(data)
    self:sort({cardInfo = data.outCardInfo, ruleDao = data.ruleDao});
    self:sort({cardInfo = data.targetCardInfo, ruleDao = data.ruleDao});

    local outCardList = data.outCardInfo.cardList;
    local targetCardList = data.targetCardInfo.cardList;

    if #outCardList ~= #targetCardList then return false; end

    return self.byteToSize[data.outCardInfo.cardByte] > self.byteToSize[data.targetCardInfo.cardByte];
end

function M:find(data)
	local sortData = {cardInfo = {}, ruleDao = data.ruleDao};
	sortData.cardInfo.cardList = data.srcCardStack:getCardList();
	self:sort(sortData);

	local handCardList = {};
	table.copyTo(handCardList, sortData.cardInfo.cardList);

	local cardListByColor = {
		[0] = {}, --方块
		[1] = {}, --梅花
		[2] = {}, --红桃
		[3] = {}, --黑桃
		[4] = {}, --大小王
	};
	for _, card in ipairs(handCardList) do
		table.insert(cardListByColor[card.color], card);
	end

	local targetCardByte = data.targetCardInfo and data.targetCardInfo.cardByte or nil;
	local result, cards = self:findFitCards(cardListByColor, targetCardByte);

	if not result then return; end --没有符合条件的牌型，返回空

	return {cardList = cards, cardByte = cards[1].byte, cardType = self.uniqueId};
end

function M:findFitCards(cardListByColor, targetCardByte)
	local copyTbl = {}; --防止原表元素的变动
	table.copyTo2(copyTbl, cardListByColor);
	local fitCards = {};
	if not targetCardByte then
		for _, cardList in pairs(copyTbl) do
			if #cardList >= self.minNum then
				for i = 1, self.minNum do
					table.insert(fitCards, cardList[i]);
				end
				break;
			end
		end
	else
		local startIdx;
		for _, cardList in pairs(copyTbl) do
			table.sort(cardList, function(a, b)
				return a.value < b.value;
			end);
			for i = self.minNum, #cardList do
				if self.byteToSize[cardList[i].byte] > self.byteToSize[targetCardByte] then
					startIdx = i;
					break;
				end
			end

			if startIdx then
				for i = startIdx, startIdx - self.minNum + 1, -1 do
					table.insert(fitCards, cardList[i]);
				end
				break;
			end
		end
	end

	-- Log.v("---->>>>iorinie fitCards", #fitCards); --test
	if #fitCards ~= self.minNum then return false; end

	table.sort(fitCards, function(a, b)
		return a.value > b.value;
	end);

	return true, fitCards;
end

return M; 