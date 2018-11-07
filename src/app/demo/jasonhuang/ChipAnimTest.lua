local RegionConfig = {
    [1] = {pos = cc.p(8.5,417),ap = {0,0.5},capInsets = cc.rect(10,10,54,54),zorder = 1,swallow = {top = -35,bottom = 12.5,left = 35,right = -12.5},size = cc.size(128,92),res = "Images/koprokdice/bet/koprok_dice_bet_dark1.png"},
    [2] = {pos = cc.p(136.5,417),ap = {0,0.5},capInsets = cc.rect(10,10,54,54),zorder = 1,swallow = {top = -35,bottom = 12.5,left = 12.5,right = -35},size = cc.size(128,92),res = "Images/koprokdice/bet/koprok_dice_bet_dark2.png"},
    [3] = {pos = cc.p(8.5,325),ap = {0,0.5},size = cc.size(128,92),zorder = 1,swallow = {top = -12.5,bottom = 12.5,left = 0,right = -12.5}},
    [4] = {pos = cc.p(136.5,325),ap = {0,0.5},size = cc.size(128,92),zorder = 1,swallow = {top = -12.5,bottom = 12.5,left = 12.5,right = 0}},
    [5] = {pos = cc.p(8.5,233),ap = {0,0.5},size = cc.size(128,92),zorder = 1,swallow = {top = -12.5,bottom = 0,left = 0,right = -12.5}},
    [6] = {pos = cc.p(136.5,233),ap = {0,0.5},size = cc.size(128,92),zorder = 1,swallow = {top = -12.5,bottom = 0,left = 12.5,right = 0}},
    [7] = {pos = cc.p(8.5,147.5),ap = {0,0.5},size = cc.size(84.5,80.5),zorder = 1},
    [8] = {pos = cc.p(94,147.5),ap = {0,0.5},size = cc.size(85,80.5),zorder = 1},
    [9] = {pos = cc.p(180,147.5),ap = {0,0.5},size = cc.size(84.5,80.5),zorder = 1},
    [10] = {pos = cc.p(8.5,65.5),ap = {0,0.5},size = cc.size(84.5,80.5),zorder = 1},
    [11] = {pos = cc.p(94,65.5),ap = {0,0.5},size = cc.size(85,80.5),zorder = 1},
    [12] = {pos = cc.p(180,65.5),ap = {0,0.5},size = cc.size(84.5,80.5),zorder = 1},

    [13] = {pos = cc.p(32,370),ap = {0,0.5},size = cc.size(79,25),zorder = 2},
    [14] = {pos = cc.p(162,370),ap = {0,0.5},size = cc.size(79,25),zorder = 2},
    [15] = {pos = cc.p(32,279.5),ap = {0,0.5},size = cc.size(79,25),zorder = 2},
    [16] = {pos = cc.p(162,279.5),ap = {0,0.5},size = cc.size(79,25),zorder = 2},
    [17] = {pos = cc.p(124,416),ap = {0,0.5},size = cc.size(25,60),zorder = 2},
    [18] = {pos = cc.p(124,325),ap = {0,0.5},size = cc.size(25,60),zorder = 2},
    [19] = {pos = cc.p(124,234),ap = {0,0.5},size = cc.size(25,60),zorder = 2},
    [20] = {pos = cc.p(8,444),ap = {0,0.5},size = cc.size(35,35),zorder = 2,radius = 35,oriPoint = cc.p(8,461)},
    [21] = {pos = cc.p(230,444),ap = {0,0.5},size = cc.size(35,35),zorder = 2,radius = 35,oriPoint = cc.p(265,461)},
}

local CHIPBTNS = {
    {res = "Images/koprokdice/chip_btn1.png",pos = cc.p(-100,70)},
    {res = "Images/koprokdice/chip_btn2.png",pos = cc.p(-100,110)},
    {res = "Images/koprokdice/chip_btn3.png",pos = cc.p(-100,150)},
    {res = "Images/koprokdice/chip_btn4.png",pos = cc.p(-100,190)},
}

local curChipIdx
local lastSelectChipBtn

local mainLayer
local _roulette
local regionNodes = {}

local function createBetRegion(bg)
    for i, v in pairs(RegionConfig) do
        local res_default = v.res or "Images/koprokdice/bet/koprok_dice_bet_dark3.png"
        local darkNode = display.newSprite(res_default,{capInsets = v.capInsets})
        darkNode:setPosition(v.pos)
        darkNode:setAnchorPoint(unpack(v.ap))
        darkNode:setContentSize(v.size)
        darkNode.betNum = i
        darkNode:setOpacity(0)
        bg:addChild(darkNode)
        table.insert(regionNodes,darkNode)
    end
end

local function createBetAnim(regionNode)
    if not curChipIdx then
        return
    end
    local chip = display.newSprite(CHIPBTNS[curChipIdx].res)
    chip:setPosition(CHIPBTNS[curChipIdx].pos)
    chip:setScale(0.5,0.5)
    _roulette:addChild(chip)
    local config = RegionConfig[regionNode.betNum]
    local swallow = config.swallow or {top = 0,bottom = 0,left = 0,right = 0}
    local posx,posy = regionNode:getPosition()
    local size = regionNode:getContentSize()
    local size_chip = chip:getContentSize()
    local range_x = {posx + size_chip.width/2*0.5 + swallow.left,posx + size.width - size_chip.width/2*0.5 + swallow.right}
    local range_y = {posy - size.height/2 + size_chip.height/2*0.5 + swallow.bottom,posy + size.height/2 - size_chip.height/2*0.5 + swallow.top}
    local px,py = math.random(unpack(range_x)),math.random(unpack(range_y))
    local speed = 100
    local time = math.ceil(math.abs(px - posx) / speed)
    local ac = cc.EaseCubicActionOut:create(cc.MoveTo:create(time, cc.p(px,py)))
    chip:runAction(ac)
end

--创建下注轮盘
local function createBetRoulette()
    local layer = display.newLayer(cc.c4b(0,128,128,255))
    -- local layer = display.newLayer()
    mainLayer = layer
    local betRoulette = display.newSprite("Images/koprokdice/bet/koprok_dice_bet.png",display.cx,display.cy)
    betRoulette:setScale(0.6,0.6)
    layer:addChild(betRoulette)
    _roulette = betRoulette
    createBetRegion(betRoulette)

    local function onTouchBegan(touch, event)
        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onTouchEnded(touch,event)
        local pos = touch:getLocation()
        local target = event:getCurrentTarget()
        local isTouch = false
        local isInRadius
        local touchIdx
        for i,node in ipairs(regionNodes) do            
            local locationInNode = node:convertToNodeSpace(touch:getLocation())
            local s = node:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            
            if cc.rectContainsPoint(rect, locationInNode) then
                if regionNodes[i].betNum and RegionConfig[regionNodes[i].betNum].radius then
                    print("判断是否半径内")
                    --检测是否处于半径以内
                    local radius = RegionConfig[regionNodes[i].betNum].radius
                    local oriPoint = RegionConfig[regionNodes[i].betNum].oriPoint
                    local tp = _roulette:convertToNodeSpace(pos)
                    local distance = math.sqrt( math.pow(tp.x - oriPoint.x,2) + math.pow(tp.y - oriPoint.y,2) )
                    if distance <= radius then
                        print("在半径内")
                        isTouch = true
                    else
                        isInRadius = false
                        print("不在半径内")
                    end
                else
                    isTouch = true
                end
                if isTouch then
                    if isInRadius ~= false then
                        if not touchIdx then
                            touchIdx = i
                        else
                            local preNode = regionNodes[touchIdx]
                            local conf = RegionConfig[preNode.betNum]
                            local conf2 = RegionConfig[node.betNum]
                            if conf2.zorder > conf.zorder then
                                touchIdx = i
                            end
                        end
                    end
                end
            end
        end
        if isTouch then
            print("命中目标编号："..regionNodes[touchIdx].betNum)
            createBetAnim(regionNodes[touchIdx])
            return true
        else
            return false
        end     
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layer)

    return layer
end

local function createChips()
    for i=1,4 do
        local btn = ccui.Button:create(CHIPBTNS[i].res,CHIPBTNS[i].res,CHIPBTNS[i].res, 0)
        btn:setPosition(CHIPBTNS[i].pos)
        btn:setScale(0.6,0.6)
        local size = btn:getContentSize()
        local light = display.newSprite("Images/koprokdice/chip_btn_light.png")
        light:setPosition(cc.p(size.width/2,size.height/2))
        light:setVisible(false)
        btn:addChild(light)
        btn.light = light
        btn:addClickEventListener(function(sender)
            if lastSelectChipBtn then
                lastSelectChipBtn.light:setVisible(false)
            end
            curChipIdx = i
            lastSelectChipBtn = sender
            lastSelectChipBtn.light:setVisible(true)
        end)
        _roulette:addChild(btn)
    end
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(createBetRoulette())
    createChips()
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main