local COLORMAP = {
    [0] = "方块";
	[1] = "梅花";
	[2] = "红桃";
	[3] = "黑桃";
}

local normalColorResCreate = {
    {res = "color_%d.png",name = "colorNode",pos = cc.p(52,60)},
    {res = "color_%d_small.png",name = "colorSmallNode",pos = cc.p(18,83)},
}

local mkproperty = function(getFunc, setFunc)
	local instance = {proprety = true}
	instance.get = getFunc
	instance.set = setFunc
    setmetatable(instance, {__newIndex = function()
        --不能被修改
		error("can no set")
	end})
	return instance
end

local Card = class("Card",function()
	return cc.Node:create()
end)

function Card:ctor()
    local peer = tolua.getpeer(self)
	local mt = getmetatable(peer)
	local __index = mt.__index
	mt.__index = function(_, k)
		if type(Card[k]) == "table" and Card[k].proprety == true then
			return Card[k].get(self)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(Card[k]) == "table" and Card[k].proprety == true then
			return Card[k].set(self, v)
		else
			rawset(_, k, v)
		end
	end

    self:initData();
    self:initView();
end

function Card:dtor()
    -- body
end

function Card:initData()
    self.dataConfig = {
        color = 0,
        value = 1,
        reverse = false,
    }
end

function Card:initView()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("Images/jasonhuang/card/textures/card.plist")
    self.bg = cc.Sprite:createWithSpriteFrameName("bg.png")
    self.bg:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.bg)

    self:createColor()
    self:createValue()
end

function Card:createColor()
    local color = self.dataConfig.color
    if color >= 0 and color <= 3 then
        for i,v in ipairs(normalColorResCreate) do
            if not self[v.name] then
                local node = cc.Sprite:createWithSpriteFrameName(string.format(v.res,color + 1))
                self.bg:addChild(node)
                node:setPosition(v.pos)
                self[v.name] = node
            else
                self[v.name]:initWithSpriteFrameName(string.format(v.res,color + 1))
            end
        end  
    end
end

function Card:createValue()
    local pre = self.dataConfig.color % 2 == 0 and "red_" or "black_"
    if not self.valueNode then
        self.valueNode = cc.Sprite:createWithSpriteFrameName(pre..self.dataConfig.value..".png")
        self.valueNode:setPosition(cc.p(18,112))
        self.bg:addChild(self.valueNode)
    else
        self.valueNode:initWithSpriteFrameName(pre..self.dataConfig.value..".png")
    end

    -- JQK
    if self.dataConfig.value > 10 and self.dataConfig.value < 14 then
        self.colorNode:initWithSpriteFrameName(pre.."man_"..self.dataConfig.value..".png")
    else
        self.colorNode:initWithSpriteFrameName(string.format("color_%d.png",self.dataConfig.color + 1))
    end
end

function Card:updateReverse()
    if self.reverse then
        -- 背面
        self.bg:initWithSpriteFrameName("card_back_big.png")
    else
        self.bg:initWithSpriteFrameName("bg.png")
    end
    self.valueNode:setVisible(not self.reverse)
    self.colorNode:setVisible(not self.reverse)
    self.colorSmallNode:setVisible(not self.reverse)
end

Card.value = mkproperty(function( self )
	if self.dataConfig.value then
		return self.dataConfig.value;
	end
end, function ( self, value )
	if self.dataConfig.value ~= value then
		self.dataConfig.value = value
		self:createValue()
	end
end)

Card.color = mkproperty(function( self )
	if self.dataConfig.color then
		return self.dataConfig.color;
	end
end, function ( self, value )
	if self.dataConfig.color ~= value then
		self.dataConfig.color = value
        self:createColor()
        self:createValue()
	end
end)

--正背面
Card.reverse = mkproperty(function( self )
	if self.dataConfig.reverse then
		return self.dataConfig.reverse;
	end
end, function ( self, value )
	if self.dataConfig.reverse ~= value then
		self.dataConfig.reverse = value
		self:updateReverse()
	end
end)

return Card