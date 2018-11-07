local Card = require("app.demo.jasonhuang.card.Card")

local oneCard
local function createOnePoker()
    local card = Card:create()
    oneCard = card
    return card
end

local function createPokerSetPanel()
    local layer = cc.Layer:create()

    local colorBtn = ccui.Button:create("Images/jasonhuang/btn_blue.png", "Images/jasonhuang/btn_blue.png")
    colorBtn:setAnchorPoint(cc.p(1.0,0.5))
    colorBtn:setTitleText("改变花色")
    colorBtn:setPosition(display.right_center)
    colorBtn:addClickEventListener(function(sender)
        local colorMap = {0,1,2,3}
        local res = true
        while res do
            local index = math.random(#colorMap)
            if colorMap[index] ~= oneCard.color then
                oneCard.color = colorMap[index]
                res = false
            end
        end
    end)
    layer:addChild(colorBtn)

    local valueBtn = ccui.Button:create("Images/jasonhuang/btn_blue.png", "Images/jasonhuang/btn_blue.png")
    valueBtn:setAnchorPoint(cc.p(1.0,0.5))
    valueBtn:setTitleText("改变牌值")
    valueBtn:setPosition(cc.p(display.right, display.cy-50))
    valueBtn:addClickEventListener(function(sender)
        local res = true
        while res do
            local val = math.random(13)
            if val ~= oneCard.value then
                oneCard.value = val
                res = false
            end
        end
    end)
    layer:addChild(valueBtn)
    
    local reverseBtn = ccui.Button:create("Images/jasonhuang/btn_blue.png", "Images/jasonhuang/btn_blue.png")
    reverseBtn:setAnchorPoint(cc.p(1.0,0.5))
    reverseBtn:setTitleText("改变正背面")
    reverseBtn:setPosition(cc.p(display.right, display.cy-100))
    reverseBtn:addClickEventListener(function(sender)
        oneCard.reverse = not oneCard.reverse 
    end)
    layer:addChild(reverseBtn)

    return layer
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(CreateBackMenuItem())
    scene:addChild(createPokerSetPanel())
    scene:addChild(createOnePoker())
    return scene
end

return main