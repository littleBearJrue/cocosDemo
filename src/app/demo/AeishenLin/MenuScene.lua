require("app/demo/AeishenLin/GameScene")


local function createMenuLayer() 
   local layer=cc.Layer:create()                         

    --MenuItemFont的使用
    cc.MenuItemFont:setFontName("Times New Roman")
    cc.MenuItemFont:setFontSize(26)
    local Text=cc.MenuItemFont:create("Start")
    local function menuItemCallback(sender)           --按钮回调函数
       print("gameStart......")
       cc.Director:getInstance():replaceScene(GameSceneMain())
    --    cc.Director:getInstance():replaceScene(ClockModuleMain(10))
       --cc.Director:getInstance():replaceScene(cc.TransitionPageTurn(1, GameSceneMain(),nil))
    end
    Text:registerScriptTapHandler(menuItemCallback)   --注册回调函数

    --精灵菜单的使用
    local s1=cc.Sprite:create("Images/YellowSquare.png")
    local s2=cc.Sprite:create("Images/YellowTriangle.png")
    local spriteBtn=cc.MenuItemSprite:create(s1,s2)
    local function spriteBtnCB(sender) 
       print("spriteMenu.....")
    end
    spriteBtn:registerScriptTapHandler(spriteBtnCB)

    --图片菜单的使用
    local ImageBtn=cc.MenuItemImage:create("Images/powered.png","HelloWorld.png")
    local function imageBtnCB(sender) 
       print("imageBtnMenu....")
    end
    ImageBtn:registerScriptTapHandler(imageBtnCB)

    local toggleBtn1 = cc.MenuItemToggle:create(ImageBtn,spriteBtn)
    local function toggleBtnCB1(sender) 
        -- print("ToggleImage....")
     end
    toggleBtn1:registerScriptTapHandler(toggleBtnCB1)

    local toggleBtn2 = cc.MenuItemToggle:create(cc.MenuItemFont:create( "open" ),cc.MenuItemFont:create( "close" ))
    local function toggleBtnCB2(sender) 
        print("ToggleText....")
     end
    toggleBtn1:registerScriptTapHandler(toggleBtnCB2)

    local mn = cc.Menu:create(Text,toggleBtn1,toggleBtn2)         
    mn:alignItemsVertically() --居中排列
    layer:addChild(mn)
    return layer                                       
end


local function main()
    --cc.sys.localStorage.setItem("hightScore",0);
    --cc.UserDefault:getInstance():setIntegerForKey("hightScore", 0)
    local scene = cc.Scene:create()
    scene:addChild(createMenuLayer())               
    --scene:addChild(CreateBackMenuItem())
    return scene
end

return main