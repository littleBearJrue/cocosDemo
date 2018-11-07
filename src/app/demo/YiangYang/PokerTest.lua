-- @Author: YiangYang
-- @Date:   2018-10-24 10:31:14
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-31 11:24:40

local pokerLayerCtr = import(".poker.PokerLayerCtr")
local function createUI()
	local ctr = pokerLayerCtr.new()
    return ctr:getView()
end


local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main