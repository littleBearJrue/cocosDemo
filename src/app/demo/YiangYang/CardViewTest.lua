
local function createUI()
	
	local CardView = import(".CardView")
	local cardview = CardView:create()
	cardview:setPosition(100,100)
	-- cardview.cardTByte = 0x11
	-- cardview.cardValue = 13
	-- cardview.cardType = 2
	-- dump(cardview.cardType,"cardType")

	return cardview
end

-- --plist贴图测试
-- local function createPlistUI()
-- 	cc.SpriteFrameCache:getInstance():addSpriteFrames("yiang/poker.plist")
-- 	local iv = ccui.ImageView:create()
-- 	iv:loadTexture("red_1.png",ccui.TextureResType.plistType)
-- 	iv:setPosition(200,200)
-- 	return iv
-- end

local function createLayer(cardview)
	

	local layout = ccui.Layout:create()
	-- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- layout:setBackGroundColor(cc.c3b(255, 255, 0));
	layout:setContentSize(200,display.height)

	local label = cc.Label:createWithTTF("随机改变牌值", s_arialPath, 30)
    :move(display.cx, display.height-50)
	layout:addChild(label)

	local function onClick()
		cardview.cardValue = math.random(1,15)
		cardview.cardType = math.random(1,4)
		cardview.cardStyle = math.random(0,1)
		if cardview.cardStyle == 0 then
			if cardview.cardValue <= 13 then
				label:setString("cardValue = "..cardview.cardValue..", cardType = "..cardview.cardType)
			else
				label:setString("cardValue = "..cardview.cardValue)
			end
		else
			label:setString("cardStyle is an ")
		end
	end

	local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal):move(display.cx, display.height-100)
	btn:addClickEventListener(onClick)

	layout:addChild(btn)

	layout:setPosition(0,0)
	return layout
end

local function main()
    local scene = cc.Scene:create()
    local cardview = createUI()
    scene:addChild(cardview)
    -- scene:addChild(createPlistUI())
    scene:addChild(createLayer(cardview))
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main