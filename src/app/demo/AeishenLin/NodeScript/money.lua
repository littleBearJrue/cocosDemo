local money = {

    isOver = false,
    speed = 3,
    
    onEnter = function(self)

        local director = cc.Director:getInstance()
        local winSize = director:getVisibleSize()
        local visibleOrigin = director:getVisibleOrigin()

        local owner = self:getOwner()
        local contentSize = owner:getContentSize()


        local minX = contentSize.width / 2
        local maxX = winSize.width - contentSize.width/2
        local rangeX= maxX - minX
        math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)))
        local actualX = math.random(1000) % rangeX + minX
        owner:setPosition(visibleOrigin.x + actualX , winSize.height + contentSize.height/2)


        local minDuration = 1;   
        local maxDuration = 4;
        local rangeDuration = maxDuration - minDuration
        local actualDuration = math.random(1000) % rangeDuration + minDuration

        local actionMove = cc.MoveTo:create( self.speed * actualDuration, cc.p(actualX,0 - contentSize.height))

        -- ---获取mainControl.lua脚本组件
        local controlComponent = tolua.cast(owner:getParent():getComponent("ControlComponent"), "cc.ComponentLua") --强制转换对象类型,tolua.cast(对象, 类型名称) 
        local control = controlComponent:getScriptObject()
        
        local function destorySelf()
            self.isOver = true;
        end
        local actionMoveDone = cc.CallFunc:create(destorySelf)
        owner:runAction(cc.Sequence:create(actionMove, actionMoveDone))
    end,
 
}

return money