local Chip = class("Chip", function()
	local chipImg = ccui.ImageView:create("DowneyTang/koprokdice/chip_btn%d.png")
    return chipImg 
end)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
BehaviorExtend(Chip);

--筹码移动
function Chip:chipMove(startPos, endPos)
	
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


--设置筹码金额
Chip.chipValue = mkproprety(function(self)
	return self._data.chip
end,function(self, chipValue)
	self._data.chip = chipValue
	self:update({chip = chipValue})
end)

function Chip:update(data)
	if data.chip then
		print("updateChip", data.chip)
        self:loadTexture(string.format("DowneyTang/koprokdice/chip_btn%d.png",data.chip))
	end
end


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
        chip = 1,
	}
end

return Chip;