local CardView = import("app.demo.KevinZhang.CardView").CardView







local function main()
    -- 创建主场景
    local scene = cc.Scene:create()
    local card = CardView:create()
    card:setPosition(cc.p(150, 150))
    scene:addChild(card)
    card._value = 2
    print("card size", card:getContentSize().height, card:getContentSize().width)
    print("card scale", card:getScale())
    scene:addChild(CreateBackMenuItem())
    return scene;
end


return main;