local SszViewCtr = class("SszViewCtr",cc.load("boyaa").mvc.BoyaaCtr);
local SszView = require("app.demo.DowneyTang.CapsaSusun.SszView")
local Paixing = require("app.demo.DowneyTang.CapsaSusun.Paixing")

function SszViewCtr:ctor() 
	print("SszViewCtr");
end

local byteMap = {
	--【第1组牌Byte值】
	{0x13,0x14,0x15,},

	--【第2组牌Byte值】
	{0x31,0x3a,0x3b,0x3c,0x3d,},

	--【第3组牌Byte值】
	{0x23,0x24,0x25,0x26,0x27,},
}

function SszViewCtr:getByteMap(byteMap)
	if byteMap then
		print("...................接收数据...................")
		dump(byteMap)
		local data = {}
		local dataCheck = {}
		local newPaixing = Paixing.new()
		for i = 1, #byteMap do
			data[i] = newPaixing:check(byteMap[i])
		end
		dump(data)
		if data[3] > data[2] then
			if data[2] > data[1] then
				dataCheck[1], dataCheck[2], dataCheck[3] = true, true , true
			elseif data[2] < data[1] then
				if  data[3] < data[1] then
					dataCheck[1], dataCheck[2], dataCheck[3] = nil
				elseif data[3] > data[1] then
					dataCheck[1], dataCheck[2] = nil
					dataCheck[3] = true
				end
			end
		elseif  data[3] < data[2] then 
			if data[3] <data[1] then 
				dataCheck[1], dataCheck[2], dataCheck[3] = nil
			elseif data[3] >data[1] then
				dataCheck[1] = true
				dataCheck[2], dataCheck[3] = nil
			end
		end
		self:getView():cardJudge(dataCheck, data)
		data = nil
	end
end

function SszViewCtr:initView(isBehavior)
    local newSszView = SszView.new();
    newSszView:init(byteMap)
	if isBehavior == 1 then
    	newSszView:bindBehavior(newSszViewBehavior);
	elseif isBehavior == 2 then
    	newSszView:bindBehavior(newSszViewObserverBehavior);	
    end  
	newSszView:bindCtr(self);

	-- local node = cc.Node:create();
	-- newSszView:addTo(node)
	-- self:setView(newSszView)
end

return SszViewCtr;