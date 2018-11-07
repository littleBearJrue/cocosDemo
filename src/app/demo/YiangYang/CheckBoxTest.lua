
local function createCheckBox()
	--五种状态纹理图片
	local normal = "yiang/default_toggle_normal.png"
	local normal_press = "yiang/default_toggle_pressed.png"
	local active = "yiang/default_toggle_checkmark.png"
	local normal_disable = "yiang/default_toggle_disabled.png"
	local active_disable = "yiang/default_toggle_disabled.png"
	--纹理格式
	--UI_TEX_TYPE_LOCAL 、 UI_TEX_TYPE_PLIST
	local checkbox = ccui.CheckBox:create(normal,normal_press,active,normal_disable,active_disable,UI_TEX_TYPE_LOCAL)
	:move(display.cx,display.cy)
	-- checkbox:addEventListenerCheckBox(function (target,selector)
	-- 	--selector 0:选中； 1:没选
	-- 	dump(target,"checkbox target =")
	-- 	dump(selector,"checkbox selector =")
	-- end)

	checkbox:addEventListener(function (target,selector)
		--selector 0:选中 CHECKBOX_STATE_EVENT_SELECTED； 1:没选 CHECKBOX_STATE_EVENT_UNSELECTED 
		dump(target,"checkbox target =")
		dump(selector,"checkbox selector =")
		dump(CHECKBOX_STATE_EVENT_SELECTED,"checkbox 000 =")
	end)

	return checkbox
end

local function createBtn()
	local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal, 0)
    :move(display.cx, display.cy+50)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    return btn
end 

local function main()
    local scene = cc.Scene:create()
    
    local box = createCheckBox()
    local btn = createBtn()
    btn:addClickEventListener(function ()
    	box:setEnabled(false) --禁用
    end)

    scene:addChild(box)
    scene:addChild(btn)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main