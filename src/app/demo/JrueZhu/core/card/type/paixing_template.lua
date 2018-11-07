--[[--ldoc desc
@module paixing_template
@author SinChen

Date   2018-01-09 19:35:02
Last Modified by   SinChen
Last Modified time 2018-03-02 16:47:30
]]

local template = [==[
local CardBase = import("..base.CardBase")
local M = class(CardBase)

M.description = [[
功能描述说明：
]]

function M:ctor(data,ruleDao)

end

function M:check(data)
	
end

function M:compare(data)
	
end

function M:find( ... )
	-- body
end

return M;
]==]

return template;