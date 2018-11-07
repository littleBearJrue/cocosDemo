local CreateImageView = function()
	local img1 = "JoeyChen/1.png"
	local img2 = "JoeyChen/4.png"

    local testImageView = ccui.ImageView:create("JoeyChen/1.png")
    	:move(display.cx, display.cy)
    testImageView:setName("img1")
    testImageView:setTouchEnabled(true)
    testImageView:addClickEventListener(function()
    	local name = testImageView:getName()
    	local file = name == "img1" and img2 or img1
		testImageView:loadTexture(file)
		testImageView:setName(name == "img1" and "img2" or "img1")
    end)

    return testImageView
end

local function initText()
    local text =  cc.Label:createWithSystemFont("点击切换图片", "Arial", 30)
        :move(display.cx, display.cy - 50)

    return text
end

local function main()
    local scene = cc.Scene:create()
    local ImageView = CreateImageView()
    scene:addChild(ImageView)
    scene:addChild(initText())
    scene:addChild(CreateBackMenuItem())

    return scene
end

return main