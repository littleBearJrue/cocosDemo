--[[--ldoc desc
@Module DeployCardView.lua
@Author JasonLiu

Date: 2018-10-30 10:55:00
Last Modified by: JasonLiu
Last Modified time: 2018-10-30 15:43:47
]]

local Card = require("app.demo.JasonLiu.widget.Card")

local DeployCardView = class("DeployCardView", cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

BehaviorExtend(DeployCardView);

function DeployCardView:ctor(data)
    self:initData()
    self:initView(data)
    self:initEvent()
end

--[[
    @function initDate      初始化数据
]] 
function DeployCardView:initData()
    self.cards = {}  --所有的牌对象
    self.labels = {}  --所有的牌型标签对象
    self.checks = {}  --所有的牌型检查图标对象
end

--[[
    @function initView      初始化View
    @param #data table      牌的byte
]] 
function DeployCardView:initView(data)	
    --创建配置牌的根布局
    local rootLayoutW, rootLayoutH = 0,0
    local rootLayout = ccui.Layout:create():setAnchorPoint(cc.p(0.5, 0.5))
    rootLayout:setLayoutType(ccui.LayoutType.VERTICAL)
    --根据数据添加每行的牌布局
    for i, item in ipairs(data.card) do
        local layoutW, layoutH = 0, 0
        local layout = ccui.Layout:create():setLayoutType(ccui.LayoutType.HORIZONTAL)
        --添加牌型检查图标
        local deployCheck, marginSize = self:createDeployCheck()
        layout:addChild(deployCheck)
        table.insert(self.checks, deployCheck)
        layoutW = layoutW + deployCheck:getContentSize().width + marginSize.w
        --添加牌型标签
        local label = self:createDeployLable({ left = layoutW, right = 0, top = 0, bottom = 0})
        rootLayout:addChild(label)
        table.insert(self.labels, label)
        --添加一行的牌
        for _, cardByte in ipairs(item) do
            local cardLayout, marginSize = self:createCardLayout(cardByte, i)
            layout:addChild(cardLayout)
            
            layoutW = layoutW + cardLayout:getContentSize().width + marginSize.w
            layoutH = cardLayout:getContentSize().height + marginSize.h
        end
        layout:setContentSize(layoutW, layoutH)
        rootLayout:addChild(layout)
        --计算布局的宽高
        rootLayoutW = layoutW > rootLayoutW and layoutW or rootLayoutW
        rootLayoutH = rootLayoutH + layoutH + label:getContentSize().height
    end
    rootLayout:setContentSize(rootLayoutW, rootLayoutH)
    self:addChild(rootLayout)
    --添加提示标签
    self.tipsLabel = self:createTipsLabel()
    self:addChild(self.tipsLabel)
    --添加闹钟，开始倒计时
    self.clock = self:createClock()
    self:addChild(self.clock)
    self:clockCountdown(30)
    --添加交换按钮
    self:addChild(self:createSwitchButton())
    --添加完成按钮
    self:addChild(self:createCompleteButton())
    --添加临时操作节点
    self.tempNode = cc.Node:create()
    self:addChild(self.tempNode)
    --添加临时动作节点
    self.tempActionNode = cc.Node:create()
    self:addChild(self.tempActionNode)
end

--[[
    @function initEvent      初始化事件
]] 
function DeployCardView:initEvent()
    local touchCardIndex = 0
    local selectedCardIndex = 0
    local isMoved = false
    local movedIndex = 0
    local function onTouchBegan( touch, event )
        touchCardIndex = self:getTouchCardIndex(touch:getLocation())
        return true  
    end
    local function onTouchEnded( touch, event )
        if isMoved then
            isMoved = false
            self.tempNode:removeAllChildren()
            self.cards[touchCardIndex]:getChildByName("card"):setOpacity(255)
            if movedIndex > 0 then
                self:switchCardPosition(touchCardIndex, movedIndex)
                touchCardIndex = 0
                movedIndex = 0
                self:updateCardMovedStyle(movedIndex)
            end
        else
            if selectedCardIndex > 0 and touchCardIndex > 0 and selectedCardIndex ~= touchCardIndex then
                self:switchCardPosition(selectedCardIndex, touchCardIndex)
                touchCardIndex = 0
                selectedCardIndex = 0
            else
                if touchCardIndex > 0 then
                    if selectedCardIndex == touchCardIndex then
                        selectedCardIndex = 0
                    else 
                        selectedCardIndex = touchCardIndex
                    end
                    self:updateCardSelectedStyle(selectedCardIndex, 1.15, 200)
                end
            end
        end
    end
    
    local function onTouchMoved(touch, event)
        if touchCardIndex > 0 then
            isMoved = true
            selectedCardIndex = 0
            self:updateCardSelectedStyle(touchCardIndex, 1 , 100)

            local tempCard = self.tempNode:getChildByName("tempCard")
            if not tempCard then
                local card = self.cards[touchCardIndex]:getChildByName("card")
                local cardPos = self:convertToNodeSpace(card:getParent():convertToWorldSpaceAR(cc.p(card:getPosition())))
                local tempCard = Card:create({cardByte = card.cardByte}):setAnchorPoint(cc.p(0.5, 0.5)):move(cardPos):setName("tempCard")
                tempCard:setOpacity(170)
                self.tempNode:addChild(tempCard)
            else
                local delta = touch:getDelta() --获取滑动的距离
                local posX, posY = tempCard:getPosition()  --获取当前的位置
                tempCard:setPosition(cc.p(posX + delta.x / self:getScale(), posY + delta.y / self:getScale())) --给精灵重新设置位置

                local index = self:getTouchCardIndex(touch:getLocation())
                if movedIndex ~= index and index ~= touchCardIndex then
                    movedIndex = index
                    self:updateCardMovedStyle(movedIndex)
                end
            end
        end
    end
 
    local listener1 = cc.EventListenerTouchOneByOne:create()  --创建一个单点事件监听
    listener1:setSwallowTouches(true)  --是否向下传递
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher() 
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self) --分发监听事件
end

--[[
    @function createDeployLable      创建牌型标签
    @param #margin table             边界参数
]] 
function DeployCardView:createDeployLable(margin)
    local parameter = ccui.LinearLayoutParameter:create():setGravity(ccui.LinearGravity.centerVertical)
    parameter:setMargin(margin)
    
    local label = ccui.Text:create("", "Arial", 27):setColor(cc.c3b(255,255,0)):setAnchorPoint(0, 0.5):setLayoutParameter(parameter)
    return label
end

--[[
    @function createDeployCheck      创建牌型检查图标
]] 
function DeployCardView:createDeployCheck()
    local parameter = ccui.LinearLayoutParameter:create():setGravity(ccui.LinearGravity.centerVertical)
    parameter:setMargin({ left = 0, right = 20, top = 0, bottom = 0})
    
    local deployCheck = ccui.ImageView:create("Images/JasonLiu/deployCard/room_placecard_right.png"):setLayoutParameter(parameter)
    return deployCheck, {w = 20 , h = 00}
end

--[[
    @function createCardLayout      创建一张牌
    @param #cardByte int            牌的byte值
    @param #layer int               层级
]] 
function DeployCardView:createCardLayout(cardByte, layer)
    local parameter = ccui.LinearLayoutParameter:create()
    parameter:setMargin({ left = 0, right = 10, top = 5, bottom = 5})
    
    local cardLayout = ccui.Layout:create():setLayoutType(ccui.LayoutType.RELATIVE):setLayoutParameter(parameter)
    local card = Card:create({cardByte = cardByte}):setAnchorPoint(cc.p(0.5, 0.5)):setName("card")
    local rootBg = ccui.ImageView:create("Images/JasonLiu/deployCard/poker_bg.png"):setScale9Enabled(true)
        :setContentSize(cc.size(card:getContentSize().width + 11, card:getContentSize().height + 15)):setOpacity(80)
    local cardBg = ccui.ImageView:create("Images/JasonLiu/deployCard/poker_selected.png"):setScale9Enabled(true)
        :setContentSize(cc.size(card:getContentSize().width, card:getContentSize().height)):setAnchorPoint(cc.p(0.5, 0.5))
        :setVisible(false):setName("bg")
    local highlight = ccui.ImageView:create("Images/JasonLiu/deployCard/susun_highlight_cover.png"):setScale9Enabled(true):setVisible(false)
        :setContentSize(card:getContentSize()):setAnchorPoint(cc.p(0.5, 0.5)):setName("highlight"):setOpacity(200)
    local cardNode = ccui.Widget:create():setLayoutParameter(ccui.RelativeLayoutParameter:create():setAlign(ccui.RelativeAlign.centerInParent)):setTag(layer)
    cardNode:addChild(cardBg)
    cardNode:addChild(card)
    card:addChild(highlight)   
    cardLayout:addChild(rootBg)
    cardLayout:addChild(cardNode)
    cardLayout:setContentSize(rootBg:getContentSize())
    table.insert(self.cards, cardNode)

    return cardLayout, {w = 10 , h = 10}
end

--[[
    @function createSwitchButton      创建交换按钮
]] 
function DeployCardView:createSwitchButton()
    local button = ccui.Button:create("Images/JasonLiu/deployCard/panel_switch_content_zh_HK.png"):move(-460, -470)
    button:addTouchEventListener(function(sender, eventType)
        if (0 == eventType) then
            local tempByte = { [2] = {}, [3] = {}}
            for i, node in ipairs(self.cards) do
                if node:getTag() == 2 or node:getTag() == 3 then
                    table.insert(tempByte[node:getTag()], node:getChildByName("card").cardByte)
                end
            end
            for i, node in ipairs(self.cards) do
                if node:getTag() == 2 or node:getTag() == 3 then
                    local temp = table.remove(tempByte[node:getTag() == 2 and 3 or 2], 1)
                    node:getChildByName("card").cardByte = temp
                end
            end

            self:getCtr():updateCardsData()
        end
    end)

    return button
end

--[[
    @function createCompleteButton      创建完成按钮
]] 
function DeployCardView:createCompleteButton()
    local button = ccui.Button:create("Images/JasonLiu/deployCard/panel_switch_btn.png"):move(0, -470):setTitleText("完成"):setTitleFontSize(24):setScale(1.4)
    button:addTouchEventListener(function(sender, eventType)
        self.clock:stopAllActions()
        self:clockCountdown(30)
    end)
    return button
end

--[[
    @function createTipsLabel      创建提示标签
]] 
function DeployCardView:createTipsLabel()
    local label = ccui.Text:create("点击或者拖动都可以交换牌哟", "Arial", 33):setColor(cc.c3b(80,217,86)):setLayoutParameter(parameter):move(0, 320)

    return label
end

--[[
    @function createClock      创建闹钟
]] 
function DeployCardView:createClock()
    local clock = cc.Node:create():move(0, 450)
    local bg = cc.Sprite:create("Images/JasonLiu/deployCard/placecard_countdownbg.png"):setContentSize(160, 160)
    clock:addChild(bg)
	local circleProgressBar = cc.ProgressTimer:create(cc.Sprite:create("Images/JasonLiu/deployCard/placecard_countdown.png"):setContentSize(148, 148)):setType(cc.PROGRESS_TIMER_TYPE_RADIAL):setPercentage(100):setName("progress")
    clock:addChild(circleProgressBar)
    local label = cc.Label:createWithTTF("30", "fonts/arial.ttf", 70, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER):setTextColor(cc.c3b(80,217,86)):setName("label")
    clock:addChild(label)

    return clock
end

--[[
    @function clockCountdown      开始闹钟倒计时
    @param #count int             倒计时秒数
]] 
function DeployCardView:clockCountdown(count)
    local label = self.clock:getChildByName("label")
    local progress = self.clock:getChildByName("progress")
    label:setString(count)
    progress:setPercentage(100):getSprite():setTexture("Images/JasonLiu/deployCard/placecard_countdown.png"):setContentSize(148, 148)
    self.tipsLabel:setString("点击或者拖动都可以交换牌哟")
    local c = count
    schedule(self.clock, function()  
        c = c - 0.1
        progress:setPercentage(100 / count * c)
        if math.fmod(c, 1) < 0.1 then
            label:setString(string.format("%d", c))
            if math.modf(c / 1) == 10 then
                progress:getSprite():setTexture("Images/JasonLiu/deployCard/placecard_countdown_red.png"):setContentSize(148, 148)
                self.tipsLabel:setString("老板，时间快到咯！")
            elseif math.modf(c / 1) == 0 then
                progress:setPercentage(0)
                self.clock:stopAllActions()
            end
        end
    end, 0.1)  
end

--[[
    @function switchCardPosition      交换牌的位置
    @param #index1 int                第一张牌的索引
    @param #index2 int                第二张牌的索引
]] 
function DeployCardView:switchCardPosition(index1, index2)
    local actionTime = 0.3
    local card1, card2 = self.cards[index1]:getChildByName("card"), self.cards[index2]:getChildByName("card")
    local card1Pos = self:convertToNodeSpace(card1:getParent():convertToWorldSpaceAR(cc.p(card1:getPosition())))
    local card2Pos = self:convertToNodeSpace(card2:getParent():convertToWorldSpaceAR(cc.p(card2:getPosition())))
    local newCard1 = Card:create({cardByte = card1.cardByte}):setAnchorPoint(cc.p(0.5, 0.5)):move(card1Pos)
    local newCard2 = Card:create({cardByte = card2.cardByte}):setAnchorPoint(cc.p(0.5, 0.5)):move(card2Pos)
    
    card1:setVisible(false):setScale(1):setOpacity(255)
    card2:setVisible(false):setScale(1):setOpacity(255)

    newCard1:runAction(cc.MoveTo:create(actionTime, card2Pos))
    newCard2:runAction(cc.MoveTo:create(actionTime, card1Pos))
    self.tempNode:addChild(newCard2)
    self.tempNode:addChild(newCard1)

    performWithDelay(self, function()  
        card1.cardByte = newCard2.cardByte
        card2.cardByte = newCard1.cardByte
        card1:setVisible(true)
        card2:setVisible(true)
        self.tempNode:removeAllChildren()

        self:getCtr():updateCardsData()
    end, actionTime)  
end

--[[
    @function updateCardSelectedStyle      更新牌选中时样式
    @param #index int                      牌的索引
    @param #scale float                    缩放值
    @param #opacity int                    透明值
]] 
function DeployCardView:updateCardSelectedStyle(index, scale, opacity)
    for i, v in ipairs(self.cards) do
        local card = v:getChildByName("card")
        if i == index then
            card:setScale(scale):setOpacity(opacity)
        elseif card:getScale() ~= 1 or card:getOpacity() ~= 255 then
            card:setScale(1):setOpacity(255)
        end
    end
end

--[[
    @function updateCardMovedStyle      更新牌移动时样式
    @param #index int                   牌的索引
]] 
function DeployCardView:updateCardMovedStyle(index)
    for i, v in ipairs(self.cards) do
        local cardBg = v:getChildByName("bg")
        if i == index then
            cardBg:setVisible(true)
        elseif cardBg:isVisible() then
            cardBg:setVisible(false)
        end
    end
end

--[[
    @function updatePaiXingLabel      更新牌型标签
    @param #layer int                 层级
    @param #string string             牌型
]] 
function DeployCardView:updatePaiXingLabel(layer, string)
    local lable = self.labels[layer]
    if lable then
        lable:setString(string)
    end
end

--[[
    @function updataCardsPaiXingCorrectStyle      更新满足牌型时牌的样式
    @param #layer int                             层级
    @param #cards table                           对应的牌
]] 
function DeployCardView:updataCardsPaiXingCorrectStyle(layer, cards)
    if cards then
        for i, node in ipairs(self.cards) do
            if node:getTag() == layer then
                local card = node:getChildByName("card")
                local highlight = card:getChildByName("highlight")
                highlight:setVisible(false)
                for i, v in ipairs(cards) do
                    if card.cardByte == v then
                        highlight:setVisible(true)
                    end
                end
            end
        end
    end
end

--[[
    @function updatePaiXing         更新牌型
    @param #layer int               层级
    @param #paixing string          牌型
    @param #cards table             对应的牌
]] 
function DeployCardView:updatePaiXing(layer, paixing, cards)
    self:updatePaiXingLabel(layer, paixing)
    self:updataCardsPaiXingCorrectStyle(layer, cards)
end

--[[
    @function updateCheck           更新牌型检查图标
    @param #layer int               层级
    @param #flag bool               是否正确
]] 
function DeployCardView:updateCheck(layer, flag)
    local check = self.checks[layer]
    if check then
        check:loadTexture(flag and "Images/JasonLiu/deployCard/room_placecard_right.png" or "Images/JasonLiu/deployCard/room_placecard_wrong.png")
    end
end

--[[
    @function getTouchCardIndex      获取触摸到牌的位置
    @return #index int               牌的索引 
]] 
function DeployCardView:getTouchCardIndex(location)
    for i, v in ipairs(self.cards) do
        local point = v:getParent():convertToWorldSpaceAR(cc.p(v:getPosition()))
        local cardSize = v:getChildByName("card"):getContentSize()
        if math.abs(location.x - point.x) < cardSize.width * self:getScale() / 2 and math.abs(location.y - point.y) < cardSize.height * self:getScale() / 2 then
            return i
        end
    end

    return 0
end

--[[
    @function getCardsByteData           获取所有牌的byte值
    @return #data table                  所有牌的byte
]] 
function DeployCardView:getCardsByteData()
    local data = {}
    for i, node in ipairs(self.cards) do
        if not data[node:getTag()] then
            data[node:getTag()] = {}
        end
        table.insert(data[node:getTag()], node:getChildByName("card").cardByte)
    end

    return data
end

--[[
    @function getCardShineAction         获取牌的擦亮动作
    @return #action Action               Action 
]] 
function DeployCardView:getCardShineAction()
    local spriteBatchNode = cc.SpriteBatchNode:create("Images/JasonLiu/deployCard/susun_suit_flash_swf_pin.png")
    local texture = spriteBatchNode:getTexture()

	local animation = cc.Animation:create()
	animation:addSpriteFrameWithTexture(texture, cc.rect(120 + 70 * 2,0,70,90))
	animation:addSpriteFrameWithTexture(texture, cc.rect(120 + 70,0,70,90))
	animation:addSpriteFrameWithTexture(texture, cc.rect(120,0,70,90))
	animation:addSpriteFrameWithTexture(texture, cc.rect(155,95,70,90))
	animation:addSpriteFrameWithTexture(texture, cc.rect(155 + 70,95,70,90))
	animation:addSpriteFrameWithTexture(texture, cc.rect(155 + 70 * 2,95,70,90))
	animation:setDelayPerUnit(2 * 0.05 / 3)
    animation:setRestoreOriginalFrame(true)

    return cc.Sequence:create(cc.ScaleTo:create(0.01, 2), cc.Animate:create(animation))
end

--[[
    @function runCardsShineAction        执行指定行内牌的擦亮动作
    @param #layer int                    层级
    @param #cards table                  对应的牌
]] 
function DeployCardView:runCardsShineAction(layer, cards)
    local actionTime = 0
    if cards then
        for i, node in ipairs(self.cards) do
            if node:getTag() == layer then
                self.tempActionNode:removeAllChildren()
                local card = node:getChildByName("card")
                if table.keyof(cards, card.cardByte) then
                    performWithDelay(node, function()  
                        local cardPos = self:convertToNodeSpace(card:getParent():convertToWorldSpaceAR(cc.p(card:getPosition())))
                        local sprite = cc.Sprite:create():move(cardPos):setContentSize(card:getContentSize())
                        sprite:runAction( self:getCardShineAction() )
                        self.tempActionNode:addChild(sprite)
                    end, actionTime)  
                    actionTime = actionTime + 0.03
                end
            end
        end
    end
end

return DeployCardView;