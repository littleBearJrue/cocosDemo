--[[--ldoc desc
@module paidiandaxiao_2240_1
@author RonanLuo

Date   2018-01-19 15:12:07
Last Modified by   RonanLuo
Last Modified time 2018-03-01 09:56:06
]]

--[[
	牌点排序
	打无主时 牌点大小：大王>小王>黑桃A>级别牌>A>K>Q>J>10>9>8>7>6>5>4>3>2 可跳过牌点相连（例如：级牌=8，7799算连对）
]]

local LibBase = import("..base.LibBase")
local SortUtils = import(".SortUtils")
local M = class(LibBase);

function M:main(data)
	local ruleDao = data.ruleDao;
	if ruleDao:getMainColor() >= 0 then
		return;
	end
	data.sortFlag = SortUtils.SortFlag.SJ2;
	return SortUtils.getCardSize(data, data.args[1]);
end

return M;