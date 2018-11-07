---事件
local Event = {};

---事件id
local eventID = 1

---获取游戏内唯一事件
Event.getUniqueID = function( ... )
	eventID = eventID + 1
	return "byEvn_" .. tostring(eventID)
end

Event.Resume 		= Event.getUniqueID();	-- 从后台回到app
Event.Pause 		= Event.getUniqueID();	-- app切换到后台
Event.Back 			= Event.getUniqueID();	-- 物理返回键
Event.KeyDown 		= Event.getUniqueID();	-- 键盘按键

return Event;