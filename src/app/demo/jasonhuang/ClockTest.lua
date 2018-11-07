local Clock = require("app.demo.jasonhuang.clock.Clock")

local function createOneClock()
    local clock = Clock:create()
    return clock
end

local function main()
    local scene = cc.Scene:create()
    scene:addChild(CreateBackMenuItem())
    scene:addChild(createOneClock())
    return scene
end

return main