local DeskView = require("app.demo.DowneyTang.DeskView.DeskView")
local DeskViewConfig = require("app.demo.DowneyTang.DeskView.DeskViewConfig")
local DeskViewBehavior =  require("app.demo.DowneyTang.DeskView.DeskViewBehavior")
local BigChipView = require("app.demo.DowneyTang.BigChipView.BigChipView")
-- local BetViewCtr = require("app.DowneyTang.BetView.BetViewCtr")

local function main()
    local scene = cc.Scene:create() 
    -- local newBetViewCtr = BetViewCtr.new()
    -- scene:addChild(newBetViewCtr)
    local sceneBg = ccui.ImageView:create("DowneyTang/koprokdice/koprok_dice_bg.png")
    local s = cc.Director:getInstance():getVisibleSize()
    sceneBg:setPosition(s.width*0.5, s.height/2)
    sceneBg:setScaleX(0.7)
    sceneBg:setScaleY(0.5)
    sceneBg:addTo(scene)

    --【创建大筹码】
    local newBigChipView = BigChipView.create()
    newBigChipView:setScale(0.6)
    -- newBigChipView:setPosition(250,50)
    newBigChipView:setPosition(s.width*0.5, s.height/2)
    scene:addChild(newBigChipView)

    --【创建牌桌，添加组件划分不同的触摸区域】
    local newDeskView = DeskView.create()
    newDeskView:bindBehavior(DeskViewBehavior)
    local spaceMap = DeskViewConfig:getSpaceMap()
    newDeskView:addTouchSpace(spaceMap)
    newDeskView:setScale(0.5)
    newDeskView:setPosition(240,200)
    scene:addChild(newDeskView)


    -- scene:addChild(CreateBackMenuItem())
    return scene
end

return main