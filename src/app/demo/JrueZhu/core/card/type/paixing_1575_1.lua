--[[--ldoc desc
@module paixing_1575_1
@author SeryZeng

Date   2018-01-16 20:35:40
Last Modified by   AmyGuo
Last Modified time 2018-05-28 17:55:51
]]

--4张牌点相同的的牌+任意2张其它牌（1对也当2张单牌处理）

local TongZhangDaiPai = import ("..base.TongZhangDaiPai")
local M = class(TongZhangDaiPai)

function M:ctor(data, ruleDao)
    self:init({4,2});
end

return M; 