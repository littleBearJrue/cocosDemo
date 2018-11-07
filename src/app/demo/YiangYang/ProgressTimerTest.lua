--调度器
local scheduler = cc.Director:getInstance():getScheduler()
local imageRoot = "yiang/clock/play_countdown/"

local function createHeartUI()
	local layer = cc.Layer:create()
	local bg = cc.Sprite:create("yiang/heart_bg.png"):move(display.width/3,display.cy):addTo(layer)
	local heart = cc.Sprite:create("yiang/heart.png")

    local progress = cc.ProgressTimer:create(heart):move(display.width/3,display.cy):addTo(layer)
    --Type-> kCCProgressTimerTypeRadial / kCCProgressTimerTypeBar
    --设置进度条的模式  
    progress:setType(kCCProgressTimerTypeBar) -- //kCCProgressTimerTypeBar表示条形模式
    --设置进度条变化的方向   
    progress:setBarChangeRate(cc.p(0,1)) 
    --设置进度条的起始位置    
    progress:setMidpoint(cc.p(0,0)) 
    
    local percent = 0
    local callbackEntry = nil
    local function callback( dt )
    	percent = percent + 1
    	progress:setPercentage(percent)
    	if percent >= 100 then
    		scheduler:unscheduleScriptEntry(callbackEntry)
    		callbackEntry = nil
    	end
    end 
    callbackEntry = scheduler:scheduleScriptFunc(callback,0.1,false)
    return layer
end


local function createQuanUI()
	local layer = ccui.Layout:create()
	local bg = cc.Sprite:create(imageRoot.."placecard_countdownbg.png"):move(display.width/1.5,display.cy):addTo(layer)
	local quan = cc.Sprite:create(imageRoot.."placecard_countdown.png")

    local progress = cc.ProgressTimer:create(quan):move(display.width/1.5,display.cy):addTo(layer)
    progress:setReverseDirection(true)
    local percent = 100
    local callbackEntry = nil
    local canChange = true
    local function callback( dt )
        progress:setPercentage(percent)
    	percent = percent - 1

        if canChange and  percent < 50 then
            progress:setSprite(cc.Sprite:create(imageRoot.."placecard_countdown_red.png"))
            progress:setReverseDirection(true)
            canChange = false
        end
    	if percent < 0 then
    		scheduler:unscheduleScriptEntry(callbackEntry)
    		callbackEntry = nil
    	end
    end 
    callbackEntry = scheduler:scheduleScriptFunc(callback,0.1,false)
    
    return layer
end

local function main()
    --使用plist拼图，加载进缓存

    local scene = cc.Scene:create()
    scene:addChild(createHeartUI())
    scene:addChild(createQuanUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main