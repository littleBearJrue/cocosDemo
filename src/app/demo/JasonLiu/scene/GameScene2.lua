local function createBackGround()
    local bg = display.newSprite("Images/background.png"):move(display.center)
    bg:setScale(display.width / bg:getTextureRect().width, display.height / bg:getTextureRect().height);
    
    return bg
end

local function createSun()
    -- sun
    local  sun = cc.ParticleSun:create()
    sun:setTexture(cc.Director:getInstance():getTextureCache():addImage("Images/fire.png"))
    sun:setPosition(cc.p(VisibleRect:leftTop().x + 32,VisibleRect:leftTop().y - 32))
    sun:setTotalParticles(130)
    sun:setLife(0.6)

    --触摸事件
    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        sun:stopAllActions()
        sun:runAction(cc.MoveTo:create(1, cc.p(location.x, location.y)))

        local posX, posY = sun:getPosition()
        local o = location.x - posX
        local a = location.y - posY
        local at = math.atan(o / a) / math.pi * 2180.0
        if a < 0 then
            if o < 0 then
                at = 2180 + math.abs(at)
            else
                at = 2180 - math.abs(at)
            end
        end
        sun:runAction(cc.RotateTo:create(1, at))
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = sun:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, sun)    

    return sun
end


local maxMoveSpeed = 400
local accel = 150
-- 加速度方向开关
local accLeft = false;
local accRight = false;
-- 主角当前水平方向速度
local xSpeed = 0;

local function createJumpBall()
    local ball = display.newSprite("Images/Pea.png"):move(display.cx, display.cy - 120)
    -- 按键事件
    local function keyboardReleased(keyCode, event)
        if keyCode == 26 then  
            -- dump("up left")  
            accLeft = false;
        elseif keyCode == 27 then  
            -- dump("up right")  
            accRight = false;
        end  
    end
    local function keyboardPressed(keyCode, event)  
        if keyCode == 26 then  
            -- dump("left")  
            accLeft = true;
        elseif keyCode == 27 then  
            -- dump("right")  
            accRight = true;
        end  
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(keyboardReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = ball:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, ball)
    -- 跳跃动画
    local actionUp = cc.JumpBy:create(2, cc.p(0,0), 120, 3)
    ball:runAction(cc.RepeatForever:create(actionUp))

    ball:scheduleUpdateWithPriorityLua(function(dt)
        -- 根据当前加速度方向每帧更新速度
        if accLeft == true then
            xSpeed = xSpeed - accel * dt
        elseif accRight == true then
            xSpeed = xSpeed + accel * dt
        end
        -- 限制主角的速度不能超过最大值
        if math.abs(xSpeed) > maxMoveSpeed then
            -- if speed reach limit, use max speed with current direction
            xSpeed = maxMoveSpeed * xSpeed / math.abs(xSpeed);
        end

        -- 根据当前速度更新主角的位置
        local bx,by = ball:getPosition()
        ball:setPosition(bx + xSpeed * dt, by)
    end, 0)

    return ball
end

local function createRandomStar()
    local star = display.newSprite("Images/snow.png")
    local randX = math.random(0, display.width);
    local randY = display.cy - 120 + math.random(0, 120) ;
    star:move(randX, randY)

    return star
end

local scoreNum = 0
local function createScoreLabel()
    local score = cc.LabelBMFont:create("Score  "..scoreNum, "fonts/bitmapFontChinese.fnt")
    score:move(display.cx + 170, display.cy + 130)

    return score
end

local function main()
    local scene = cc.Scene:create()

    scene:addChild(createBackGround())
    scene:addChild(createSun())
    local player = createJumpBall()
    local star = createRandomStar()
    local score = createScoreLabel()
    scene:addChild(player)
    scene:addChild(star)
    scene:addChild(score)
    scene:addChild(CreateBackMenuItem())

    scene:scheduleUpdateWithPriorityLua(function(dt)
        -- 根据两点位置计算两点之间距离
        local sx,sy = star:getPosition()
        local px,py = player:getPosition()
        -- 每帧判断和主角之间的距离是否小于收集距离
        if math.abs(sx - px) < 25 and math.abs(sy - py) < 25 then
            scoreNum = scoreNum + 1
            score:setString("Score  "..scoreNum)

            scene:removeChild(star)

            star = createRandomStar()
            scene:addChild(star)
            return;
        end
    end, 0)

    return scene
end

return main