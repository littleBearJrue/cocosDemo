-- @Author: EdmanWang
-- @Date:   2018-10-18 15:36:39
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-31 11:02:51

-- 实例话一个cardview对象，为scene
local CardView = class("CardView",cc.load("boyaa").mvc.BoyaaView);

local _ByteMap = {
    [0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3",  [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7",
    [0x08] = "方块8", [0x09] = "方块9", [0x0a] = "方块10", [0x0b] = "方块J", [0x0c] = "方块Q", [0x0d] = "方块K",

    [0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3",  [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7",
    [0x18] = "梅花8", [0x19] = "梅花9", [0x1a] = "梅花10", [0x1b] = "梅花J", [0x1c] = "梅花Q", [0x1d] = "梅花K",

    [0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3",  [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7",
    [0x28] = "红桃8", [0x29] = "红桃9", [0x2a] = "红桃10", [0x2b] = "红桃J", [0x2c] = "红桃Q", [0x2d] = "红桃K",

    [0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3",  [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7",
    [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3a] = "黑桃10", [0x3b] = "黑桃J", [0x3c] = "黑桃Q", [0x3d] = "黑桃K",

    [0x4e] = "小王", [0x4f] = "大王", [0x40] = "日历牌", [0x41] = "听用牌",
}

local _ColorMap = {
    [0] = "方块";
    [1] = "梅花";
    [2] = "红桃";
    [3] = "黑桃"; 
}

local _ValueMap = { 
    [3] = "3";
    [4] = "4";
    [5] = "5";
    [6] = "6";
    [7] = "7";
    [8] = "8";
    [9] = "9";
    [10] = "10";
    [11] = "J",
    [12] = "Q",
    [13] = "K",
    [14] = "A",
    [15] = "2",
    [16] = "小王",
    [17] = "大王",
}

--[[-构造函数-
   入参：data
        数据结构为 {
           cardByte：
        }
]]
function CardView:ctor(data)
    local peer = tolua.getpeer(self)
    local mt = getmetatable(peer)
    local __index = mt.__index
    mt.__index = function(_, k)
        if type(CardView[k]) == "table" and CardView[k].proprety == true then
            return CardView[k].get(self)
        elseif __index then
            if type(__index) == "table" then
                return __index[k]
            elseif type(__index) == "function" then
                return __index(_, k)
            end
        end
    end
    mt.__newindex = function(_, k, v)
        if type(CardView[k]) == "table" and CardView[k].proprety == true then
            return CardView[k].set(self, v)
        else
            rawset(_, k, v)
        end
    end
    -- self.cardValue = 1;
    -- self.cardColor = 1;
    -- self.cardByte = data;
    -- -- -- 默认创建一张牌
    -- local cardInfo =  self:getCardAttrFromByte(data);
    -- -- --[[-todo通过cardInfo 创建一张牌-]]
    -- self:createCard(cardInfo);
end

--[[-
   -- 跟新牌
    入参：table{
        value :
        color :
        flag :
    }
    返回值：cardByte
-]]
function CardView:updateView(data)
    local cardInfoNew = {};
    print("jjjjjjjjjjjjjjjj",type(data) == "table")
    if  type(data) == "table"  then
        self.cardValue  = data.cardValue;
        self.cardColor = data.cardColor;
        self.cardFlag = data.cardFlag;
    end
    cardInfoNew.cardValue = self.cardValue;
    cardInfoNew.cardColor = self.cardColor;
    cardInfoNew.cardFlag = self.cardFlag;
    --[[-todo  相应的参数修改牌-]]
    self:createCard(cardInfoNew);
end

function CardView:getCardAttrFromByte(byte)
    local cardInfo = {};
    self.updateCard  = {};
    local flag = math.floor(byte / 0x10)+1;
    local color, value = -1, -1;
    local byte2 = byte % 0x100;
        color = math.floor(byte2 / 0x10);
        value = byte2 % 0x10;
        if value < 3 then
            value = value + 13;
        elseif value > 13 then
            value = value + 2;
        end
        if color >= 5 and color <= 9 then
            color = color - 5;
        end
    self.updateCard.cardValue = value;
    self.updateCard.cardColor = color;
    self.updateCard.cardFlag = flag;
    cardInfo.cardValue = value;
    cardInfo.cardColor = color;
    cardInfo.cardFlag = flag;
    -- 返回一个table类型的 cardInfo,
    return cardInfo;
end


function CardView:createCard(cardInfo)
    local layer = cc.Layer:create();
	local spriteFrame = cc.SpriteFrameCache:getInstance();
    -- 加载plist
    spriteFrame:addSpriteFrames("card/cards.plist");
    local bg = cc.Sprite:createWithSpriteFrameName("bg.png");
    -- 以背景为节点，添加上其他的节点
    local size = bg:getContentSize();
    -- print("jjjjjjjjjjjjjjjjjjjjjjjj",cardInfo)
    -- -- 得到bg的size大小
    -- dump(cardInfo, "wgx------------")
    -- 默认的numberColor
    local numberColor = "black_";
    local flag = cardInfo.cardFlag;
    if flag %2 == 1 then
        numberColor = "red_"
    end
    --得到牌值    
    local cardNumber = cardInfo.cardValue;
    local cardColor = cardInfo.cardColor+1;
    local number;
    local bigImg;
    local smallImg
    if cardNumber == 16 then
        number =  cc.Sprite:createWithSpriteFrameName("small_joker_word.png");
        number:setPosition(33,size.height-50);
        bigImg =  cc.Sprite:createWithSpriteFrameName("small_joker.png");
        bigImg:setPosition(size.width/2,size.height/2-8);
    elseif  cardNumber == 17  then
        number =  cc.Sprite:createWithSpriteFrameName("big_joker_word.png");
        bigImg =  cc.Sprite:createWithSpriteFrameName("big_joker.png");
        number:setPosition(33,size.height-50);
        bigImg:setPosition(size.width/2+5,size.height/2-8);
    else    
        number = cc.Sprite:createWithSpriteFrameName(numberColor..cardNumber..".png");
        number:setPosition(33,size.height-50);
         -- 得到牌面上的牌值
        bigImg = cc.Sprite:createWithSpriteFrameName("color_"..cardColor..".png");
        bigImg:setPosition(size.width/2+5,size.height/2);
    
        smallImg = cc.Sprite:createWithSpriteFrameName("color_"..cardColor.."_small.png");
        smallImg:setPosition(30,size.height/2+13);
    end    
    bg:addChild(number, 1, 1);
    bg:addChild(bigImg, 1, 2);
    if cardNumber < 16  then
        bg:addChild(smallImg, 1, 3);
    end  
    -- bg:setPosition(0,0);
    bg:addTo(layer);
    layer:addTo(self)
    return self;
end

local mkproprety = function(getFun, setFun)
    local instance = {proprety = true}
    instance.get = getFun
    instance.set = setFun
    setmetatable(instance, {__newIndex = function()
        error(1)
    end})
    return instance
end

local function checkOrValue( params )
    if type(params) == "number" then
        return params;
    else
        error("输入的参数不合理")
    end
end

CardView.color = mkproprety(
    function(self)  return self.updateCard.cardColor  end,
    function(self, color)
        -- 数据校验
       local colorOrValue = checkOrValue(color);
       if colorOrValue ~= nil then
           self.updateCard.cardColor = colorOrValue;
           self:updateView(self.updateCard)
       end
end)

CardView.value = mkproprety(
    function(self)  return self.updateCard.cardValue end,
    function(self, value)
    -- 数据校验
    local colorOrValue = checkOrValue(value);
       if colorOrValue ~= nil then
          self.updateCard.cardValue = colorOrValue;
          self:updateView(self.updateCard)
       end
end)
return CardView;
