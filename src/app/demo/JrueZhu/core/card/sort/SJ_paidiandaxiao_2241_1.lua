--[[--ldoc desc
@module paidiandaxiao_2241_1
@author WahidZhang

Date   2018-03-15 14:59:44
Last Modified by   WahidZhang
Last Modified time 2018-03-22 17:30:48
]]

--[[
	牌点排序
	级别牌打3，并且有主花色时： 牌点大小：大王>小王>主花色3>副花色3>主花色2>副花色2>A>K>Q>J>10>9>8>7>6>5>4 不可跳过牌点相连（例如：级牌=8，7799不算连对）
--]]

local LibBase = import("..base.LibBase")
local SortUtils = import(".SortUtils")
local M = class(LibBase);

function M:main(data)
	local value = Card.ValueMap:getKeyByValue(tostring(data.args[1]));
	if value ~= data.ruleDao:getMainValue() then
		return;
	end
	data.sortFlag = SortUtils.SortFlag.SJ1;
	return SortUtils.getCardSize(data, data.args[2]);
end

return M;