local function test1()
    local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal, 0)
    :move(display.cx, display.cy)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    return btn
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(test1())
    -- scene:addChild(CreateBackMenuItem())
    return scene
end

return main