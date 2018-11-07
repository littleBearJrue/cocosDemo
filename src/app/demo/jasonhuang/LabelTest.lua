local test1 = function()
    local testLabel = cc.Label:createWithTTF("hello world", s_arialPath, 30)
    :move(display.cx, display.cy)
    testLabel:setAnchorPoint(cc.p(0.5, 0.5))
    return testLabel
end

local function main()
    local scene = cc.Scene:create()
    local label = test1()
    scene:addChild(label)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main