local BetViewCtr =  require("app.demo.DowneyTang.BetView.BetViewCtr")

local function main()
    local scene = cc.Scene:create() 
    local sceneBg = ccui.ImageView:create("DowneyTang/koprokdice/koprok_dice_bg.png")
    local s = cc.Director:getInstance():getVisibleSize()
    sceneBg:setPosition(s.width*0.45, s.height/2)
    sceneBg:setScaleX(0.7)
    sceneBg:setScaleY(0.5)
    sceneBg:addTo(scene)

    local newBetViewCtr = BetViewCtr.new();
    newBetViewCtr:initView(1);
    scene:addChild(newBetViewCtr:getView());

    -- scene:addChild(CreateBackMenuItem())
    return scene
end

return main