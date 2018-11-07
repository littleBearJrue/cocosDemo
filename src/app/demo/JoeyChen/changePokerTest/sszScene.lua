-- @module: sszScene
-- @author: JoeyChen
-- @Date:   2018-10-25 16:53:47
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-11-01 20:09:40
local sszScene = {}
local appPath = "app.demo.JoeyChen"
local changePokerViewCtr = require(appPath..".changePokerTest.changePokerViewCtr")

-- 模拟单牌数据
local pokerfig = {
	[1] = {
		[1] = 0x15, [2] = 0x3d, [3] = 0x26,
	},
	[2] = {
		[1] = 0x27, [2] = 0x12, [3] = 0x2c, [4] = 0x37, [5] = 0x2d,
	},
	[3] = {
		[1] = 0x4b, [2] = 0x36, [3] = 0x23, [4] = 0x14, [5] = 0x34,
	},
};

function sszScene:main()
    self.m_scene = cc.Scene:create()
    self.m_scene:addChild(CreateBackMenuItem())
    self:createLayout();

    return self.m_scene
end

function sszScene:createLayout()
	local changePokerCtr = changePokerViewCtr.new(pokerfig);
    self.m_scene:addChild(changePokerCtr:getView());
    changePokerCtr:getView():setLocalZOrder(2)
end

return handler(sszScene, sszScene.main)