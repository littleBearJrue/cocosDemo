local ChipBtnView = class("ChipBtnView",cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
BehaviorExtend(ChipBtnView);
local imagePath = "Images/AeishenLin/chip/";

function ChipBtnView:ctor()
    self:initView()
end

---创建筹码面值
local function createChipNum(ChipBtn,tag)
    local chipNum = ccui.ImageView:create(imagePath.."chip_"..tag..".png")
    chipNum:setPosition(cc.p(ChipBtn:getContentSize().width/2 , ChipBtn:getContentSize().height/2 ))
    if tag < 3 then 
        chipNum:setScale(0.3,0.4)
    else
        chipNum:setScale(0.4,0.4)
    end
    ChipBtn:addChild(chipNum)
end

---创建高光效果
local function createHighLight(ChipBtn)
    local highLight = ccui.ImageView:create(imagePath.."chip_btn_light.png")
    highLight:setTag(1)
    highLight:setScale(1.5,1.5)
    highLight:setPosition(cc.p(ChipBtn:getContentSize().width/2 , ChipBtn:getContentSize().height/2 + 1 ))
    ChipBtn:addChild(highLight)
end

---去除高光效果
local function removeHighLight(self)
    for i = 1, 4 do
        local _chipBtn = self:getChildByTag(i)    --循环获取四个按键去除高光效果
        if _chipBtn:getChildByTag(1)  then
           _chipBtn:removeChildByTag(1)
        end
    end 
end

---创建每一个筹码按钮的具体过程
local function createChipBtn(self,path,tag)
    local ChipBtn = ccui.Button:create(imagePath..path) 
	self:addChild(ChipBtn)
    ChipBtn:setTag(tag)
    createChipNum(ChipBtn,tag)
    if tag == 1 then
        createHighLight(ChipBtn)
    end

    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            removeHighLight(self)
            createHighLight(ChipBtn)
            local data = {}
			data.value = ChipBtn:getTag()
            self.ctr:sendEvenWithData(data);
        end
    end  

    ChipBtn:addTouchEventListener(touchEvent)  
	return ChipBtn
end

---循环创建4个筹码按钮
local function createBtn(self)
	for i = 1, 4 do
        local ChipBtn = createChipBtn(self,"chip_btn"..i..".png",i)
        local width = ChipBtn:getContentSize().width
	    ChipBtn:setPosition(cc.p(-self.width/2 + width/2 + (i - 1) * (5 + width) - 2,0))
	end
end

--初始创建视图
function ChipBtnView:initView()
	local bg = cc.Sprite:create(imagePath.."bg7.png")
    local bgSize = bg:getContentSize()
    bg:setOpacity(0)
	self:setContentSize(bgSize)
    self:addChild(bg)
    self.width = bgSize.width
	createBtn(self)
end

return ChipBtnView;