local ChipBehavior = class("ChipBehavior",cc.load("boyaa").behavior.BehaviorBase);

local exportInterface = {
    -- "updateView",
    "chipMove",
}

function ChipBehavior:chipMove(object,startPos, endPos)
    object:setPosition(startPos)
    local rotate = cc.RotateBy:create(0.5, 360)
    local moveTo = cc.MoveTo:create(0.5, endPos)
    local spawn = cc.Spawn:create(rotate, moveTo)
    object:runAction(spawn)
end


function ChipBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true,false);
        -- object:bindMethod(self, v, handler(self, self[v]));
    end 
end

function ChipBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end


return ChipBehavior;