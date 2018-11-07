local ChipCompent = 
{
    totalDt = 0,
    shakeDuration = 0.25, 
    clockDuration = 1,
    shakeFalg = false,
    shakeTime = 3;

    onEnter = function(self) 
        local owner = self:getOwner();
        local move = cc.MoveTo:create(0.8,owner.chipPos.endPos)
        math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
        local rotateValue = math.random(0,360)
        local rotate = cc.RotateBy:create(0.8,rotateValue)
        owner:runAction(cc.Spawn:create(move,rotate))
    end,
}

return ChipCompent