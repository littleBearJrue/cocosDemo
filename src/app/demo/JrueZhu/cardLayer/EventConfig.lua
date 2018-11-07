--[[--ldoc desc
@module EventConfig
@author JrueZhu

Date   2018-10-29 11:47:52
Last Modified by   JrueZhu
Last Modified time 2018-10-29 14:24:31
]]

local EventConfig = {};

EventConfig.EventFuncConfig = {
	outCard = "executeOutCard",
	grapCard = "executeGrapCard",
	outCardUpdateDisCard = "updateDiscardAfterOutCard",
};

EventConfig.EventNameConfig = {
	outCard = "outCard",
	grapCard = "grapCard",
};

return EventConfig;
