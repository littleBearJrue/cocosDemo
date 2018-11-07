--[[--ldoc desc
@Module BetCtr.lua
@Author AeishenLin

Date: 2018-10-26 10:31:39
Last Modified by: AeishenLin
Last Modified time: 2018-10-26 18:45:36
]]
local appPath = "app.demo.AeishenLin.Bet"
local BetCtr = class("BetCtr",cc.load("boyaa").mvc.BoyaaCtr);
local BetView =  require(appPath..".BetView")
local ChipBtnView = require(appPath..".ChipBtnView")
local Chip = require("app/demo/AeishenLin/Chip/Chip")
-- local TestViewBehavior =  require(appPath..".testView.TestViewBehavior")


local EvenConfig = {
	chipBtnEvent = "chipBtnEvent",
	betViewEvent = "betViewEvent",
	gameResultEvent = "gameResultEvent"
}

function BetCtr:ctor()
	self.chipTag = 1       --初始化筹码按键为第一个筹码按键
	self.SectionTag = nil       --初始化下注触摸区域编号为空
	self.winSection = {}
	self.loseSection = {}
end

--创建下注背景视图
local function createBetView(self)
    local betView = BetView.new();
    betView:bindCtr(self);
    betView:setScale(0.55,0.55)
    return betView
end

--创建筹码按钮视图
local function createChipBtnView(self)
	local chipBtnView = ChipBtnView.new()
	chipBtnView:bindCtr(self)
    chipBtnView:setPosition(cc.p(0,-630))
    return chipBtnView
end

---创建能飞的筹码
local function createChip(chipTag)
    local chip = Chip.new()
    chip.tag = chipTag
    chip:setPosition(cc.p(0, - 700))
    return chip
end

---初始化设置所有区域的筹码数量为0
local function setSectionValue(view)
	local count = view.sectionCount
	for i = 1, count do
		local target = view:getChildByTag(i)
		target.tagWithValue = {0,0,0,0}
	end
end


---记录该区域上对应值的筹码的个数
local function updateSectionValue(target,chipTag)
	for _chipTag, _ in ipairs(target.tagWithValue) do         
		if _chipTag == chipTag then
			target.tagWithValue[_chipTag] = target.tagWithValue[_chipTag] + 1
		end
	end
end

---获取选中区域的随机坐标
local function getRandomPos(self, sectionTag, chip)
	local x,y
	local chipWidth = chip:getBoundingBox().width
	local target = self:getView():getChildByTag(sectionTag)  
	local targetWidth = target:getBoundingBox().width
	local targetHegiht = target:getBoundingBox().height

	if sectionTag >= 1 and sectionTag <= 6 then 
		local threeImgH = self:getView():getChildByTag(13):getBoundingBox().height
		local fourImgW = self:getView():getChildByTag(17):getBoundingBox().width
		local fiveImgW = self:getView():getChildByTag(20):getBoundingBox().width
		if sectionTag == 1 then 
			x = math.random(chipWidth/2 + 2, targetWidth - fourImgW/2 - chipWidth/2 - 2)
			y = math.random(chipWidth/2 + 2, targetHegiht - threeImgH/2 - chipWidth/2 - 2)
		elseif sectionTag == 2 then 
			x = math.random(chipWidth/2 + fourImgW/2 + 2, targetWidth - chipWidth/2 - 2)
			y = math.random(chipWidth/2 + 2, targetHegiht - threeImgH/2 - chipWidth/2 - 2)
		elseif sectionTag == 3 then 	
			x = math.random(chipWidth/2 + 2, targetWidth - fourImgW/2 - chipWidth/2 - 2)
			y = math.random(chipWidth/2 + threeImgH/2 + 2, targetHegiht - threeImgH/2 - chipWidth/2 - 2)
		elseif sectionTag == 4 then 	
			x = math.random(chipWidth/2 + fourImgW/2 + 2, targetWidth - chipWidth/2 - 2)
			y = math.random(chipWidth/2 + threeImgH/2 + 2, targetHegiht - threeImgH/2 - chipWidth/2 - 2)
		elseif sectionTag == 5 then 
			x = math.random(chipWidth/2 + fiveImgW + 2, targetWidth - fourImgW/2 - chipWidth/2 - 2)
			y = math.random(chipWidth/2 + threeImgH/2 + 2, targetHegiht - chipWidth/2 - 2)
		elseif sectionTag == 6 then 
			x = math.random(chipWidth/2 + fourImgW/2 + 2, targetWidth - chipWidth/2 - fiveImgW - 2)
			y = math.random(chipWidth/2 + threeImgH/2+ 2, targetHegiht - chipWidth/2 - 2)
		end
	elseif sectionTag >= 7 and sectionTag <= 21 then 
		x = math.random(chipWidth/2 + 4, targetWidth - chipWidth/2 - 4)
		y = math.random(chipWidth/2 + 4, targetHegiht - chipWidth/2 - 4)
	end
    return x,y
end

---控制筹码飞向桌面
local function flyChipToDesk(self, chipTag, target, startPos, userId) 
	local chip = createChip(chipTag)
	chip:setPosition(startPos)
	chip.userId = userId;
	local endX, endY = getRandomPos(self, self.SectionTag,chip)                  --设置筹码在选中区域随机位置，该位置为选中区域上的坐标，即节点坐标
    local worldPos = target:convertToWorldSpace({x = endX, y = endY});   --将筹码在选中区域随机位置转换为世界坐标
	local newNodePos = self:getView():convertToNodeSpace(worldPos)       --将筹码在选中区域随机位置转换为betView上的坐标，也是节点坐标	
	self:getView():addChild(chip)                                        --先将筹码添加到betView作为其子物体

    local actionMoveDone = cc.CallFunc:create(function ()   --筹码运动结束后的回调函数
        local chipCount = target:getChildrenCount()         --获取该区域上的筹码数量  
        chip:removeFromParent()                             --筹码脱离原父物体betView         
        target:addChild(chip)                               --筹码作为该区域的新的子物体
        chip:setTag(chipCount + 1)                          --给每个区域新加的筹码设置编号
        chip:setPosition(cc.p(endX,endY))                   --筹码设置位置为选中区域随机位置
        print("当前区域编号："..self.SectionTag..";  ".."当前区域筹码数量："..#target:getChildren())
    end)

    local actionMove = cc.MoveTo:create(0.4,cc.p(newNodePos.x,newNodePos.y))  --筹码飞到对应世界坐标位置
    chip:runAction(cc.Sequence:create(actionMove, actionMoveDone))
end

---控制筹码飞回玩家手中或钱庄
local function FlyChipBack(self, chip, target, endPos)
    local worldPos = self:getView():convertToWorldSpace(endPos);
	local newNodePos = target:convertToNodeSpace(worldPos)
	local actionMoveDone = cc.CallFunc:create(function ()   --筹码运动结束后的回调函数
		chip:removeFromParent()
    end)
    local actionMove = cc.MoveTo:create(0.4,cc.p(newNodePos.x,newNodePos.y))  --筹码飞到对应坐标位置
    chip:runAction(cc.Sequence:create(actionMove, actionMoveDone))
end

---筹码点击事件更新选中筹码值
function BetCtr:chipBtnEvent(event)
	self.chipTag = event._usedata.newValue
end

---下注区域点击事件更新选中下注区域
function BetCtr:betViewEvent(event)
	self.SectionTag =  event._usedata.newTag                              --获取选中区域的Tag                 
    local target = self:getView():getChildByTag(self.SectionTag)          --通过Tag获得选中区域
	updateSectionValue(target,self.chipTag)                     --记录该区域上对应值的筹码的个数
	flyChipToDesk(self, self.chipTag, target, cc.p(0, - 700), 1) 
end

--根据游戏结果赔付删除桌面筹码
function BetCtr:gameResultEvent(event)
	self.winSection = event._usedata.winSection
    
    
	-- for tag = 1, self:getView().sectionCount do
	-- 	for i = 1, #self.winSection do
	-- 		if self.winSection[i] ~= tag then
	-- 			table.insert(self.loseSection,tag) 
	-- 		end
	-- 	end
	-- end

	---未中奖区域筹码回收
	-- for i = 1, #self.loseSection do
	-- 	if self:getView():getChildByTag(self.loseSection[i]) then
	-- 		local target = self:getView():getChildByTag(self.loseSection[i])
	-- 		local chipCount = target:getChildrenCount()      --获取该区域上的筹码数量
	-- 		for i = 1, chipCount do 
	-- 			local childChip = target:getChildByTag(i)    --获取该区域上每个筹码
	-- 			FlyChipBack(self, childChip, target, {x = 500, y = 100})
	-- 		end
	-- 	end
    -- end
	
	-- ---中奖区域筹码赔付
	-- for i = 1, #self.winSection do
	-- 	if self:getView():getChildByTag(self.winSection[i]) then
	-- 		local target = self:getView():getChildByTag(self.winSection[i])
	-- 		local chipCount = target:getChildrenCount()      --获取该区域上的筹码数量
	-- 		for i = 1, chipCount do 
	-- 			local childChip = target:getChildByTag(i)    --获取该区域上每个筹码
	-- 			flyChipToDesk(self, childChip.tag, target, cc.p(500, 100), childChip.userId) 
	-- 		end
	-- 	end
	-- end
	
	-- ---中奖区域筹码返回玩家
	-- for i = 1, #self.winSection do
	-- 	if self:getView():getChildByTag(self.winSection[i]) then
	-- 		local target = self:getView():getChildByTag(self.winSection[i])
	-- 		local chipCount = target:getChildrenCount()      --获取该区域上的筹码数量
	-- 		for i = 1, chipCount do 
	-- 			local childChip = target:getChildByTag(i)    --获取该区域上每个筹码
	-- 				--FlyChipBack(self, childChip.tag, target, playerManager:getUserById(childChip.userId).headPos) 
	-- 			if childChip.userId == 1 then                                   --模拟
	-- 				FlyChipBack(self, childChip, target, {x = 0, y = -700}) 
	-- 			end
	-- 		end
	-- 	end
	-- end
	setSectionValue(self.betView)
end


function BetCtr:initView(isBehavior)
	self.betView = createBetView(self)
	self.chipBtnView = createChipBtnView(self)
	self.betView:addChild(self.chipBtnView)
	self:setView(self.betView)
	setSectionValue(self.betView)
	self:registerEvent()
end

--注册消息函数
function BetCtr:registerEvent()
	for eventName, funcName in pairs(EvenConfig) do
		if self[funcName] then
			self:bindEventListener(eventName,handler(self,self[funcName]))
		else
			error(eventName.."的回调函数不存在")
		end
	end
end

--view调用发送数据
function BetCtr:sendEvenWithData(data)
	if data.tag then 
		self:sendEvenData(EvenConfig.betViewEvent,{newTag = data.tag});
	elseif data.value then 
		self:sendEvenData(EvenConfig.chipBtnEvent,{newValue = data.value});
	-- elseif data.winSection then 
	-- 	self:sendEvenData(EvenConfig.gameResultEvent,{winSection = data.winSection});
	end	
end

return BetCtr;