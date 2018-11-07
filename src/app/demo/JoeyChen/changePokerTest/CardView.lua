local imagePath = "Images/poker/poker/"
local CardView = class("CardView",ccui.Layout)

--监听函数，调用这个函数，返回一个携带set，get函数的表
local mkproprety = function(getFun, setFun)
	local instance = {proprety = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
	end})
	return instance
end

--设置属性的set和get函数，将属性存储到CardView类中
CardView.cardType = mkproprety(function(self)
	return self.property.cardType
end,function(self, key, value)
	self:updateView({cardType = value})
end)

CardView.cardValue = mkproprety(function(self)
	return self.property.cardValue
end,function(self, key, value)
	self:updateView({cardValue = value})
end)

CardView.cardByte = mkproprety(function(self)
	return self.property.cardByte
end,function(self, key, value)
	self:updateView({cardByte = value})
end)

CardView.cardStyle = mkproprety(function(self)
	return self.property.cardStyle
end,function(self, key, value)
	self:updateView({cardStyle = value})
end)

--检测存储数据
local function checkAndSaveData( self,data,isfirst )
	local legal = false
	if data.cardByte and type(data.cardByte) == "number" then
		local cardType = math.floor(data.cardByte/16)
		local cardValue = data.cardByte%16
		if checkAndSaveData(self,{cardType = cardType},false) and checkAndSaveData(self,{cardValue = cardValue},false) then
			self.property.cardType = cardType
			self.property.cardValue = cardValue
			self.property.cardByte = cardType * 16 + cardValue
			legal = true
		end
	end
	if data.cardType and type(data.cardType) == "number" then
		if data.cardType >= 1 and data.cardType <= 5 then
			if isfirst then
				self.property.cardType = data.cardType
			end
			legal = true
		end
	end
	if data.cardValue and type(data.cardValue) == "number" then
		if self.property.cardType >= 1 and self.property.cardType <= 4 then
			if data.cardValue >= 1 and data.cardValue <= 13 then
				if isfirst then
					self.property.cardValue = data.cardValue
				end
				legal = true
			end
		elseif self.property.cardType == 5 then
			if data.cardValue >= 1 and data.cardValue <= 2 then
				if isfirst then
					self.property.cardValue = data.cardValue
				end
				legal = true
			end
		end
	end
	if data.cardStyle and type(data.cardStyle) == "number" then
		if data.cardStyle == 1 or data.cardStyle == 2 then
			self.property.cardStyle = data.cardStyle
			legal = true
		end
	end 
	return legal
end

--获取背景路径
local function getBgPath( self )
	local bgPath
	if self.property.cardStyle == 1 then
		bgPath = imagePath.."bg.png"
	elseif self.property.cardStyle == 2 then
		bgPath = imagePath.."bg_an.png"
	end
	return bgPath
end

--获取数字图片路径
local function getNumberPath( self )
	local numberPath
	if self.property.cardType <= 4 then
		if self.property.cardType == 1 or self.property.cardType == 3 then
			numberPath = imagePath.."red_"..self.property.cardValue..".png"
		end
		if self.property.cardType == 2 or self.property.cardType == 4 then
			numberPath = imagePath.."black_"..self.property.cardValue..".png"
		end
	else
		if self.property.cardValue == 1 then
			numberPath = imagePath.."small_joker_word.png"
		end
		if self.property.cardValue == 2 then
			numberPath = imagePath.."big_joker_word.png"
		end
	end
	return numberPath
end

--获取小图路径
local function getSmallImgPath( self )
	local smallImgPath
	if self.property.cardType <= 4 then
		smallImgPath = imagePath.."color_"..self.property.cardType.."_small.png"
	else
 		
	end
	return smallImgPath
end

--获取大图路径
local function getBigImgPath( self )
	local bigImgPath
	if self.property.cardType <= 4 then
		if self.property.cardValue <= 10 then
			bigImgPath = imagePath.."color_"..self.property.cardType..".png"
		else
			if self.property.cardType == 1 or self.property.cardType == 3 then
				bigImgPath = imagePath.."red_man_"..self.property.cardValue..".png"
			end
			if self.property.cardType == 2 or self.property.cardType == 4 then
				bigImgPath = imagePath.."black_man_"..self.property.cardValue..".png"
			end
		end
	else
		if self.property.cardValue == 1 then
			bigImgPath = imagePath.."small_joker.png"
		end
		if self.property.cardValue == 2 then
			bigImgPath = imagePath.."big_joker.png"
		end
	end
	return bigImgPath
end

--修改属性时更新视图
function CardView:updateView( data )
	if data then
		if not checkAndSaveData(self,data,true) then
			self:setVisible(false)
			return
		end
	end
	self:setVisible(true)
	--替换图片路径
	local bgPath = getBgPath(self)
	local numberPath = getNumberPath(self)
	local smallImgPath = getSmallImgPath(self)
	local bigImgPath = getBigImgPath(self)
	if self.bg then
		if bgPath then
			self.bg:setVisible(true)
			self.bg:loadTexture(bgPath)
		else
			self.bg:setVisible(false)
		end
	end
	if self.property.cardStyle == 1 then
		if self.number then
			if numberPath then
				self.number:getParent():requestDoLayout()
				self.number:setVisible(true)
				self.number:loadTexture(numberPath)
			else
				self.number:setVisible(false)
			end
		end
		if self.smallImg then
			if smallImgPath then
				self.smallImg:setVisible(true)
				self.smallImg:loadTexture(smallImgPath)
			else
				self.smallImg:setVisible(false)
			end
		end
		if self.bigImg then
			if bigImgPath then
				self.bigImg:setVisible(true)
				self.bigImg:loadTexture(bigImgPath)
			else
				self.bigImg:setVisible(false)
			end
		end
	else
		self.number:setVisible(false)
		self.smallImg:setVisible(false)
		self.bigImg:setVisible(false)
	end
end

--进行初始化
local function init( self,class )
	--当获取self中的属性时，会找到self的元表的__index，__index指向一个函数，函数中遍历self的peer表
	--因此获取self属性不存在时，会去peer表中找，peer表没找到，去peer表的元表的__index中找
	--因此现在需要对self数据进行监听，需要设置peer的元表
	local peer = tolua.getpeer(self)
	local mt = getmetatable(peer)
	--记录peer的元表mt已经有的__index属性
	local __index = mt.__index
	mt.__index = function(peerTable, k)
		--属性监听
		if type(class[k]) == "table" and class[k].proprety == true then
			return class[k].get(self)
		--原有元表
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(peerTable, k)
			end
		end
	end
	mt.__newindex = function(peerTable, k, v)
		--属性监听
		if type(class[k]) == "table" and class[k].proprety == true then
			return class[k].set(self,k, v)
		--赋值给peer表
		else
			--不能写成peerTable[k] = v，因为这样写会再次执行mt.__newindex，最后栈溢出
			rawset(peerTable, k, v)
		end
	end
end

--初始化数据
local function initData( self )
	self.property = {
		cardType = 1,
		cardValue = 1,
		cardByte = 0x11,
		cardStyle = 1,
	}
end

--初始创建视图
local function initView( self )
	--设置为相对布局
	self:setLayoutType(ccui.LayoutType.RELATIVE)

	
	--获取路径
	local bgPath = getBgPath(self)
	local numberPath = getNumberPath(self)
	local smallImgPath = getSmallImgPath(self)
	local bigImgPath = getBigImgPath(self)

	--创建背景
	local bg = ccui.ImageView:create(bgPath)
	self.bg = bg
	local bgSize = bg:getContentSize()
	self:setContentSize(bgSize)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.centerInParent)
	bg:setLayoutParameter(parameter)
	self:addChild(bg)

	--创建数字
	local number = ccui.ImageView:create(numberPath)
	self.number = number
	number:ignoreContentAdaptWithSize(true)
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setRelativeName("number")
	parameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	parameter:setMargin({ left = 10, top = 10 } )
	number:setLayoutParameter(parameter)
	self:addChild(number)
	
	--创建小图
	local smallImg = ccui.ImageView:create(smallImgPath)
	self.smallImg = smallImg
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setRelativeToWidgetName("number")
	parameter:setAlign(ccui.RelativeAlign.locationBelowLeftAlign)
	parameter:setMargin({ left = 0, top = 5 } )
	smallImg:setLayoutParameter(parameter)
	self:addChild(smallImg)
	
	--创建大图
	local bigImg = ccui.ImageView:create(bigImgPath)
	self.bigImg = bigImg
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.centerInParent)
	bigImg:setLayoutParameter(parameter)
	self:addChild(bigImg)
end

--构造函数，CardView是table，self是userdata
function CardView:ctor( data )
	init(self,CardView)
	initData(self)
	initView(self)
	self:updateView(data)
end

return CardView