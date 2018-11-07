--[[
 * @Author: KevinZhang
 * @Date: 2018-10-17 16:19:09
 * @LastEditors: KevinZhang
 * @LastEditTime: 2018-10-26 11:35:02
 ]]



local layoutFile = "creator/Scene/KevinZhang/pokerView.ccreator"
local findViewById = function(node, path)
	local list = string.split(path,"/")
	local findNode = node
	for i, v in ipairs(list) do
		findNode = findNode:getChildByName(v)
	end
	return findNode
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

local controls = {
	cardValue = "bg/value",
	cardColor = "bg/color",
	cardColorSmall = "bg/colorSmall",
}

local CardView = class("CardView", function() 
    local creatorReader = creator.CreatorReader:createWithFilename(layoutFile);
    creatorReader:setup();
	local card = creatorReader:getNodeGraph();
	local self = card:getChildByName("bg")
	for k, v in pairs(controls) do
		self[k] = findViewById(card, v)
	end
	card:removeChild(self)
	return self
end)

function CardView:ctor()
	
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
	self._data = {
		value = 1,
		color = 0,
		byte = 0x01,
	}
end

CardView._value = mkproprety(function(self)
	return self._data.value
end,function(self, value)
	self._data.value = value
	self:update({value = value})
end)

function CardView:update(data)
	if data.value then
		self:updateValue(data.value)
	end
end


function CardView:updateValue(value)
	print("updateValue", value)
	self.cardValue:setSpriteFrame("red_2.png")
end
-- -- mkproprety
-- function CardView:setValue(value)
	
-- end

-- function CardView:setColor(color)
	
-- end

-- function CardView:setByte(byte)
	
-- end
return CardView