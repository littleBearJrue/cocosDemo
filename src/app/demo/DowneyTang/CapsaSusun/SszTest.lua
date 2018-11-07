local SszViewCtr =  require("app.demo.DowneyTang.CapsaSusun.SszViewCtr")

local function main()
    local scene = cc.Scene:create() 

    local SszViewCtr = SszViewCtr.new();
    SszViewCtr:initView()
    scene:addChild(SszViewCtr:getView()); 

    return scene
end

return main