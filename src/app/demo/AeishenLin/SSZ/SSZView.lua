local layoutFile = "creator/Scene/AeishenLin/gameScene.ccreator"
local SliderClock = require("app/demo/AeishenLin/Clock/SliderClock")
local CardView = require("app/demo/JrueZhu/widget/SingleCardView.lua")
local ImagePath = "Images/AeishenLin/chip/btn"
local SSZView = class("BetView",cc.load("boyaa").mvc.BoyaaView);
local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local visibleSize= director:getVisibleSize()

function SSZView:ctor()
    self.slotList = {}               --存放牌的所有卡槽
    self.isMovingChange = false;     --是否移动交换
    self.beforeTarget = nil;         --第一张要交换的牌
    self.changeTarget = nil;         --第二张要交换的牌
    self.allCheck = {};
    self:initView()
    self:initButton()
end

----获取cardByte
local function getAllCardByte(slotList)
    local allCardByte = {}
    for i = 1, 13 do
        table.insert(allCardByte, slotList[i].cardByte)   
    end
    return allCardByte
end

----创建时钟
local function createClock(bg)
    local clock = SliderClock.new()
    clock:setPosition(cc.p(bg:getContentSize().width / 2, 3 * bg:getContentSize().height / 4))
    bg:addChild(clock)
end

----创建遮罩
local function createOtherImg(path,parent,Opacity,tag)
    local img = cc.Sprite:create(path)
    img:setAnchorPoint(0,0)
    parent:addChild(img)
    img:setOpacity(Opacity)
    img:setTag(tag)
end

----创建单牌
local function createOneCard(cardByte)
    local card = CardView:create({cardByte = cardByte})
    return card
end

----实现牌的交换
local function cardChange(self,before,change)
    local beforeParent = before:getParent()
    local changeParent = change:getParent()
    local temp = before.cardByte
    before.cardByte = change.cardByte
    change.cardByte = temp
    beforeParent.cardByte = before.cardByte
    changeParent.cardByte = change.cardByte
    self.ctr:sendEvenWithData(getAllCardByte(self.slotList));

    if change:getChildByTag(20) then 
        change:getChildByTag(20):removeFromParent()
    end
    
    self.beforeTarget = nil
    self.isMovingChange = false
    self.changeTarget = nil
end

function SSZView:initView()
    local creatorReader = creator.CreatorReader:createWithFilename(layoutFile);
    creatorReader:setup();
    local view = creatorReader:getNodeGraph();
    view:setPosition(cc.p(origin.x + visibleSize.width / 2 - 200,origin.x + visibleSize.height / 2 - 450))
    self:addChild(view)
    self.bg = view:getChildByName("bg");
    self.slotNode = self.bg:getChildByName("allSlot")
    self.slotList = self.slotNode:getChildren()
    self.allCheck = self.bg:getChildByName("allCheck")
    self.allLabel = self.bg:getChildByName("allLabel")
    self.startButton = self.bg:getChildByName("allButton"):getChildByName("startButton")
    self.changeButton = self.bg:getChildByName("allButton"):getChildByName("changeButton")
    createClock(self.bg)
end


---改变图片显示
function SSZView:changeTexture(imgNum, isRight)
    if isRight == true then
        self.allCheck:getChildren()[imgNum]:setTexture(ImagePath.."/room_placecard_right.png")
    else
        self.allCheck:getChildren()[imgNum]:setTexture(ImagePath.."/room_placecard_wrong.png")
    end
end

---清理上一次符合牌型的牌的遮罩
function SSZView:beforeSetCheckCard()
    for i, slot in ipairs(self.slotList) do
        local target = slot:getChildByTag(i) 
        if target:getChildByTag(22) then 
            target:getChildByTag(22):removeFromParent()
        end
    end
end

---符合牌型的牌增加遮罩
function SSZView:setCheckCardView(parent)
    createOtherImg(ImagePath.."/check.png",parent,80,22)
end

---显示牌型名字
function SSZView:changeString(labelNum, string)
    self.allLabel:getChildren()[labelNum]:setString(string)  
end

---初始化按钮
function SSZView:initButton()
    ---2，3交换
    local function touchEvent1(sender,eventType)
        if eventType == 2 then
            for i, otherSlot in ipairs(self.slotList) do
                if i > 3 and i < 9 then 
                    local otherTarget = otherSlot:getChildByTag(i)    --根据tag获取其他卡槽中的牌
                    local temp = otherTarget.cardByte
                    otherTarget.cardByte = self.slotList[i + 5]:getChildByTag(i + 5).cardByte
                    self.slotList[i + 5]:getChildByTag(i + 5).cardByte = temp
                    otherSlot.cardByte = otherTarget.cardByte
                    self.slotList[i + 5].cardByte = temp
                end
            end
            self.ctr:sendEvenWithData(getAllCardByte(self.slotList));
        end
    end

    ---完成组牌
    local function touchEvent2(sender,eventType)
        if eventType == 2 then
            self.bg:removeAllChildren()
            print("开始比较")
        end
    end

    self.changeButton:addTouchEventListener(touchEvent1)
    self.startButton:addTouchEventListener(touchEvent2)
end

----创建每一张牌
function SSZView:createAllCard(cardList)
    for i,cardByte in ipairs(cardList) do
        local oneCard = createOneCard(cardByte)
        oneCard:setTag(i)
        self.slotList[i]:addChild(oneCard)
        self.slotList[i].cardByte = cardByte
        oneCard.cloneCard = nil                    --牌的一个属性
        ---开始点击
        local function touchBegan(touch, event)
            local target = event:getCurrentTarget()  
		    local targetSize = target:getContentSize()
		    local rect = cc.rect(0, 0, targetSize.width, targetSize.height)
            local p = target:convertTouchToNodeSpace(touch)
           
            if cc.rectContainsPoint(rect, p) then      
                local p_ = self.slotNode:convertTouchToNodeSpace(touch)
                target.cloneCard = createOneCard(target.cardByte)
                target.cloneCard:setScale(1.1,1.1)
                target.cloneCard:setAnchorPoint(0.5,0.5)
                target.cloneCard:setPosition(cc.p(p_.x,p_.y))
                target.cloneCard:addTo(self.slotNode)

                if not self.beforeTarget then
                    self.beforeTarget = target
                    createOtherImg(ImagePath.."/touch.png",target,100,21)
                else
                    self.changeTarget = target
                end
                return true
            end
            return false   
        end
        ---拖动
        local function touchMoved(touch, event)
            local target = event:getCurrentTarget()  
            
            if self.beforeTarget then 
                self.beforeTarget:getChildByTag(21):removeFromParent()
                self.beforeTarget = nil
            end
            
            if target == self.changeTarget then
                self.changeTarget = nil
            end 

            if target.cloneCard then
                target:setVisible(false)
                local currentPosX , currentPosY = target.cloneCard:getPosition();
                local diff = touch:getDelta();
                target.cloneCard:setPosition(cc.p(currentPosX + diff.x,currentPosY + diff.y));
                
                for i, otherSlot in ipairs(self.slotList) do
                    local otherTarget = otherSlot:getChildByTag(i)    --根据tag获取其他卡槽中的牌
                    if otherTarget ~= target then
                        local otherTargetSize = otherTarget:getContentSize()
                        local otherTargetRect = cc.rect(0, 0, otherTargetSize.width, otherTargetSize.height)
                        local otherTargetP = otherTarget:convertTouchToNodeSpace(touch)
                        if cc.rectContainsPoint(otherTargetRect, otherTargetP) then
                            if not otherTarget:getChildByTag(20) then 
                                createOtherImg(ImagePath.."/change.png",otherTarget,100,20)
                                self.isMovingChange = true
                                self.changeTarget = otherTarget
                            else
                                self.isMovingChange = true
                                self.changeTarget = otherTarget
                            end
                        else
                            if otherTarget:getChildByTag(20) then 
                                otherTarget:getChildByTag(20):removeFromParent()
                                self.isMovingChange = false
                                self.changeTarget = nil
                            end
                        end
                    end
                end
                return true
            end
            return false
        end
        ---点击或拖动结束
        local function touchEnded(touch, event)
            local target = event:getCurrentTarget()   
            --移动
            if self.isMovingChange and self.beforeTarget == nil then
                cardChange(self,target,self.changeTarget)
            end
            target:setVisible(true)
            --点击交换
            if self.changeTarget and self.beforeTarget then
                self.beforeTarget:getChildByTag(21):removeFromParent()
                cardChange(self,self.beforeTarget,self.changeTarget)
            end
            if target.cloneCard then
                target.cloneCard:removeFromParent()
                return true
            end
            return false
        end
          
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)             --设置事件吞噬
        listener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touchMoved,cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(touchEnded,cc.Handler.EVENT_TOUCH_ENDED)
        oneCard:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, oneCard)
    end
    self.ctr:sendEvenWithData(getAllCardByte(self.slotList));
end

return SSZView