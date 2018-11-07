-- @Author: YiangYang
-- @Date:   2018-10-31 11:12:16
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-11-02 16:59:19

local ExchangeCardView = class("ExchangeCardView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend

local CardView = import("..CardView")

local Clock = import(".Clock")

local SceneRoot = "creator/Scene/YiangYang/"
local ImageRoot = "creator/Texture/YiangYang/"

--[[
	初始化creator布局
]]
local function initCreatorView(self)
	
	local file_path = SceneRoot..'shisanzhang.ccreator'
    local creatorReader = creator.CreatorReader:createWithFilename(file_path)
    creatorReader:setup()
    local scene = creatorReader:getNodeGraph()
    self:addChild(scene)

    local Canvas = scene:getChildByName("Canvas")
    
    self.sszNode = Canvas:getChildByName("sszNode")

    local poker_panel = self.sszNode:getChildByName("poker_panel")

    for i=1,13 do
        local children = poker_panel:getChildByName("room_poker_"..i)
        children:setVisible(false)
        local pos = {}
        local localPos = cc.p(children:getPositionX(),children:getPositionY())
        local worldPos = children:getParent():convertToWorldSpaceAR(localPos)
        pos.x = worldPos.x
        pos.y = worldPos.y
        table.insert(self.cardPosTb,pos)
    end

    self.timeTip = self.sszNode:getChildByName("timeTip")
    self.sureBtn = self.sszNode:getChildByName("sureBtn")
    self.changeBtn = self.sszNode:getChildByName("changeBtn")
    --每组牌是否符合规则（下面的牌型会比上面的牌型大）
    self.sprite1 = self.sszNode:getChildByName("sprite1")
    self.sprite2 = self.sszNode:getChildByName("sprite2")
    self.sprite3 = self.sszNode:getChildByName("sprite3")
    --每组牌牌型
    self.groupType1 = self.sszNode:getChildByName("groupType1")
    self.groupType2 = self.sszNode:getChildByName("groupType2")
    self.groupType3 = self.sszNode:getChildByName("groupType3")

    --初始化btn事件
    self.sureBtn:addClickEventListener(function ()
    	self.sszNode:setVisible(false)
    	self:getCtr():sendReq()
    end)

	self.changeBtn:addClickEventListener(function ()
    	self:getCtr():exchange23CardGroup()
    end)

	self.timeTip:setString("点击或者拖动交换牌")
	--缓存纹理
	self.rightCache = cc.Director:getInstance():getTextureCache():addImage(ImageRoot.."room_placecard_right.png")
	self.wrongCache = cc.Director:getInstance():getTextureCache():addImage(ImageRoot.."room_placecard_wrong.png")

	--闹钟
	local clock =  Clock:create(15):addTo(self.sszNode):move(display.sizeInPixels.width/2.,display.height-150)
	clock:setCallback(function ()
		self.timeTip:setString("倒计时时间到")
	end,function ()
		self.timeTip:setString("进入最后倒计时,请抓紧时间")
	end)

end

function ExchangeCardView:ctor()

	self.cardPosTb = {}		--世界坐标集合
	self.cardBytes = {}		--牌值集合

	self.cardGroup = {}		--牌集合

	self.choiseCard = nil 	--选中的card
	self.targetCard = nil	--要交换的目标card

	initCreatorView(self)
end

--[[
	根据遮罩类型，更新cardview
]]
local function updateCardViewMask(cardview,maskType)
	if "normal" == maskType then 	 --正常
		cardview:setScale(0.5,0.5)
	elseif "choise" == maskType then --选中
		cardview:setScale(0.55,0.55)
	elseif "best" == maskType then 	 --牌型最大
		cardview:setCascadeOpacityEnabled(true)
		cardview:setOpacity(122)
	elseif "reBest" == maskType then --牌型样式还原
		cardview:setCascadeOpacityEnabled(true)
		cardview:setOpacity(255)
	end
end

--[[
	牌回归原位（拖动情况）
]]
local function cardRegression(self)
	local cIndex = 0
	for i,v in ipairs(self.cardBytes) do
		if v == self.choiseCard.cardTByte then
			cIndex = i 
		end	
	end
	--若是牌不在原位则位移回归
	if self.choiseCard:getPositionX() ~= self.cardPosTb[cIndex].x 
		or self.choiseCard:getPositionY() ~= self.cardPosTb[cIndex].y then
		self.choiseCard:runAction(cc.MoveTo:create(0.1,self.cardPosTb[cIndex]))
		--若是经过位移后回归，则需把选中置空
		updateCardViewMask(self.choiseCard,"normal") --取消原先选中遮罩
		self.choiseCard = nil
	end
end

--[[
	刷新各个牌组，并通知ctr 牌组变化
	@cIndex 选中的下标
	@tIndex 目标下标
]]
local function updateCardGroup(self,cIndex,tIndex)

	local bigValue,smallValue,bigCard,smallCard
	if cIndex > tIndex then --下标大的先移除，防止错乱
		--记录牌值
		bigValue = table.remove(self.cardBytes,cIndex)
		smallValue = table.remove(self.cardBytes,tIndex)
		--下标小的先添加 进行交换
		table.insert(self.cardBytes,tIndex,bigValue)
		table.insert(self.cardBytes,cIndex,smallValue)

		--记录cardview
		bigCard = table.remove(self.cardGroup,cIndex)
		smallCard = table.remove(self.cardGroup,tIndex)
		--下标小的先添加 进行交换
		table.insert(self.cardGroup,tIndex,bigCard)
		table.insert(self.cardGroup,cIndex,smallCard)
	else
		--下标大的先移除，防止错乱
		bigValue = table.remove(self.cardBytes,tIndex)
		smallValue = table.remove(self.cardBytes,cIndex)
		--下标小的先添加 进行交换
		table.insert(self.cardBytes,cIndex,bigValue)
		table.insert(self.cardBytes,tIndex,smallValue)

		--记录cardview
		bigCard = table.remove(self.cardGroup,tIndex)
		smallCard = table.remove(self.cardGroup,cIndex)
		--下标小的先添加 进行交换
		table.insert(self.cardGroup,cIndex,bigCard)
		table.insert(self.cardGroup,tIndex,smallCard)
	end

	--刷新数据后，通知ctr
	self:getCtr():updateCardBytes(self.cardBytes)
end



--[[-
	换牌动画
-]]
local function exchangeCardAnima(self)
	if not self.choiseCard or not self.targetCard then return end

	local cIndex = 0
	local tIndex = 0
	for i,v in ipairs(self.cardBytes) do
		if v == self.choiseCard.cardTByte then
			cIndex = i 
		end
		if v == self.targetCard.cardTByte then
			tIndex = i 
		end	
	end

	if self.isTuo then 	--拖动交换
		self.choiseCard:runAction(cc.MoveTo:create(0.1,cc.p(self.targetCard:getPositionX(),self.targetCard:getPositionY())))
	else 				--点击交换
		self.choiseCard:runAction(cc.MoveTo:create(0.15,self.cardPosTb[tIndex]))
	end
	self.targetCard:runAction(cc.MoveTo:create(0.15,self.cardPosTb[cIndex]))
	--换牌之后需要更新牌组
	updateCardGroup(self,cIndex,tIndex)
end


--[[
	展示各个牌组牌型
	data 结构看Paixingutil
]]
function ExchangeCardView:showPaiXing(data)
	--设置牌型名称
	self.groupType1:setString(data[1].name)
	self.groupType2:setString(data[2].name)
	self.groupType3:setString(data[3].name)
	
	--看三个牌型从上到下是否满足从小到大的规则
	if data[1].state then
		self.sprite1:initWithTexture(self.rightCache)
	else
		self.sprite1:initWithTexture(self.wrongCache)
	end

	if data[2].state then
		self.sprite2:initWithTexture(self.rightCache)
	else
		self.sprite2:initWithTexture(self.wrongCache)
	end

	if data[3].state then
		self.sprite3:initWithTexture(self.rightCache)
	else
		self.sprite3:initWithTexture(self.wrongCache)
	end

	--先还原
	for i,card in ipairs(self.cardGroup) do
		updateCardViewMask(card,"reBest")
	end
	--再设置样式
	for i,v in ipairs(data) do
		for _,byte in ipairs(v.typeData) do
			for _,card in ipairs(self.cardGroup) do
				if byte == card.cardTByte then
					updateCardViewMask(card,"best")
				end
			end
		end
	end

end

--[[-
	设置牌 触摸监听事件
-]]
local function setTouchEvent(self,cardview)

	local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
		local locationInNode = target:convertToNodeSpace(touch:getLocation())
		local s = target:getContentSize()
		local rect = cc.rect(0,0,s.width,s.height)
		if cc.rectContainsPoint(rect,locationInNode) then
			--半透明
			target:setCascadeOpacityEnabled(true)
			target:setOpacity(122)
			--复制一个做底部残影
			self.shadow = target:clone():addTo(target:getParent())
			--设置层级
			target:setLocalZOrder(1)

			--若没有选中过card，则选中
			if not self.choiseCard then
				self.choiseCard = target
				--选中后需要更新遮罩
				updateCardViewMask(target,"choise")
			elseif not self.targetCard then--若有选中card，且交换目标card为nil 则是交换目标card
				self.targetCard = target
			else --防止拖动过程中再点击
				return false
			end
			return true
		end
		return false
    end


    local function onTouchMoved(touch, event)
    	local target = event:getCurrentTarget()
    	local location = touch:getLocation()
    	target:setPosition(location)
    	self.targetCard = nil
    	for i,v in ipairs(self.cardGroup) do
			local locationInNode = v:convertToNodeSpace(touch:getLocation())
			local s = v:getContentSize()
			local rect = cc.rect(0,0,s.width,s.height)
			if v ~= target then --进入别的牌区域
				if cc.rectContainsPoint(rect,locationInNode) then
					--设置目标
					self.targetCard = v
					--目标区域做下界面变动
					v:setScale(0.55)
					--进入别的牌区域认定为拖动
					self.isTuo = true
				else
					--非目标区域界面还原
					v:setScale(0.5)
				end
			else
				if cc.rectContainsPoint(rect,locationInNode) then  --拖动的时候看看原来有无选中card，将自身设为选中
					if self.choiseCard then --看原来是否有选中的card
						updateCardViewMask(self.choiseCard,"normal")
					end
					--设置选中状态
					updateCardViewMask(v,"choise")
					self.choiseCard = v
				end
			end
    	end
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        local target = event:getCurrentTarget()
        --若有残影则移除
        if self.shadow then
        	self.shadow:removeFromParent()
        	self.shadow = nil
        end
        --还原属性
        target:setOpacity(255)
        target:setLocalZOrder(0)
        
        --是否有选中的card
        if self.choiseCard then
        	if self.targetCard then --是否有目标card
		        updateCardViewMask(self.choiseCard,"normal") --取消原先选中遮罩
		        updateCardViewMask(self.targetCard,"normal") --由于拖动的到目标区域是改了目标大小（没有做遮罩）这里要还原
	        	if self.choiseCard ~= self.targetCard then --若选中跟目标不是同一个
	        		--执行动画
	        		exchangeCardAnima(self)
	        	else
	        		--选中跟目标是相同的card，则移动到它牌组所在的位置
	        		cardRegression(self)
	        	end
	        	--重置
	        	self.choiseCard = nil
	        	self.targetCard = nil
	        else
	        	--仅有选中的card，则移动到它牌组所在的位置
	        	cardRegression(self)
        	end
        end
        --松开则没有拖动
        self.isTuo = false
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = cardview:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, cardview)

end


--[[
	创建一张牌
	@data.cardTByte 牌值
	@data.pos 		世界坐标位置
]]
local function createOneCard(self,data)
	local cardview = CardView:create()
	cardview.cardTByte = data.cardTByte
	cardview:setAnchorPoint(0.5,0.5)
	cardview:setScale(0.5,0.5)
	cardview:setPosition(data.pos)
	cardview:addTo(self.sszNode)
	return cardview
end

--[[
	创建待交换的十三张手牌
]]
local function createHandCard(self,data)
	for i,v in ipairs(data) do
		local cardview = createOneCard(self,{cardTByte = v,pos = self.cardPosTb[i]})
		table.insert(self.cardBytes,v) --保存牌值下标对应世界坐标下标
		table.insert(self.cardGroup,cardview) 
		setTouchEvent(self,cardview)
	end
end


--更新view
function ExchangeCardView:updateView(data,pxData)
	if not data then return end
	--创建手牌
	createHandCard(self,data)
	--更新牌型
	self:showPaiXing(pxData)
end

--[[
	2,3排数据调换后，刷新界面
]]
function ExchangeCardView:updateExchange23CardGroup(cardBytes,pxData)
	self.cardBytes = cardBytes
	for i,v in ipairs(self.cardBytes) do
		self.cardGroup[i].cardTByte = v
	end
	--更新牌型
	self:showPaiXing(pxData)
end




return ExchangeCardView