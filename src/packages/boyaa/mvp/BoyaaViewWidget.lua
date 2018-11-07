--[[--ldoc desc
@module BoyaaViewWidget
@author ShuaiYang

Date   2018-10-18 12:09:59
Last Modified by   ShuaiYang
Last Modified time 2018-11-01 14:52:04
]]

local BoyaaViewWidget = class("BoyaaViewWidget", cc.Node);
-- BoyaaView[".isclass"] = true;
local BoyaaWidgetExtend  = import(".BoyaaWidgetExtend");
BoyaaWidgetExtend(BoyaaViewWidget)

return BoyaaViewWidget;