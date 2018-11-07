local TestWidget = require "dev.demo.test.TestWidget"
local TestAni = require "dev.demo.test.TestAni"
local TestMore = require "dev.demo.test.TestMore"
local TestServer = require "dev.demo.test.TestServer"
local TestHttp = require "dev.demo.test.TestHttp"
local TestDownload = require "dev.demo.test.TestDownload"
local TestGame = require "dev.demo.test.testGame.TestGame"

local SceneTest = class("SceneTest", Scene)

local tests = {
	{name="1_widget",create_func=TestWidget},
	{name="2_ani",create_func=TestAni},
	{name="3_more",create_func=TestMore},

	{name="4_TestServer",create_func=TestServer},
	{name="5_TestHttp",create_func=TestHttp},


	{name="6_TestDownload",create_func=TestDownload},
	{name="7_TestGame",create_func=TestGame},

	
	
}


function SceneTest:onCreate()
	self:init()
	self:enableNodeEvents()	
end

function SceneTest:onEnter()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
        -- local aa = nil
		-- local bb = aa + 20
		require("dev.demo.data.database.sqlite3")
		print("finish")
		-- require("app.data.database.sqlite3")
		-- print("finish")
		local test = require("dev.demo.data.autobind.test")
		test:create():addTo(self)
    end)))
end

function SceneTest:init()

	--创建解析器
	local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/test_scene.ccreator')
	--生成 SpriteFrames 
	creatorReader:setup()
 
	--生成节点树
	local scene = creatorReader:getNodeGraph()

	--获取 root 节点，此节点影响 widget 的布局情况，每个 ccreator 都需要这个节点
	self.m_root = NodeUtils:seekNodeByName(scene,'root') 

	--只保留 root 子树，其它的节点去掉
	self.m_root:removeFromParent(false)
	self:addChild(self.m_root)

	--获取节点 ScrollView
	self.m_scrollView = NodeUtils:seekNodeByName(self.m_root,'ScrollView') 

	--获取 Container
	local container = self.m_scrollView:getInnerContainer()
	

	--添加 ArrangeNode 更好的操作 scrollview
	local arrangeNode = cc.Node:create()
	container:addChild(arrangeNode)

	local dy = 50
	local len = #tests
	for i=1,len do
		local item = ccui.Button:create()
		item:setContentSize(cc.size(300,40))
		item:setTitleText(tests[i].name)		
		item:setTitleColor(cc.WHITE)--cc.c3b(_r,_g,_b))
		item:setTitleFontSize(40)
		--item:getTitleLabel():setAnchorPoint(cc.p(0.5,1))
		item:setAnchorPoint(cc.p(0,1))
		item:setPressedActionEnabled(true)
		item:addClickEventListener(function(sender)
			local layer = tests[i].create_func:create()
			cc.Director:getInstance():getRunningScene():addChild(layer)
		  end)

		arrangeNode:addChild(item)
		item:setPositionY(-(i-1)*dy)
	end



	local s = self.m_scrollView:getContentSize()
	local height = len*dy

	if height < s.height then
		height = s.height
	end

	arrangeNode:setPosition(20,height)

	self.m_scrollView:setInnerContainerSize(cc.size(s.width,height))
	--self.m_scrollView:scrollToTop(1.0,true)
	self.m_scrollView:jumpToTop()
end

return SceneTest
