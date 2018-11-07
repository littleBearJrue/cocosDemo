-- @module: MenuItemTest
-- @author: JoeyChen
-- @Date:   2018-10-19 16:09:55
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-19 17:10:17

local function createUI()
	local text = cc.Label:createWithSystemFont("文字", "Arial", 30)
	local labelBtn = cc.MenuItemLabel:create(text)
		:onClicked(function()
			dump("点击文字菜单")
		end)

    local s1 = cc.Sprite:create("Images/cocos2dbanner.png")
    local s2 = cc.Sprite:create("JoeyChen/1.png")
    local spriteBtn = cc.MenuItemSprite:create(s1, s2)
		:onClicked(function()
			dump("点击精灵菜单")
		end)    

	local ImageBtn = cc.MenuItemImage:create("Images/cocos2dbanner.png","JoeyChen/4.png")
		:onClicked(function()
			dump("点击图片菜单")
		end)

	local onIcon = "JoeyChen/2.png"
	local offIcon = "JoeyChen/3.png"
	local onMenuItem = cc.MenuItemImage:create(onIcon,onIcon)
	local offMenuItem = cc.MenuItemImage:create(offIcon,offIcon)
	local toggleBtn = cc.MenuItemToggle:create(onMenuItem,offMenuItem)
		:onClicked(function()
			dump("点击开关菜单")
		end)

	local menu = cc.Menu:create(labelBtn, spriteBtn, ImageBtn, toggleBtn)
		:move(display.cx, display.cy)
	menu:alignItemsVertically()

	return menu
end 

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main