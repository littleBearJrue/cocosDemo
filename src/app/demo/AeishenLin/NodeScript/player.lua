
local visibleSize = cc.Director:getInstance():getVisibleSize();
local origin = cc.Director:getInstance():getVisibleOrigin();

local Player = {

    onEnter = function(self)   
        local owner = self:getOwner()
        local function onKeyPressed(keyCode, event)
            local move = nil
            local x,y = owner:getPosition()
            if keyCode == 124 and x > origin.x + owner:getContentSize().width then
                owner:setTexture("Images/grossini_dance_06.png")
                move = cc.MoveBy:create(0.4,cc.p(-30,0))
            elseif keyCode == 127 and x < visibleSize.width - owner:getContentSize().width then 
                owner:setTexture("Images/grossini_dance_10.png")
                move = cc.MoveBy:create(0.4,cc.p(30,0))
            elseif keyCode == 59 then
                owner:setTexture("Images/grossini_dance_05.png")
                move = cc.JumpBy:create(0.4,cc.p(0,0), 80, 1)
            else
                return
            end
            owner:runAction(move)  
        end

        local function onKeyReleased(keyCode, event)
            if keyCode == 124 or keyCode == 127 or keyCode == 59 then
                owner:setTexture("Images/grossini.png")
            else
                return
            end
        end
    
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED )
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener,owner)  --为具有场景图优先级的指定事件添加事件侦听器。
    end,

    update = function(self, dt)
        local owner = self:getOwner()
        
        -- ---获取mainControl.lua脚本组件
        local controlComponent = tolua.cast(owner:getParent():getComponent("ControlComponent"), "cc.ComponentLua") --强制转换对象类型,tolua.cast(对象, 类型名称) 
        local control = controlComponent:getScriptObject()

        local money = control.money
        local enemies = control.enemies

        for i = #money, 1, -1 do
            local mon = money[i]
            if tolua.isnull(owner) or tolua.isnull(mon) then
                return 
            end 
            if cc.rectIntersectsRect(owner:getBoundingBox(), mon:getBoundingBox()) then 
                control:addScore();
                table.remove(money, i);
                owner:getParent():removeChild(mon, true);
            else
                if mon:getComponent("moneyComponent").isOver then
                    table.remove(money, i);
                    owner:getParent():removeChild(mon, true);
                end
            end
        end

        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            if tolua.isnull(owner) or tolua.isnull(enemy) then
                return 
            end 
            if cc.rectIntersectsRect(owner:getBoundingBox(), enemy:getBoundingBox()) then 
                table.remove(enemies, i);
                owner:getParent():removeChild(enemy, true);
                control:looseGame()
            else
                if enemy:getComponent("moneyComponent").isOver then 
                    print(enemy:getComponent("moneyComponent").isOver) 
                    table.remove(enemies, i);
                    owner:getParent():removeChild(enemy, true);
                end
            end
        end
    end,
    
}

return Player
