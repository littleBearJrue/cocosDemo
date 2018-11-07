--[[--ldoc desc
@Module Clock.lua
@Author AeishenLin

Date: 2018-10-22 18:43:44
Last Modified by: AeishenLin
Last Modified time: 2018-10-22 18:58:30
]]

local mkproprety = function(getFun, setFun)
	local instance = {proprety = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
		error(1)
	end})
	return instance
end

local Clock = class("Clock",function ()
	return cc.Sprite:create("Images/AeishenLin/clock_bg_poker.png")
end)

function Clock:ctor()
    local peer = tolua.getpeer(self)                                                                       --每个C++对象需要存贮自己的成员变量的值，这个值不能够存贮在元表里(因为元表是类共用的)，所以每个对象要用一个私有的表来存贮，这个表在tolua里叫做peer表。元表的__index指向了一个C函数，当在Lua中要访问一个C++对象的成员变量(准确的说是一个域)时，会调用这个C函数，在这个C函数中，会查找各个关联表来取得要访问的域，这其中就包括peer表的查询。 
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
    self._data = {_timeText = 15}
    self:initTimeText()
end

---闹钟数值初始化
function Clock:initTimeText()
    self.clockTimeText = ccui.Text:create(self._data._timeText,"Arial",18)
	self:addChild(self.clockTimeText)
	self.clockTimeText:setPosition(cc.p(self:getContentSize().width/2 , self:getContentSize().height/2 ))
    self.clockTimeText:setColor(cc.c3b(255,210,0))
end

---闹钟数值
Clock.timeText = mkproprety(function(self)
	return self._data._timeText
end,function(self, timeText)
    self._data._timeText = timeText
	self:update({_timeText = timeText})
end)

function Clock:update(data)
    if data._timeText then
        self.clockTimeText:setString(data._timeText)
	end
end


return Clock
