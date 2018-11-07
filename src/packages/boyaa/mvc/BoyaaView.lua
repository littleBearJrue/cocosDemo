--[[--ldoc desc
@module BoyaaView
@author ShuaiYang

Date   2018-10-18 12:09:59
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 10:50:20
]]

local BoyaaView = class("BoyaaView", cc.Node);
-- BoyaaView[".isclass"] = true;
local BoyaaWidgetExtend  = import(".BoyaaWidgetExtend");
BoyaaWidgetExtend(BoyaaView)

return BoyaaView;