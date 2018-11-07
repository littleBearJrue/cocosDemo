--[[--ldoc desc
@module SSZView
@author JrueZhu

Date   2018-10-31 09:32:00
Last Modified by   JrueZhu
Last Modified time 2018-11-01 19:01:13
]]

local appPath = "app.demo.JrueZhu"
local SSZView = class("SSZView",cc.load("boyaa").mvc.BoyaaLayout);
local layoutFile = "creator/Scene/JrueZhu/shiSanZhang.ccreator"
local SingleCardView = require(appPath .. ".widget.SingleCardView")

BehaviorExtend(SSZView);

function SSZView:ctor()
	-- 加载creator界面
	self:loadLayout();
	-- 初始化配置
	self:initConfig();
end

function SSZView:loadLayout()
	local creatorReader = creator.CreatorReader:createWithFilename(layoutFile);
    creatorReader:setup();
	local layer = creatorReader:getNodeGraph();
	layer:setPosition(display.center)
	layer:setScale(0.7)
	self:addChild(layer);
	self.layer = layer:getChildByName("room_bg");
end

function SSZView:initConfig()
	self.mCardViews = {};
	self.selectedCard = nil;
	self.targetCard = nil;
end

local function changePosBetweenTwoCards(self, firstCard, secondCard)
	-- TODO
	-- 这里应该有个动画的
	local tempByte = firstCard.cardByte;
	firstCard.cardByte = secondCard.cardByte;
	secondCard.cardByte = tempByte;
end

local function adjustCardScale(card, state)
	if state == "normal" then
		card:setScale(0.7)
		--card:setGlobalZOrder(0);
	elseif state == "selected" then
		card:setScale(0.8);
		--card:setGlobalZOrder(99);
	end
end

local function createBaseCard(cardView)
	local baseCard = cardView:clone();
	baseCard:setCascadeOpacityEnabled(true);
	baseCard:setOpacity(125);
	baseCard:setGlobalZOrder(0);
	return baseCard;
end

local function setTouchEvent(self, cardView)
	local function onTouchBegan(touch, event)
        local cardView = event:getCurrentTarget()
		local locationInNode = cardView:convertToNodeSpace(touch:getLocation())
		local cardSize = cardView:getContentSize()
		local rect = cc.rect(0, 0, cardSize.width, cardSize.height)
		if cc.rectContainsPoint(rect, locationInNode) then

			self.baseCard = createBaseCard(cardView);
			self:addChild(self.baseCard)
			
			--设置层级
			cardView:setLocalZOrder(99)

			--若没有选中过card，则选中
			if not self.selectedCard then
				self.selectedCard = cardView
				--选中后需要更新遮罩
				adjustCardScale(cardView, "selected")
			elseif not self.targetCard then--若有选中card，且交换目标card为nil 则是交换目标card
				self.targetCard = cardView
			end
			return true
		end
		return false
    end


    local function onTouchMoved(touch, event)
    	local cardView = event:getCurrentTarget()
    	local posX, posY = cardView:getPosition();
    	local diff = touch:getDelta();
    	local currentPosX = posX + diff.x;
		local currentPosY = posY + diff.y;
    	cardView:setPosition(cc.p(currentPosX, currentPosY));
    	for row, cardViews in ipairs(self.mCardViews) do
			for col, target in ipairs(cardViews) do
				local locationInNode = target:convertToNodeSpace(touch:getLocation())
				local cardSize = target:getContentSize()
				local rect = cc.rect(0, 0 ,cardSize.width, cardSize.height)
				if target ~= cardView then --进入别的牌区域
					if cc.rectContainsPoint(rect, locationInNode) then
	
						self.targetCard = target
	
						adjustCardScale(target, "selected");
						self.isTuo = true
					else
						adjustCardScale(target, "normal");
					end
				else
					if cc.rectContainsPoint(rect,locationInNode) then  --拖动的时候看看原来有无选中card，将自身设为选中
						if self.selectedCard then --看原来是否有选中的card
							adjustCardScale(self.selectedCard,"normal")
						end
						--设置选中状态
						adjustCardScale(target,"selected")
						self.selectedCard = target
					end
				end
			end
    	end
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        local cardView = event:getCurrentTarget()
        local basePosX, basePosY = self.baseCard:getPosition();


        if self.baseCard then
        	self.baseCard:removeSelf();
        	self.baseCard = nil
        end
        --还原属性
        cardView:setOpacity(255)
        cardView:setLocalZOrder(0)
        
        --是否有选中的card
        if self.selectedCard then
        	if self.targetCard then
        		adjustCardScale(self.selectedCard, "normal")
				adjustCardScale(self.targetCard, "normal")

	        	if self.selectedCard ~= self.targetCard then --若选中跟目标不是同一个
	 				changePosBetweenTwoCards(self, self.selectedCard, self.targetCard);
	 				local targetPosX, targetPosY = self.targetCard:getPosition();
	 				self.selectedCard:setPosition(targetPosX, targetPosY);
					self.targetCard:setPosition(basePosX, basePosY);

	        	else
					self.selectedCard:setPosition(basePosX, basePosY);
	        	end
	     
	        	self.selectedCard = nil
	        	self.targetCard = nil
	        else
				self.selectedCard:setPosition(basePosX, basePosY);
				adjustCardScale(self.selectedCard, "normal")
				self.selectedCard = nil;
        	end
        end
 
        self.isTuo = false
    end


	local listener = cc.EventListenerTouchOneByOne:create() -- 单点触摸监听 
   listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN);
   listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED);
   listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED);
   local dispacher = cardView:getEventDispatcher()  
   dispacher:addEventListenerWithSceneGraphPriority(listener, cardView)
end

function SSZView:createOneCard(cardByte)
	local card = SingleCardView:create({cardByte = cardByte});
	return card;
end

function SSZView:createCards(data)
	local cardPath = "poker_row_%d_col_%d";
	for i = 1, 3 do
		if self.mCardViews[1] == nil then self.mCardViews[1] = {} end;
		local card = self:createOneCard(data[i]);
		setTouchEvent(self, card);
		table.insert(self.mCardViews[1], card);
		local cardPanel = self.layer:getChildByName(string.format(cardPath, 1, i));
		local posX = cardPanel:getPositionX();
		local posY = cardPanel:getPositionY();
		local point = cardPanel:getParent():convertToWorldSpace(cc.p(posX, posY))
		card:setScale(0.7)
		card:setPosition(point.x, point.y)
		card:setAnchorPoint(0.5, 0.5)
		self:addChild(card, 0, i);
		cardPanel:setVisible(false);
	end
	for i = 4, 8 do
		if self.mCardViews[2] == nil then self.mCardViews[2] = {} end;
		local card = self:createOneCard(data[i]);
		setTouchEvent(self, card);
		table.insert(self.mCardViews[2], card);
		local cardPanel = self.layer:getChildByName(string.format(cardPath, 2, i - 3));
		local posX = cardPanel:getPositionX();
		local posY = cardPanel:getPositionY();
		local point = cardPanel:getParent():convertToWorldSpace(cc.p(posX, posY))
		card:setScale(0.7)
		card:setPosition(point.x, point.y)
		card:setAnchorPoint(0.5, 0.5)
		self:addChild(card, 0, i);
		cardPanel:setVisible(false);
	end
	for i = 9, #data do
		if self.mCardViews[3] == nil then self.mCardViews[3] = {} end;
		local card = self:createOneCard(data[i]);
		setTouchEvent(self, card);
		table.insert(self.mCardViews[3], card);
		local cardPanel = self.layer:getChildByName(string.format(cardPath, 3, i - 8));
		local posX = cardPanel:getPositionX();
		local posY = cardPanel:getPositionY();
		local point = cardPanel:getParent():convertToWorldSpace(cc.p(posX, posY))
		card:setScale(0.7)
		card:setPosition(point.x, point.y)
		card:setAnchorPoint(0.5, 0.5)
		self:addChild(card, 0, i);
		cardPanel:setVisible(false);
	end
end

--[[
	更新牌的显示，置灰处理
--]]
function SSZView:updateCardDisplay(card)

end

--[[
	更新每一行的牌型显示文字
--]]
function SSZView:updatePaixingLabel(paixingStr)
	
end

--[[
	更新每行满足牌型的牌的高亮显示
--]]
function SSZView:updateCardPlaceImg()
	-- body
end

return SSZView;