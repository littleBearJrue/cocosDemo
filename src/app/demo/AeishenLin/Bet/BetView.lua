local BetView = class("BetView",cc.load("boyaa").mvc.BoyaaView);
-- local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

-- BehaviorExtend(BetView);
local imagePath = "Images/AeishenLin/chip/";

function BetView:ctor()
	self.sectionCount = 21; --默认区域数量
    self:initView()
end

---获取点击位置,返回选中区域tag
local function getSection(self,sectionImg)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)             --设置事件吞噬
	local function onTouchBegan(touch, event)
		local target = event:getCurrentTarget()  --获取事件所绑定的 target, 通常是cc.Node及其子类 
		local size = target:getContentSize()
		local rect = cc.rect(0, 0, size.width, size.height)
		local p = target:convertTouchToNodeSpace(touch)
		if cc.rectContainsPoint(rect, p) then            -- 判断触摸点是否在按钮范围内
			local data = {}
			data.tag = target:getTag()
			self.ctr:sendEvenWithData(data);
			return true
		end
		return false
	end
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN) 
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, sectionImg)
	
end

---创建区域图片
local function createSectionImg(self,path,tag)
    local sectionImg = cc.Sprite:create(imagePath..path) 
	self:addChild(sectionImg)
	sectionImg:setOpacity(100)
	sectionImg:setTag(tag)
	getSection(self,sectionImg)
	return sectionImg
end


--创建大大图
local function createFirst(self)
	for i = 1, 6 do
		local firstImg = createSectionImg(self,"btn/bg1.png",i)
		local width = firstImg:getContentSize().width
		local height = firstImg:getContentSize().height 
		self.firstHeight = height
		self.firstWidth = width
		if i >= 2 and i % 2 == 0 then 
			firstImg:setPosition(cc.p(width / 2 + 2, (i/2 - 1) * (height + 6)))		
		else	
			firstImg:setPosition(cc.p(-width / 2 - 2,((i+1)/2 - 1) * (height + 6)))
		end
	end
end

--创建大图
local function createSecond(self)
	for i = 7, 12 do
		local secondImg = createSectionImg(self,"btn/bg2.png",i)
		local width = secondImg:getContentSize().width
		local height = secondImg:getContentSize().height 
		if i >= 7 and i <= 9 then 
			secondImg:setPosition(cc.p(width * (i-8), -height - 12))		
		else	
			secondImg:setPosition(cc.p(width * (i-11),-height * 2 - 12))
		end
	end
end


--创建中图1
local function createThree(self)
	for i = 13, 16 do
		local threeImg = createSectionImg(self,"btn/bg3.png",i)
		local width = threeImg:getContentSize().width
		local height = threeImg:getContentSize().height 
		if i >= 13 and i <= 14 then  
			threeImg:setPosition(cc.p((2 * i - 27) * (width/2 + width/3), -7 + height * 2))		
		else	
			threeImg:setPosition(cc.p((2 * i - 31) * (width/2 + width/3), -1 + self.firstHeight + height * 2))
		end
	end
end


--创建中图2
local function createFour(self)
	for i = 17, 19 do
		local fourImg = createSectionImg(self,"btn/bg4.png",i)
		fourImg:setPosition(cc.p(0, (i - 17) * (self.firstHeight + 5.2)))		
	end
end

--创建小图
local function createFive(self)
	for i = 20, 21 do
		local fiveImg = createSectionImg(self,"btn/bg5.png",i)
		fiveImg:setPosition(cc.p((i * 2 - 41) * (self.firstWidth - 22), self.firstHeight * 2.5 - 14))		
	end
end

--初始创建视图
function BetView:initView()
	local bg = ccui.ImageView:create(imagePath.."koprok_dice_bet.png")
	self.bg = bg
	local bgSize = bg:getContentSize()
	self:setContentSize(bgSize)
	self:addChild(bg)

	createFirst(self)
	createSecond(self)
	createThree(self)
	createFour(self)
	createFive(self)
end

return BetView;