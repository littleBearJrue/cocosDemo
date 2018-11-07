
local Event = require(".Event");
local dispatcher = require(".EventDispatcher");
local Eevent = {}
Eevent.Event = Event; 
Eevent.EventDispatcher = dispatcher:create();

return Eevent;