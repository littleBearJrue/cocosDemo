local changePokerView = class("changePokerView",cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local CardView = import(".CardView")
local ClockView = import(".ClockView")

BehaviorExtend(changePokerView);

-- 十三张牌坐标
local posConfig = {
	[1] = {
		[1] = {x = display.cx - 122.6, y = display.cy + 96.5},
		[2] = {x = display.cx - 61.3, y = display.cy + 96.5},
		[3] = {x = display.cx, y = display.cy + 96.5},
	},
	[2] = {
		[1] = {x = display.cx - 122.6, y = display.cy},
		[2] = {x = display.cx - 61.3, y = display.cy},
		[3] = {x = display.cx, y = display.cy},
		[4] = {x = display.cx + 61.3, y = display.cy},
		[5] = {x = display.cx + 122.6, y = display.cy},
	},
	[3] = {
		[1] = {x = display.cx - 122.6, y = display.cy - 96.5},
		[2] = {x = display.cx - 61.3, y = display.cy - 96.5},
		[3] = {x = display.cx, y = display.cy - 96.5},
		[4] = {x = display.cx + 61.3, y = display.cy - 96.5},
		[5] = {x = display.cx + 122.6, y = display.cy - 96.5},
	},
};

function changePokerView:ctor()
	self.selectCard = nil
	self.isSelected = false
	self:init()
end

function changePokerView:dtor()
    self:cancelAllSchedule()
    self:unbindCtr();

	self:cleanAll()
end

-- 初始化界面
function changePokerView:init()
    local creatorReader = creator.CreatorReader:createWithFilename('creator/Scene/JoeyChen/testScene.ccreator');
    creatorReader:setup();
    self.scene = creatorReader:getNodeGraph();
    self.scene:addTo(self)

    self:initButtonEvent()
    self:initClock()
    -- self:addPoker()
end

-- 设置按钮事件
function changePokerView:initButtonEvent()
	local changeButton = self.scene:getChildByName("Canvas"):getChildByName("bg"):getChildByName("change2And3")
	changeButton:addClickEventListener(function()
		self:changeTwoAndThreeRowCards()
    end)
	local endButton = self.scene:getChildByName("Canvas"):getChildByName("bg"):getChildByName("onEnd")
	endButton:addClickEventListener(function()
		self:changeCardOver()
    end)
end

-- 初始化闹钟
function changePokerView:initClock()
	local function setTipText()
		local tip = self.scene:getChildByName("Canvas"):getChildByName("bg"):getChildByName("tip")
		tip:setString("倒计时即将结束，请尽快换牌！")
	end

	self.clockView = ClockView.new(60,50,setTipText);
    self.clockView:setAnchorPoint(0.5,0.5)
    self.clockView:move(0,0);
    self.clockView:addTo(self)
end

-- 添加牌组
function changePokerView:addPoker(pokerfig)
	for i,list in ipairs(posConfig) do
		for j,v in ipairs(list) do
			local cardView = self:createOnePoker(pokerfig[i][j])
			cardView:setPosition(v.x, v.y)
			cardView:setTag(i..j)
			cardView:addTo(self)
			self:initPokerTouchListener(cardView)

			local size = cardView:getContentSize()
			local mask = cc.Sprite:create("creator/Texture/JoeyChen/room_poker_selected.png")
				:move(size.width/2,size.height/2)
				:setAnchorPoint(0.5,0.5)
				:setScale(2.4,2.4)
				:setVisible(false)
				:setName("mask")
				:addTo(cardView)
		end
	end
	self:createCardListInfo(false)
end

-- 创建单牌
function changePokerView:createOnePoker(cardByte)
	local cardView = CardView:create()
	cardView.cardByte = cardByte
	cardView:setScale(0.28,0.28)
	cardView:setAnchorPoint(0.5,0.5)

	return cardView
end

-- 设置单牌触摸事件
function changePokerView:initPokerTouchListener(cardView)
	local firstX,firstY = 0,0  --初始位置

    local function onTouchBegan(touch,event)
        local point = touch:getLocation()
        local rect = cardView:getBoundingBox()
        if (cc.rectContainsPoint(rect,point)) then
        	-- 获取初始位置
        	firstX,firstY = cardView:getPosition()
            return true;
        end
    
        return false;
    end
    local function onTouchEnded(touch,event)
    	cardView:setLocalZOrder(1)
    	local posX,posY = cardView:getPosition()  --获取当前的位置
        if firstX == posX and firstY == posY then 
            -- 显示遮罩
            if not self.isSelected and not self.selectCard then
	            cardView:setScale(0.32,0.32)
	            self.selectCard = cardView
	            self.isSelected = true
	        elseif self.isSelected and self.selectCard == cardView then
	            self:initCardInfo(cardView, true)
	        elseif self.isSelected and self.selectCard ~= cardView then
	            local oldTag = self.selectCard:getTag()
	            local nowTag = cardView:getTag()
	            self.selectCard:runAction(cc.MoveTo:create(0.5,cc.p(self:getPosByTag(nowTag))))
	            cardView:runAction(cc.MoveTo:create(0.5,cc.p(self:getPosByTag(oldTag))))
	            self.selectCard:setTag(nowTag)
	            cardView:setTag(oldTag)

	            self:initCardInfo(self.selectCard)
	            self:createCardListInfo(false)
	        end
        else
        	local posX,posY = cardView:getPosition()  --获取当前的位置
			for i,list in ipairs(posConfig) do
				for j,v in ipairs(list) do
					if (posX > v.x - 28.3 and posX < v.x + 28.3) and (posY > v.y - 38.1 and posY < v.y + 38.1) then
						local targetCard = self:getChildByTag(i..j)
						cardView:setPosition(v.x,v.y)
						targetCard:runAction(cc.MoveTo:create(0.5,cc.p(firstX,firstY)))

						targetCard:setTag(cardView:getTag())
						cardView:setTag(i..j)

			        	self:initCardInfo(self.selectCard)
			        	self:createCardListInfo(false)
			            return
			        end
				end
			end
            -- 返回初始位置
            cardView:setPosition(firstX,firstY)
        end
    end
    local function onTouchMoved(touch, event)
    	cardView:setLocalZOrder(99)
        local posX,posY = cardView:getPosition()  --获取当前的位置
        local delta = touch:getDelta() --获取滑动的距离
        cardView:setPosition(cc.p(posX + delta.x, posY + delta.y)) --给精灵重新设置位置
    end
 
    local listener = cc.EventListenerTouchOneByOne:create()  --创建一个单点事件监听
    listener:setSwallowTouches(false)  --是否向下传递
    --注册三个回调监听方法
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    
    local eventDispatcher = cardView:getEventDispatcher() --事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, cardView) --分发监听事件
end

-- 交换二三行牌组
function changePokerView:changeTwoAndThreeRowCards()
	for i = 1, 5 do
		local twoRowCard = self:getChildByTag("2"..i)
		local threeRowCard = self:getChildByTag("3"..i)

		twoRowCard:runAction(cc.MoveTo:create(0.5,cc.p(posConfig[3][i].x, posConfig[3][i].y)))
		threeRowCard:runAction(cc.MoveTo:create(0.5,cc.p(posConfig[2][i].x, posConfig[2][i].y)))

		twoRowCard:setTag("3"..i)
		threeRowCard:setTag("2"..i)
	end
    if self.selectCard then
		self:initCardInfo(self.selectCard)
	end
	self:createCardListInfo(false)
end

-- 点击完成按钮
function changePokerView:changeCardOver()
	self:initCardInfo(self.selectCard)
	self:createCardListInfo(true)
end

-- 将牌组数据传给控制层
function changePokerView:createCardListInfo(isOver)
	local cardListInfo = {}
	for i,list in ipairs(posConfig) do
		cardListInfo[i] = {}
		for j,v in ipairs(list) do
			local cardByte = self:getChildByTag(i..j).cardByte
			table.insert(cardListInfo[i], cardByte)
		end
	end
	self.ctr:receiveCardListInfo(cardListInfo, isOver)
end

-- 根据索引获得单牌区域位置
function changePokerView:getPosByTag(tag)
	local row = tonumber(string.sub(tag,1,1))
	local col = tonumber(string.sub(tag,2))

	local x = posConfig[row][col].x
	local y = posConfig[row][col].y

	return x,y
end

-- 初始化单牌数据
function changePokerView:initCardInfo(cardView, isNotSelected)
    if self.isSelected then
    	cardView:setScale(0.28,0.28)
    end
    self.selectCard = nil
    self.isSelected = false

    if not isNotSelected then
		for i,list in ipairs(posConfig) do
			for j,v in ipairs(list) do
				local card = self:getChildByTag(i..j)
			    local mask = card:getChildByName("mask")
			    mask:setVisible(false)				
			end
		end
	end
end

-- 根据byte值获取view
function changePokerView:getCardViewByByte(cardByte)
	for i,list in ipairs(posConfig) do
		for j,v in ipairs(list) do
			local cardView = self:getChildByTag(i..j)
			if cardView.cardByte == cardByte then
			    local mask = cardView:getChildByName("mask")
			    mask:setVisible(true)
			    return
			end
		end
	end
end

-- 每行牌型等显示
function changePokerView:changeUIByCardType(cardTypeInfo)
	local listInfo = cardTypeInfo.list
	for i,v in ipairs(listInfo) do
		local bg = self.scene:getChildByName("Canvas"):getChildByName("bg");
		-- 该行牌组是否符合规则
		local icon = bg:getChildByName(tostring(i))
		if v.result then
			icon:getChildByName("yes"):setVisible(true)
			icon:getChildByName("no"):setVisible(false)
		else
			icon:getChildByName("yes"):setVisible(false)
			icon:getChildByName("no"):setVisible(true)
		end
		-- 该行牌组可组成的牌型名称
		local text = bg:getChildByName("pokerBg"):getChildByName(tostring(i))
		text:setString(v.name)
		-- 该行牌组牌型包含的牌高亮显示
		for i,cardByte in ipairs(v.card) do
			self:getCardViewByByte(cardByte)
		end
	end
end

function changePokerView:cleanAll()
	self.scene = nil
	self.selectCard = nil
	self.isSelected = false
	self.clockView:cleanAll()
	self:removeAllChildren()
end

return changePokerView;