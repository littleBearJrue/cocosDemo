--[[--ldoc desc
@Module Clock.lua
@Author JasonLiu

Date: 2018-10-19 11:54:04
Last Modified by: JasonLiu
Last Modified time: 2018-10-22 16:20:58
]]
local Clock = class("Clock", cc.Node)

local defaultImgPath = "Images/clock/clock_default.png"
local defaultCount = 10

local mkproprety = function(getFun, setFun)
	local instance = {proprety = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
		error(1)
	end})
	return instance
end

function Clock:initMetatable()
    local peer = tolua.getpeer(self)
	local mt = getmetatable(peer)
	local __index = mt.__index
	mt.__index = function(_, k)
		if type(Clock[k]) == "table" and Clock[k].proprety == true then
			return Clock[k].get(self)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(Clock[k]) == "table" and Clock[k].proprety == true then
			return Clock[k].set(self, v)
		else
			rawset(_, k, v)
		end
	end
	self._data = {
        count = defaultCount,
        imgPath = defaultImgPath,
	}
end

Clock._count = mkproprety(function(self)
	return self._data.count
end,function(self, count)
	self._data.count = count
	self:update({count = count})
end)

Clock._imgPath = mkproprety(function(self)
	return self._data.imgPath
end,function(self, imgPath)
	self._data.imgPath = imgPath
	self:update({imgPath = imgPath})
end)

function Clock:update(data)
	if data.count then
        self:setCount(data.count)
    elseif data.imgPath then
        self:setImgPath(data.imgPath)
	end
end

function Clock:setCount(count)
	self._data.count = count
    self.time:setString(count)
end

function Clock:setImgPath(imgPath)
	self._data.imgPath = imgPath
    self.bg:setTexture(imgPath)
end

function Clock:ctor(imgPath, count)
    self:initView(imgPath, count)
    
    self:initMetatable()
end

--[[
    @function initView      初始化View
    @param #imgPath string  背景图片路径
    @param #count int       计数值
]] 
function Clock:initView(imgPath, count)
	self.bg = cc.Sprite:create(imgPath or defaultImgPath)
    self.time = cc.Label:createWithSystemFont(count or defaultCount, "American", 22)

    self:addChild(self.bg)
    self:addChild(self.time)	
end

--[[
    @function countdown         开始倒计时
    @param #callback function   回调函数
    @param #count int           计数值
    @param #isPlayAnim bool     是否播放动画
]] 
function Clock:countdown(callback, count, isPlayAnim)
	print("Clock countdown")
    local c = count or self._data.count or defaultCount
    self:stopActions()
	self.time:setString(c)
    schedule(self.time, function()  
        c = c - 1
        self.time:setString(c)
        if c == 0 then
			self:stopActions()
			callback()
		elseif c == 3 and isPlayAnim then
			self.bg:runAction(self:defaultAnim())
		end
    end, 1)  
end

--[[
    @function stopActions       停止所有动作
]] 
function Clock:stopActions()
	self.time:stopAllActions()
	self.bg:stopAllActions()
	self.bg:setTexture(self._data.imgPath)
end

--[[
    @function defaultAnim       默认动画
]] 
function Clock:defaultAnim()
	local animation = cc.Animation:create()
	animation:addSpriteFrameWithFile("Images/clock/clock_anim_1_1.png")
	animation:addSpriteFrameWithFile("Images/clock/clock_anim_1_2.png")
	-- should last 2.8 seconds. And there are 14 frames.
	animation:setDelayPerUnit(2 * 0.1 / 2)
	animation:setRestoreOriginalFrame(true)
	local action = cc.Animate:create(animation)

	return cc.RepeatForever:create(cc.Sequence:create(action, action:reverse()))
end

function Clock:setVisible(visible)
	self.bg:setVisible(visible)
	self.time:setVisible(visible)
end

function Clock:getContentSize()
	return self.bg:getContentSize()
end

return Clock