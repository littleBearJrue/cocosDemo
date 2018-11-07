local ScreenTest = {}
local director = cc.Director:getInstance()
local view = director:getOpenGLView()
local designSize = view:getDesignResolutionSize()
function ScreenTest:createBackGround( )
	local background = cc.Sprite:create("Images/assetMgrBackground3.png")
	background:setContentSize(designSize.width,designSize.height)
	background:setAnchorPoint(0.5,0.5)
	background:setPosition(designSize.width/2,designSize.height/2)
	return background
end

function ScreenTest:createSprite( )
	local sprite = cc.Sprite:create("HelloWorld.png")
	-- sprite:setScale(0.5,0.5)
	sprite:setAnchorPoint(0,0)
	sprite:setPosition(0,0)
	return sprite
end

function ScreenTest:createLayer( )
	local layer = cc.LayerColor:create(cc.c4b(255,255,0,255))
	layer:setContentSize(240,160)
	layer:setAnchorPoint(0,0)
	layer:setPosition(designSize.width/2,designSize.height/2)
	return layer
end

function ScreenTest:main( ... )
	local scene = cc.Scene:create()
	self.scene = scene
	scene:addChild(self:createBackGround())
	scene:addChild(self:createLayer())
	scene:addChild(self:createSprite())
	scene:addChild(CreateBackMenuItem())
	return scene
end

return handler(ScreenTest, ScreenTest.main)