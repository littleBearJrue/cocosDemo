local SwapTest = {}
local SwapCardCtr = import(".SwapCardCtr")
--所有牌
local allCard = 
{
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
	0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,
}

--主函数
function SwapTest:main( ... )
	--创建场景
	local scene = cc.Scene:create()
	self.scene = scene
	--获取桌子场景
	local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/SilvaZhang/swap/SwapTableScene.ccreator');
    creatorReader:setup();
    local swapScene = creatorReader:getNodeGraph();
    scene:addChild(swapScene)
    local Canvas = swapScene:getChildByName("Canvas")
	local tableBg = Canvas:getChildByName("tableBg")
	--发牌按钮
	self.startBtn = tableBg:getChildByName("startBtn")
	self:initView()
	self:createStarBtn()
	self:bindEventListener()
	return scene
end

function SwapTest:bindEventListener()
	local function callback( event )
		local data = event._usedata
		if data.ready then
			self.startBtn:setVisible(true)
		end
	end
    local listener1 = cc.EventListenerCustom:create("ready",callback)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)
end

--创建模块
function SwapTest:initView( )
	--创建CardLayerCtr，将view加入场景中
	local swapCardCtr = SwapCardCtr:create()
	local cardLayerView = swapCardCtr:getView()
	self.scene:addChild(cardLayerView)
end

--修改按钮
function SwapTest:createStarBtn( )
	local callback = function(tag)
		local tempCards= clone(allCard)
		local initData = {
			cardByteList = {
				[1] = {},
				[2] = {},
				[3] = {},
			}
		}
		--发牌随机
		local row = 1
		for i = 1,13 do
			local cardNum = #tempCards
			local index = math.random(1, cardNum)
			local tempCard = tempCards[index]
			table.remove(tempCards, index)
			if i == 4 or i == 9 then
				row = row + 1
			end
			table.insert(initData.cardByteList[row],tempCard)
		end
		--发送换牌消息
		if initData.cardByteList then
			local myEvent=cc.EventCustom:new("initCard")
			myEvent.initData = initData
			local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
       		customEventDispatch:dispatchEvent(myEvent)
       	end
       	tag:setVisible(false)
    end
    self.startBtn:addClickEventListener(callback)
end

return handler(SwapTest, SwapTest.main)