-- @module: SilderTest
-- @author: JoeyChen
-- @Date:   2018-10-19 17:33:25
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-19 17:54:33

local function createUI()
	local slider = ccui.Slider:create("Images/cocos2dbanner.png","JoeyChen/1.png")
		:move(display.cx,display.cy)
	slider:setPercent(20)
	slider:addEventListener(function (sender, selector)
		if sender:getPercent() == slider:getMaxPercent() then
			print("到达最大值",slider:getMaxPercent() .. "%")
		elseif sender:getPercent() == 0 then
			print("到达最小值")
		else
			print(sender:getPercent() .. "%")
		end
	end)

	return slider
end 

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main