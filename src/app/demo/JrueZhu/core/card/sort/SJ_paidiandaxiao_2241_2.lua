--[[--ldoc desc
@module SJ_paidiandaxiao_2241_2
@author RonanLuo

Date   2018-01-19 15:12:19
Last Modified by   EricHuang
Last Modified time 2018-08-20 12:12:26
]]

--[[
	牌点排序
	级别牌打A，并且有主花色时： 牌点大小：主花色5>大王>小王>主级别牌>副级别牌>K>Q>J>10>9>8>7>6>5>4>3>2 可跳过牌点相连（例如：级牌=8，7799算连对）
]]

local LibBase = import("..base.LibBase")
local SortUtils = import(".SortUtils")
local M = class(LibBase);

function M:main(data)
	local value = Card.ValueMap:getKeyByValue(tostring(data.args[1]));
	if value ~= data.ruleDao:getMainValue() then
		return;
	end

	local mainColor = data.ruleDao:getMainColor()
	if not mainColor or mainColor < 0 then -- has mincolor ???
		return
	end

	data.sortFlag = SortUtils.SortFlag.SJ2;
	return SortUtils.getCardSize(data, data.args[2])
end

return M;