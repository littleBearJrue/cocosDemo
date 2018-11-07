--[[--ldoc desc
@module SingleCardView
@author JrueZhu

Date   2018-10-24 10:55:28
Last Modified by   JrueZhu
Last Modified time 2018-10-30 11:00:27
]]

local Bit = require("app.demo.JrueZhu.Bit");

local SingleCardView  = class("SingleCardView", function()
     local layout = ccui.Layout:create();
     layout:setLayoutType(ccui.LayoutType.RELATIVE)
     return layout;
end)

local CHILD_TAG = {
    CARD_IMG = 1,
    VALUE_IMG = 2,
    COLOR_IMG = 3,
    SMALL_COLOR_IMG = 4,
}

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
		if type(SingleCardView[k]) == "table" and SingleCardView[k].property == true then
			return SingleCardView[k].get(object)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(SingleCardView[k]) == "table" and SingleCardView[k].property == true then
			return SingleCardView[k].set(object, k, v)
		else
			rawset(_, k, v)
		end
	end
end

SingleCardView.cardType = mkproperty(function(self)
	return self.cardProperties.cardType;
end, function ( self, _, value )
	self:updateView({cardType = value});
end)

SingleCardView.cardValue = mkproperty(function(self)
	return self.cardProperties.cardValue;
end, function ( self, _, value )
	self:updateView({cardValue = value});
end)

SingleCardView.cardByte = mkproperty(function(self)
	return self.cardProperties.cardByte;
end, function ( self, _, value )
	self:updateView({cardByte = value});
end)

SingleCardView.cardStyle = mkproperty(function(self)
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
            colorPath = "poker_big_" .. curType + 1 .. ".png";
            if curValue >= 11 then
                colorPath = "poker_red_" .. curValue .. ".png";
            end
            smallColorPath = "poker_small_" .. curType + 1 .. ".png";
        elseif curType == 1 or curType == 3 then
            valuePath = "black_" .. curValue .. ".png";
            colorPath = "poker_big_" .. curType + 1 .. ".png";
            if curValue >= 11 then
                colorPath = "poker_black_" .. curValue .. ".png";
            end
            smallColorPath = "poker_small_" .. curType + 1 .. ".png";
        -- elseif curType == 4 then
        --     if curValue == 1 then
        --         valuePath = "small_joker_word.png";
        --         colorPath = "small_joker.png";
        --     elseif curValue == 2 then
        --         valuePath = "big_joker_word.png";
        --         colorPath = "big_joker.png";
        --     end
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
    -- 设置为相对布局

    local frameCache;
    local cardImg = self:getChildByTag(CHILD_TAG.CARD_IMG);
    local cardImgPath = self.cardProperties.cardStyle == "liang" and "poker_front_bg.png" or "poker_back_blue.png";
    if cardImg then
        cardImg:loadTexture(cardImgPath, ccui.TextureResType.plistType);
    else
        frameCache = cc.SpriteFrameCache:getInstance();
        frameCache:addSpriteFrames("Images/JrueZhu/pokerGame/cards.plist")

        cardImg = ccui.ImageView:create(cardImgPath, ccui.TextureResType.plistType)
        self:setContentSize(cardImg:getContentSize());

        local parameter = ccui.RelativeLayoutParameter:create()
        parameter:setAlign(ccui.RelativeAlign.centerInParent)
        cardImg:setLayoutParameter(parameter)

        self:addChild(cardImg, 0, CHILD_TAG.CARD_IMG);
    end

    local valueImg = self:getChildByTag(CHILD_TAG.VALUE_IMG);
    if cardPath.valuePath then
        if valueImg then
            valueImg:loadTexture(cardPath.valuePath, ccui.TextureResType.plistType);
        else
            valueImg = ccui.ImageView:create(cardPath.valuePath, ccui.TextureResType.plistType);

            local parameter = ccui.RelativeLayoutParameter:create()
            parameter:setRelativeName("valueImg")
            parameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
            parameter:setMargin({ left = 5, top = 5 } )
            valueImg:setLayoutParameter(parameter)
            self:addChild(valueImg, 0, CHILD_TAG.VALUE_IMG);
        end
        valueImg:setVisible(true);
    end

    local smallColorImg = self:getChildByTag(CHILD_TAG.SMALL_COLOR_IMG);
    if cardPath.smallColorPath then
        if smallColorImg then
            smallColorImg:loadTexture(cardPath.smallColorPath, ccui.TextureResType.plistType);
        else
            smallColorImg = ccui.ImageView:create(cardPath.smallColorPath, ccui.TextureResType.plistType);

            local parameter = ccui.RelativeLayoutParameter:create()
            parameter:setRelativeToWidgetName("valueImg")
            parameter:setAlign(ccui.RelativeAlign.locationBelowLeftAlign)
            parameter:setMargin({ left = 0, top = 5 } )
            smallColorImg:setLayoutParameter(parameter)
            self:addChild(smallColorImg, 0, CHILD_TAG.SMALL_COLOR_IMG);
        end
        smallColorImg:setVisible(true);
    else
        if smallColorImg then
            smallColorImg:setVisible(false);
        end
    end

    local colorImg = self:getChildByTag(CHILD_TAG.COLOR_IMG);
    if cardPath.colorPath then
        if colorImg then
            colorImg:loadTexture(cardPath.colorPath, ccui.TextureResType.plistType);
        else
            colorImg = ccui.ImageView:create(cardPath.colorPath, ccui.TextureResType.plistType);
            colorImg:setAnchorPoint(1, 0);
            local parameter = ccui.RelativeLayoutParameter:create()
            parameter:setAlign(ccui.RelativeAlign.alignParentRightBottom)
            parameter:setMargin({right = 10, bottom = 10})
            colorImg:setLayoutParameter(parameter)
            self:addChild(colorImg, 0, CHILD_TAG.COLOR_IMG);
        end
        colorImg:setVisible(true);
    end

    if self.cardProperties.cardStyle == "an" then
        valueImg:setVisible(false);
        smallColorImg:setVisible(false);
        colorImg:setVisible(false);
    end

    -- 刷新下布局
    self:requestDoLayout()
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
        local cardType = self.cardProperties.cardType;
        local cardValue = self.cardProperties.cardValue;
        local cardByte = self.cardProperties.cardByte;
        local cardStyle = self.cardProperties.cardStyle;
        local limitedMaxValue = 14;
        -- if cardType == 4 then
        --     limitedMaxValue = 3;
        -- end 

        if cardType then
            if type(cardType) ~= "number" or (type(cardType) == "number" and (cardType < 0 or cardType >= 4)) then
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
function SingleCardView:updateView(data)
    if data then
        -- 优先做数据合法性校验
        checkLegalData(self, data); 
        -- 其次获取图片路径
        local cardPath = getCardPath(self.cardProperties);
        -- 最后开始创建节点，这里创建节点的方式是，如果已存在对应的节点，则直接从替换图片，如果没有则从精灵帧缓存中创建图片
        updateCardImageNodes(self, cardPath);
    end
end

function SingleCardView:ctor(data)
    -- 设置peer元表
    setPeerSemetable(self);
    -- 初始化数据表
    initData(self);
    -- 更新View并把各个节点加到CardView中
    self:updateView(data)
end

return SingleCardView;