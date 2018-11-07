local DeskViewBehavior = class("DeskViewBehavior",cc.load("boyaa").behavior.BehaviorBase);
local Chip = require("app.demo.DowneyTang.Chip");
local ChipBehavior =  require("app.demo.DowneyTang.ChipBehavior")

local exportInterface = {
    -- "updateView",
    "addTouchSpace",
}

local chipValue_ = nil
local listener = cc.EventListenerCustom:create("setChipValue_event",function(event)
	dump("event._usedata = "..event._usedata)
	chipValue_ = event._usedata
end)
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()--添加触摸监听器
eventDispatcher:addEventListenerWithFixedPriority(listener, 1)--【参数1:Listenter监听器参数】【参数2:fixedPriority固定优先级0是系统占有，不能设置为0】

--给牌桌添加不同的触摸区域
function DeskViewBehavior:addTouchSpace(object, spaceMap)
	for i = 1, #spaceMap do
		local space = ccui.ImageView:create("Images/CyanSquare.png")
		space:setOpacity(0)
		space:setScaleX(spaceMap[i].scaleX)
		space:setScaleY(spaceMap[i].scaleY)
		-- space:setAnchorPoint(0, 1)
		space:setPosition(spaceMap[i].position)
		space:setTouchEnabled(true)
		local function touchEvent(touches,eventType)
			if eventType == ccui.TouchEventType.began then
				local newChip = Chip.new();
				newChip:bindBehavior(ChipBehavior);
				newChip.chipValue = chipValue_ or 1
				newChip:setScale(0.3)
				newChip:chipMove(spaceMap[i].startPos, cc.p(math.random(spaceMap[i].endPos[1],spaceMap[i].endPos[2]),math.random(spaceMap[i].endPos[3],spaceMap[i].endPos[4])));
				object:addChild(newChip)
			end
		end  
		space:addTouchEventListener(touchEvent)
		object:addChild(space)
	end
end


function DeskViewBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true,false);
        -- object:bindMethod(self, v, handler(self, self[v]));
    end 
end

function DeskViewBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end


return DeskViewBehavior;