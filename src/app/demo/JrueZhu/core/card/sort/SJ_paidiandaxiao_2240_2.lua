--[[--ldoc desc
@module SJ_paidiandaxiao_2240_2
@author LisaChen

Date   2018-01-19 15:12:07
Last Modified by   LisaChen
Last Modified time 2018-07-11 16:03:47
]]

--[[
	牌点排序
	 打无主时 牌点大小：大王>小王>级别牌>2>A>K>Q>J>10>9>8>7>6>5>4>3 不可跳过牌点相连（例如：级牌=8，7799不算连对）
]]

local LibBase = import("..base.LibBase")
local SortUtils = import(".SortUtils")
local M = class(LibBase);

function M:main(data)
	local ruleDao = data.ruleDao;
	if ruleDao:getMainColor() >= 0 then
		return;
	end
	data.sortFlag = SortUtils.SortFlag.SJ1;
	data.isDistinguishZhuFu = false; -- 牌点大小不区分主副牌 
	return SortUtils.getCardSize(data, data.args[1]);
end

return M;