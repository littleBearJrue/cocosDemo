--[[--ldoc desc
@Module Chip.lua
@Author JasonLiu

Date: 2018-10-22 16:51:14
Last Modified by: JasonLiu
Last Modified time: 2018-10-22 17:16:31
]]

local Chip = class("Chip", cc.Node)

function Chip:ctor(value, type)
    self:initView(value, type)
end

--[[
    @function initView      初始化View
    @param #value int       筹码的值
    @param #type int        筹码的类型 大：0 小 1
]] 
function Chip:initView(value, type)
	self._data = {
        value = value or 1,
        type = type or 0,
	}
    local chipTexture = cc.SpriteBatchNode:create("Images/chip/dice_chip.png"):getTexture()
    if self._data.type == 1 then
        self.chip = self:getSmallChip(chipTexture, self._data.value)
    else
        self.chip = self:getBigChip(chipTexture, self._data.value)
    end
    self:addChild(self.chip)
end

function Chip:getBigChip(chipTexture, value)
    local map = {
        [1] = 9, [2] = 3, [3] = 6, [4] = 2, [5] =  8, [6] = 7, [7] = 5, [8] = 4,
    }
    local l = math.modf( map[value] / 3 )
    local m = math.fmod( map[value] , 3 )
    if m == 0 then
        m = 3
        l = l - 1
    end
    local chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(6 + 42 * (m - 1), 6 + 42 * l, 31, 31))

    return chip
end

function Chip:getSmallChip(chipTexture, value)
    local map = {
        [1] = 5, [2] = 1, [3] = 6, [4] = 2, [5] =  7, [6] = 3, [7] = 8, [8] = 4,
    }
    local l = math.modf( map[value] / 2 )
    local m = math.fmod( map[value] , 2 )
    if m == 0 then
        m = 2
        l = l - 1
    end
    local chip = cc.Sprite:createWithTexture(chipTexture, cc.rect(128 + 17 * (m - 1), 44 + 17 * l, 14, 14))

    return chip
end

return Chip