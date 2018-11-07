--[[--ldoc desc
@module SingleCardScene
@author JrueZhu

Date   2018-10-22 10:42:45
Last Modified by   JrueZhu
Last Modified time 2018-10-29 16:46:49
]]
local Bit = require("app.demo.JrueZhu.Bit");

local showSingleCardScene = class("showSingleCardScene", cc.load("mvc").ViewBase)
-- local CardView = require("app.demo.JrueZhu.cardLayer.singleCard.CardView")
local singleCardView = require("app.demo.JrueZhu.cardLayer.singleCard.SingleCardView")

local dataStyle = {
    BYTE_STYLE = 1,
    TYPE_VALUE_STYLE = 2,
}

local function getRandomDataStyle()
    return math.random(1, 2);
end

local function getRandomCardType() 
  return math.random(0, 3);
end

local function getRandomCardValue(existType)
    if existType >= 0 and existType < 4 then
        return math.random(1, 14);
    end
    return math.random(1, 2);
end

local function getRandomCardByte()
    local cardType = getRandomCardType();
    local cardValue = getRandomCardValue(cardType);
    return Bit:toByte(cardType, cardValue);
end

local function getRandomCardStyle()
    return math.random(1, 2) == 1 and "liang" or "an";
end

local function createRandomBtn(card, label)
    local button = ccui.Button:create("Images/JrueZhu/btn_play.png", "", "", 0);
    local randomDataStyle;
    button:move(display.cx, 50)
    button:addTouchEventListener(function(sender, eventType)        
        if (ccui.TouchEventType.began == eventType)  then            
            randomDataStyle = getRandomDataStyle();
            if randomDataStyle == dataStyle.BYTE_STYLE then
                card.cardByte = getRandomCardByte();
                card.cardStyle = getRandomCardStyle();
                if card.cardByte == 0x41 or card.cardByte == 0x42 then
                    label:setVisible(true);
                else
                    label:setVisible(false);
                end
            elseif randomDataStyle == dataStyle.TYPE_VALUE_STYLE then
                local randomCardType = getRandomCardType();
                card.cardType = randomCardType;
                card.cardValue = getRandomCardValue(randomCardType);
                card.cardStyle = getRandomCardStyle();
                if card.cardType == 4 and (card.cardValue == 1 or card.cardValue == 2) then
                    label:setVisible(true);
                else
                    label:setVisible(false);
                end
            end
        elseif (ccui.TouchEventType.moved == eventType)  then              
            print("move")        
        elseif  (ccui.TouchEventType.ended == eventType) then            
            print("up")        
        elseif  (ccui.TouchEventType.canceled == eventType) then            
            print("cancel")       
        end    
    end)
    return button;
end

local function createLabel()
    local toast = cc.Label:createWithSystemFont("恭喜你！下次分享就是你了！", "Arial", 20):move(display.cx, display.top - 50);
    toast:setVisible(false);
    return toast;
end

function showSingleCardScene:main()
    local scene = cc.Scene:create();

    local card = singleCardView:create({cardByte = 0x01, cardStyle = "liang"}):move(0, 0);
    scene:addChild(card);

    local label = createLabel(card)
    scene:addChild(label);

    scene:addChild(createRandomBtn(card, label));

    scene:addChild(CreateBackMenuItem())

    return scene;
end

return handler(showSingleCardScene, showSingleCardScene.main);