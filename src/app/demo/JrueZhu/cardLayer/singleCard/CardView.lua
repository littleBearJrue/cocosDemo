--[[--ldoc desc
@module CardView
@author JrueZhu

Date   2018-10-19 10:11:37
Last Modified by   JrueZhu
Last Modified time 2018-10-29 10:11:12
]]

--[[
    暂时不用！！！
--]]
local Bit = import("app.JrueZhu.Bit");

local CardView  = class("CardView", function()
    return ccui.Layout:create();
end)

local mkproperty = function(getFun, setFun)
	local instance = {property = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
		error()
	end})
	return instance;
end

local function setPeerSemetable(object)
    local peer = tolua.getpeer(object)
	local mt = getmetatable(peer)
	local __index = mt.__index
	mt.__index = function(_, k)
		if type(CardView[k]) == "table" and CardView[k].property == true then
			return CardView[k].get(object)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(CardView[k]) == "table" and CardView[k].property == true then
			return CardView[k].set(object, k, v)
		else
			rawset(_, k, v)
		end
	end
end

CardView.cardType = mkproperty(function(self)
	return self.cardProperties.cardType;
end, function ( self, _, value )
	self:updateView({cardType = value});
end)

CardView.cardValue = mkproperty(function(self)
	return self.cardProperties.cardValue;
end, function ( self, _, value )
	self:updateView({cardValue = value});
end)

CardView.cardByte = mkproperty(function(self)
	return self.cardProperties.cardByte;
end, function ( self, _, value )
	self:updateView({cardByte = value});
end)

CardView.cardStyle = mkproperty(function(self)
	return self.cardProperties.cardStyle;
end, function ( self, _, value )
	self:updateView({cardStyle = value});
end)


local function getCardPath(data)
    local cardType;
    local cardValue;

    local function getPathFormTypeAndValue(curType, curValue)
        local colorPath;
        local smallColorPath;
        local valuePath;

        if curType == 0 or curType == 2 then
            valuePath = "red_".. curValue .. ".png";
            colorPath = "color_" .. curType + 1 .. ".png";
            if curValue >= 11 then
                colorPath = "red_man_" .. curValue .. ".png";
            end
            smallColorPath = "color_" .. curType + 1 .. "_small.png";
        elseif curType == 1 or curType == 3 then
            valuePath = "black_" .. curValue .. ".png";
            colorPath = "color_" .. curType + 1 .. ".png";
            if curValue >= 11 then
                colorPath = "black_man_" .. curValue .. ".png";
            end
            smallColorPath = "color_" .. curType + 1 .. "_small.png";
        elseif curType == 4 then
            if curValue == 1 then
                valuePath = "small_joker_word.png";
                colorPath = "small_joker.png";
            elseif curValue == 2 then
                valuePath = "big_joker_word.png";
                colorPath = "big_joker.png";
            end
        end   
        return {valuePath = valuePath, smallColorPath = smallColorPath, colorPath = colorPath};
    end

    if data.cardByte then
        cardType = Bit:brShift(data.cardByte, 4);
        cardValue = Bit:band(data.cardByte, 0x0f);
        return getPathFormTypeAndValue(cardType, cardValue);
    end
    if data.cardType and data.cardValue then
        return getPathFormTypeAndValue( data.cardType,  data.cardValue);
    end
end

--[[
   获取cardImg节点：
   1. 优先判断是否已存在此节点，存在则返回true,并同时返回该节点
   2. 假如未存在此节点，则需要创建此节点并返回false,同时返回该节点 
--]]
local function updateCardImageNodes(self, cardPath)
    local frameCache;
    local cardImg = self:getChildByName("cardImg");
    local cardImgPath = self.cardProperties.cardStyle == "liang" and "bg.png" or "bg_an.png";
    if cardImg then
        cardImg:setSpriteFrame(cardImgPath);
    else
        frameCache = cc.SpriteFrameCache:getInstance();
        frameCache:addSpriteFrames("Images/JrueZhu/CardResource/cards.plist") 
        cardImg = cc.Sprite:createWithSpriteFrameName(cardImgPath);

    end

    local bgHeight = cardImg:getContentSize().height;
    local bgWidth = cardImg:getContentSize().width;
    local valueImg = cardImg:getChildByName("valueImg");
    if cardPath.valuePath then
        if valueImg then
            valueImg:setSpriteFrame(cardPath.valuePath);
        else
            valueImg = cc.Sprite:createWithSpriteFrameName(cardPath.valuePath);
            valueImg:setAnchorPoint(0, 1);
            valueImg:setPosition(10, bgHeight - 10);
            cardImg:addChild(valueImg, 0, "valueImg");
        end
        valueImg:setVisible(true);
    end

    local valueImageWith = valueImg:getContentSize().width;
    local valueImageHeight = valueImg:getContentSize().height;
    local smallColorImg = cardImg:getChildByName("smallColorImg");
    if cardPath.smallColorPath then
        if smallColorImg then
            smallColorImg:setSpriteFrame(cardPath.smallColorPath);
        else
            smallColorImg = cc.Sprite:createWithSpriteFrameName(cardPath.smallColorPath);
            smallColorImg:setAnchorPoint(0, 1);
            smallColorImg:setPosition(10, bgHeight - valueImageHeight - 15);
            cardImg:addChild(smallColorImg, 0, "smallColorImg");
        end
        smallColorImg:setVisible(true);
    else
        if smallColorImg then
            smallColorImg:setVisible(false);
        end
    end

    local colorImg = cardImg:getChildByName("colorImg");
    if cardPath.colorPath then
        if colorImg then
            colorImg:setSpriteFrame(cardPath.colorPath);
        else
            colorImg = cc.Sprite:createWithSpriteFrameName(cardPath.colorPath);
            colorImg:setAnchorPoint(0.5, 0.5);
            colorImg:setPosition(bgWidth/2, bgHeight/2);
            cardImg:addChild(colorImg, 0, "colorImg");
        end
        colorImg:setVisible(true);
    end

    if self.cardProperties.cardStyle == "an" then
        valueImg:setVisible(false);
        smallColorImg:setVisible(false);
        colorImg:setVisible(false);
    end

    return cardImg;
end

--[[
  初始化数据表，维持此份数据表，并实时保持表数据是最新的  
--]]
local function initData(self)
    self.cardProperties = {
		cardType = 0,
		cardValue = 1,
		cardByte = 0x01,
		cardStyle = "liang",
	}
end

local function checkLegalData(self, data)
    if data then
        -- 优先将获取到data数据更新到self.cardProperties表中，维持此份数据表的数据处于最新状况
        -- 其中data的数据可能是 cardType, cardValue, cardType的组合或者单一数据
        if data.cardByte and type(data.cardByte) == "number" then
            data.cardType = Bit:brShift(data.cardByte, 4);
            data.cardValue = Bit:band(data.cardByte, 0x0f);
        end
        if data.cardType and type(data.cardType) == "number" then
            if not data.cardValue then
				data.cardValue = self.cardProperties.cardValue;
			end
            self.cardProperties.cardType = data.cardType;
        end
        if data.cardValue and type(data.cardValue) == "number" then
            if not data.cardType then
                data.cardType = self.cardProperties.cardType;
            end
            self.cardProperties.cardValue = data.cardValue;
        end
        self.cardProperties.cardByte = Bit:toByte(self.cardProperties.cardType, self.cardProperties.cardValue);
        if data.cardStyle and type(data.cardStyle) == "string" then
            self.cardProperties.cardStyle = data.cardStyle;
        end

        -- 对处理后的self.cardProperties数据进行合法性检验，一旦检测出数据不符合需求的情况，则报错提醒

        dump(self.cardProperties, "self.cardProperties------->")

        local cardType = self.cardProperties.cardType;
        local cardValue = self.cardProperties.cardValue;
        local cardByte = self.cardProperties.cardByte;
        local cardStyle = self.cardProperties.cardStyle;
        local limitedMaxValue = 14;
        if cardType == 4 then
            limitedMaxValue = 3;
        end 

        if cardType then
            if type(cardType) ~= "number" or (type(cardType) == "number" and (cardType < 0 or cardType >= 5)) then
                error(string.format("参数不合法---> cardType == %d"), cardType);
            end
        end
        if cardValue then
            if type(cardValue) ~= "number" or (type(cardValue) == "number" and (cardValue <= 0 or cardValue >= limitedMaxValue)) then
                error(string.format("参数不合法---> cardValue == %d"), cardValue);
            end
        end
        if cardStyle then
            if type(cardStyle) ~= "string" or (type(cardStyle) == "string" and (cardStyle ~= "liang" and cardStyle ~= "an")) then
                error("cardStyle参数不合法！！！")
            end 
        end
    end
end

--[[
    更新数据  
--]]
function CardView:updateView(data)
    if data then
        -- 优先做数据合法性校验
        checkLegalData(self, data); 
        -- 其次获取图片路径
        local cardPath = getCardPath(self.cardProperties);
        -- 最后开始创建节点，这里创建节点的方式是，如果已存在对应的节点，则直接从替换图片，如果没有则从精灵帧缓存中创建图片
        return updateCardImageNodes(self, cardPath);
    end
end

function CardView:ctor(data)
    -- 设置peer元表
    setPeerSemetable(self);
    -- 初始化数据表
    initData(self);
    -- 更新View并把各个节点加到CardView中
    self:addChild(self:updateView(data), 0, "cardImg");
end

return CardView;