local mkproprety = function(getFun, setFun)
	local instance = {proprety = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
		error(1)
	end})
	return instance
end

---筹码图片资源路径
local ChipFilePath = {
	[1] = "Images/AeishenLin/chip/chip_btn1.png",
	[2] = "Images/AeishenLin/chip/chip_btn2.png",
    [3] = "Images/AeishenLin/chip/chip_btn3.png",
	[4] = "Images/AeishenLin/chip/chip_btn4.png",  
}

local ChipRealValue = {
	[1] = "100k",
	[2] = "500k",
    [3] = "1m",
	[4] = "5m",  
}

local Chip = class("Chip", function ()
    return cc.Sprite:create("Images/AeishenLin/1.png")
end)

function Chip:ctor()
    local peer = tolua.getpeer(self)
	local mt = getmetatable(peer)
	local __index = mt.__index
	mt.__index = function(_, k)
		if type(Chip[k]) == "table" and Chip[k].proprety == true then
			return Chip[k].get(self)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(Chip[k]) == "table" and Chip[k].proprety == true then
			return Chip[k].set(self, v)
		else
			rawset(_, k, v)
		end
    end
    self._data = { 
		_tag = 1,
		_userId = nil,
    }
    self:setScale(0.3,0.3)
end


---筹码tag
Chip.tag = mkproprety(function(self)
	return self._data._tag
end,function(self, tag)
    self._data._tag = tag
	self:update({_tag = tag})
end)

---筹码归属者（属于哪个玩家下注的）
Chip.userId = mkproprety(function(self)
	return self._data._userId
end,function(self, userId)
    self._data._userId = userId
end)

---筹码面值
Chip.realValue = mkproprety(function(self)
	return ChipRealValue[self._data._tag]
end)

function Chip:update(data)
    if data._tag then
        for chipValue, chipPath in pairs(ChipFilePath) do
            if chipValue == data._tag then
                self:setTexture(chipPath) 
            end
        end 
	end
end

return Chip





























-- Chip.money = mkproprety(function(self)
-- end,function(self, money)
--     for _, value in ipairs(ChipValue) do
--         if money >= value then 
--             local chip_counts, surplus = math.modf( money / value )
--             table.insert(self._data._money, value, chip_counts)
--             money = surplus * value
--         end
--     end
--     if self._data._money then 
--         self:setChipSprite(self._data._money)
--     end
-- end)

-- function Chip:setChipSprite(chipValue_Count)
--     for value, count in pairs(chipValue_Count) do
--         for _value, path in pairs(ChipFilePath) do
--             if value ==  tonumber(_value) then   
--                 if count == 1 then 
--                     local chipSprite = cc.Sprite:create(path)
--                     chipSprite:setTag(value)
--                     self:addChild(chipSprite)
--                 else
--                     for i = 1, count do
--                         local chipSprite = cc.Sprite:create(path)
--                         chipSprite:setTag(value)
--                         self:addChild(chipSprite)
--                     end
--                 end
--             end
--         end
--     end
-- end

