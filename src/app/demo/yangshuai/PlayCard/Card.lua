--[[--ldoc desc
@module Card
@author ShuaiYang

Date   2018-10-24 17:43:45
Last Modified by   ShuaiYang
Last Modified time 2018-10-24 17:47:33
]]
local Card = class("Card");

function Card:ctor(data)
	data = checktable(data)
	self.tByte = nil;
	self.value = nil;
	self.type = nil;

	if data.tByte then
		self.tByte = data.tByte;
		
	end
end


return Card;