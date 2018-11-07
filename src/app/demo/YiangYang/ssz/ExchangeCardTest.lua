-- @Author: YiangYang
-- @Date:   2018-10-31 11:16:08
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-31 15:02:15

local ExchangeCardViewCtr = import(".ExchangeCardViewCtr")
local function createUI()
	local ctr = ExchangeCardViewCtr.new()
    return ctr:getView()
end


local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main