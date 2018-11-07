-- @module: CheckBoxTest
-- @author: JoeyChen
-- @Date:   2018-10-18 16:17:36
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-18 18:43:38

local function createUI()
	local head = cc.Sprite:create("JoeyChen/1.png")
	head:setPosition(display.cx, display.cy)
	head:setVisible(false)
    local text =  cc.Label:createWithSystemFont("是否显示图片", "Arial", 30)
        :move(display.cx - 50, display.cy + 50)
	local checkbox = ccui.CheckBox:create("JoeyChen/3.png","JoeyChen/2.png")
		:move(display.cx + 100,display.cy + 50)

	checkbox:addEventListener(function (target,selector)
		local isVisible = selector == CHECKBOX_STATE_EVENT_SELECTED and true or false
		head:setVisible(isVisible)
	end)

	return head, text, checkbox
end 

local function main()
    local scene = cc.Scene:create()
    local head, text, checkbox = createUI()
    scene:addChild(head)
    scene:addChild(text)
    scene:addChild(checkbox)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main