--[[--ldoc desc
@module paixing_1569_5
@author WahidZhang

Date   2018-01-09 19:35:02
Last Modified by   CelineJiang
Last Modified time 2018-07-30 18:40:37
]]

local LineBase2 = import("..base.LineBase2")
local M = class(LineBase2)

M.description = [[
功能描述说明：
 	牌型：超级姐妹对(升级类)
    特征：牌点 “大小” 相邻的三组牌，每组都由两张相同牌点和相同花色的牌组成
 	例如：(33 44)、(77 88)、(小王小王 大王大王)
 	范围：2-3-...-J-Q-K-A-小王-大王
 	其他补充：当级别牌为 7 时，6和8算牌点大小相邻的牌

]]

function M:ctor(data,ruleDao)
    local minLen = self.args[1]
    assert(minLen,"缺少最短长度参数")
    local args = {sameCount = 2,minLength = tonumber(minLen),isSameColor = true};
    LineBase2.init(self,args);
end

return M;