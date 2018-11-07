--[[--ldoc desc
@module paixing_1569_11
@author VincentZhang

Date   2018-08-14 10:14:33
Last Modified by   VincentZhang
Last Modified time 2018-08-14 14:36:56
]]

 --[[
	paixing_1569_11: 2对及以上两张点数+花色相同的牌 
1、相连的对子，牌点大小必需相邻，主、副不能相连 
2、对大王+对小王是独立的连对 
3、主级牌不可以与副级牌相连 
注：这里的花色相同，指主花色或副花色[黑红梅方]相同

 	牌型：连对拖拉机(升级类)
 	特征：牌点相邻的两组牌，每组都由两张相同牌点和相同花色的牌组成
 	例如：(33 44)、(77 88)、(小王小王 大王大王)
 	范围：A-2-3-...-J-Q-K-小王-大王
 ]]

local LineBase2 = import("..base.LineBase2")
local M = class(LineBase2)

function M:ctor(data,ruleDao)
    local minLen = self.args[1]
    assert(minLen,"缺少最短长度参数")
    local args = {sameCount = 2,minLength = tonumber(minLen),isSameColor = true,
                   isOnlyDaXiaoWang = true,isJiCardSeparate = true};
    LineBase2.init(self,args);
end

return M