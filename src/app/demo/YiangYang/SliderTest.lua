
local function createUI()
	local layer = cc.Layer:create()
	local slider = ccui.Slider:create("yiang/slider_bg.png","yiang/slider.png")

	:move(display.cx,display.cy)
	:addTo(layer)

	-- slider:setScale9Enabled(true)

	slider:setMaxPercent(100) --设置峰值

	slider:setPercent(50) --选中50%

	slider:addEventListenerSlider(function ( sender,selector )
		-- dump(sender, "sender == ")
		dump(selector, "selector == ")
		dump(sender:getPercent(), "getPercent == ")
	end)

    return layer
end


local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main