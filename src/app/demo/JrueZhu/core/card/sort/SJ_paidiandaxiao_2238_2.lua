-- @Author: KevinZhang
-- @Date:   2017-11-13 18:42:02
-- @Last Modified by   LisaChen
-- @Last Modified time 2018-07-11 16:03:13
--[[
	牌点排序
	升级类牌点大小：大王>小王>主级别牌>副级别牌>主花色5>副花色5>主花色3>副花色3>主花色2>副花色2>A>K>Q>J>10>9>8>7>6>4 不可跳过牌点相连（例如：级牌=8，7799不算连对）
]]

local LibBase = import("..base.LibBase")
local SortUtils = import(".SortUtils")
local M = class(LibBase);

function M:main(data)
	data.sortFlag = SortUtils.SortFlag.SJ1;
	data.isDistinguishZhuFu = false; -- 牌点大小不区分主副牌 
	return SortUtils.getCardSize(data, data.args[1]);
end

return M;