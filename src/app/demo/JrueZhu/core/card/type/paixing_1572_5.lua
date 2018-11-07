--[[--ldoc desc
@module paixing_1572_5
@author VincentZhang

Date   2018-08-14 14:35:49
Last Modified by   VincentZhang
Last Modified time 2018-08-14 14:43:23
]]
--[[
paixing_1572_5: 2组及以上三张点数+花色相同的牌 
1、相连的三张，牌点大小必需相邻 
2、主牌和副牌不可以组成连三张 
3、大王小王是独立的连三张 
4、主级牌不可以与副级牌相连 
注：这里的花色相同，指主花色或副花色[黑红梅方]相同]]

local LineBase2 = import("..base.LineBase2")
local M = class(LineBase2)

M.description = [[
功能描述说明：
 	牌型：连三拖拉机(升级类)
    特征：牌点 “大小” 相邻的两组及以上牌，每组都由两张相同牌点和相同花色的牌组成
 	例如：(333 444)、(777 888)、(小王小王小王 大王大王大王)
 	范围：2-3-...-J-Q-K-A-小王-大王
 	其他补充：当级别牌为 7 时，6和8算牌点大小相邻的牌
]]

function M:ctor(data,ruleDao)
    local minLen = self.args[1]
    assert(minLen,"缺少最短长度参数")
    local args = {sameCount = 3,minLength = tonumber(minLen),isSameColor = true,
    			isOnlyDaXiaoWang = true,isJiCardSeparate = true};
    LineBase2.init(self,args);
end

return M;