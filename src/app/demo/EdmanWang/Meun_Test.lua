-- @Author: EdmanWang
-- @Date:   2018-10-22 10:51:39
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-22 16:53:49

--[[-
   菜单的测试：
           菜单
           菜单项 ：
                   MenuItemFont
                   MenuItemSprite
                   MenuItemImage
           菜单项的点击事件
-]]
local function menu_MenuItemFont()
	cc.MenuItemFont:setFontName("Times New Roman");
	cc.MenuItemFont:setFontSize(23);
    -- 创建处一个item_One
	local item_One = cc.MenuItemFont:create("start");
    -- 回调函数的具体实现
	local function item_OneCallBack( sender )
		print("我是一个回调函数的,item_OneCallBack",sender)
	end
    -- 注册item_One的回调函数
	item_One:registerScriptTapHandler(item_OneCallBack);
    
    -- cc.MenuItemLabel:setSize(20);
	local item_two = cc.MenuItemFont:create("ended");
    local function item_twoCallBack(sender)
         print("我是一个回调函数的,item_twoCallBack",sender)
    end
    item_two:registerScriptTapHandler(item_twoCallBack);

    local menu = cc.Menu:create(item_One,item_two);
    menu:alignItemsVertically();
    return menu;
end 

local function menu_MenuItemSprite( )
	local normal_sprite_start = cc.Sprite:create("menu/start-up.png");
	local select_sprite_start = cc.Sprite:create("menu/start-down.png")
	local menuItemSprite1 = cc.MenuItemSprite:create(normal_sprite_start,select_sprite_start);
	-- menuItemSprite1:setPosition(cc.Director:getInstance():convertToGL(cc.p(600,100)));
  menuItemSprite1:setPosition(30,20)
    -- 回调函数
	local function menuItemSprite1_callBack( sender )
		print("回调函数menuItemSprite1",sender);
	end
    menuItemSprite1:registerScriptTapHandler(menuItemSprite1_callBack);
  local normal_sprite_setting = cc.Sprite:create("menu/setting-up.png");
  local select_sprite_setting = cc.Sprite:create("menu/setting-down.png");
  local menuItemSprite2 = cc.MenuItemSprite:create(normal_sprite_setting,select_sprite_setting);
  menuItemSprite2:setPosition(100,100);
  local function menuItemSprite2_callBack( sender )
    print("回调函数menuItemSprite2_callBack",sender);
  end
  menuItemSprite2:registerScriptTapHandler(menuItemSprite2_callBack);
  local menu = cc.Menu:create(menuItemSprite1,menuItemSprite2);
  return menu;
end 

local function create_meun(  )
	local layer = cc.Layer:create();
  -- 背景
  local sprite_bg = cc.Sprite:create("menu/background.png");
  -- 创建菜单项
  sprite_bg:setPosition(cc.p(display.size.width/2,display.size.height/2));
  layer:addChild(sprite_bg);
  -- 使用MenuItemFont
  -- local menu = menu_MenuItemFont();
  local  menu = menu_MenuItemSprite();
  layer:addChild(menu);
  return layer;

end

function main( ... )
	local scene = cc.Scene:create();
    local layer = create_meun();
    layer:addTo(scene);
    scene:addChild(CreateBackMenuItem())
    return scene;
end

return main;