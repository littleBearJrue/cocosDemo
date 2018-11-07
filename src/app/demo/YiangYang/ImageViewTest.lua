--[[
	Sprite / ImageView Test
]]
local function main()
    local scene = cc.Scene:create()
    
    local cache = cc.Director:getInstance():getTextureCache():addImage("yiang/caishen.png")

    local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal, 0)
    :move(display.cx, display.cy)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    btn:setTitleText("点击改变纹理")
    btn:setTitleFontSize(20)

    -- local image = ccui.ImageView:create(s_PlayNormal)
    -- :move(display.cx, display.cy-50)

    local sp = cc.Sprite:create(s_PlayNormal)
    :move(display.cx, display.cy-50)

    btn:addTouchEventListener(function ( sender,eventType )
    	--event : 0->按下；1->移动；2->按下松开；3->移动后松开，即取消
		if eventType == 2 then
			-- image:loadTexture("creator/caishen.png") --更换纹理
			sp:initWithTexture(cache) --更换纹理
		end
    end)

    
    scene:addChild(btn)
    -- scene:addChild(image)
    scene:addChild(sp)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main