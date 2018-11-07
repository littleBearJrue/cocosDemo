-- @Author: KevinZhang
-- @Date:   2017-11-13 18:42:02
-- @Last Modified by   CelineJiang
-- @Last Modified time 2018-08-16 18:07:04
--[[
	牌点排序
	升级类牌点大小：主花色5>大王>小王>黑桃A>主级别牌>副级别牌>A>K>Q>J>10>9>8>7>6>5>4>3>2 可跳过牌点相连（例如：级牌=8，7799算连对）
]]

local LibBase = import("..base.LibBase")
local SortUtils = import(".SortUtils")
local M = class(LibBase);

function M:main(data)
	local ruleDao = data.ruleDao;
	data.sortFlag = SortUtils.SortFlag.SJ2;
	return SortUtils.getCardSize(data, data.args[1]);
end

return M;