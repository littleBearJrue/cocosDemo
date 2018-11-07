--[[--ldoc desc
@module ClockCountDown
@author JrueZhu

Date   2018-11-01 19:21:54
Last Modified by   JrueZhu
Last Modified time 2018-11-01 20:43:47
]]
local ClockCountDown  = class("ClockCountDown", function()
     local layout = ccui.Layout:create();
     layout:setLayoutType(ccui.LayoutType.RELATIVE)
     return layout;
end)

local clockBgPath = "Images/JrueZhu/countdown_bg.png";
local clockProgressPath = "Images/JrueZhu/countdown_green.png";

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
		if type(ClockCountDown[k]) == "table" and ClockCountDown[k].property == true then
			return ClockCountDown[k].get(object)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(ClockCountDown[k]) == "table" and ClockCountDown[k].property == true then
			return ClockCountDown[k].set(object, k, v)
		else
			rawset(_, k, v)
		end
	end
end

ClockCountDown.timer = mkproperty(function(self)
	return self.timeData.timer;
end, function ( self, _, value )
	self:updateView({timer = value});
end)


function ClockCountDown:ctor(data)
	setPeerSemetable(self);

	self.timeData = {
		timer = 60;
	}

	self:updateView(data);

	local entry;
	local function update(dt)
        if self.timeData.timer > 0 then
            self.timeData.timer = self.timeData.timer - dt;
            local numLabel = self:getChildByTag(3);
			numLabel:setString(tostring(self.timeData.timer))
        else
 			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(entry);
			if self.listener then
				self.listener();
			end
        end
    end
	entry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
end

function ClockCountDown:setTimeEndListener(func)
	self.listener = func;
end

local function checkLegalData(self, data)
	if data then
		if data.timer and type(data.timer) ~= "number" then
			error("传入的时间参数不合法！！！")
		else
			self.timeData.timer = data.timer;
		end
	end
end

function ClockCountDown:updateView(data)
	checkLegalData(self, data);
	local countDownBg = cc.Sprite:create(clockBgPath);
	countDownBg:setAnchorPoint(0.5, 0.5);
	self:addChild(countDownBg, 0, 1);

	local clockProgress = self:getChildByTag(2);
	if clockProgress then
		local to = cc.ProgressTo:create(data.timer, 0);
		clockProgress:runAction(cc.RepeatForever:create(to));
	else
		local progressImg = cc.Sprite:create(clockProgressPath);
		clockProgress = cc.ProgressTimer:create(progressImg);
		clockProgress:setPercentage(100);
		clockProgress:setReverseProgress(true);
		local to = cc.ProgressTo:create(data.timer, 0);
		clockProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL);
		clockProgress:runAction(cc.RepeatForever:create(to));
		clockProgress:setAnchorPoint(0.5, 0.5);
		self:addChild(clockProgress, 0, 2);
	end

	local numLabel = self:getChildByTag(3);
	if numLabel then
		numLabel:setString(tostring(data.timer));
	else
		numLabel = cc.Label:createWithSystemFont(tostring(data.timer), "Arial", 35);
		numLabel:setAnchorPoint(0.5, 0.5);
		self:addChild(numLabel, 0, 3)
	end
end

return ClockCountDown;