-- @Author: YiangYang
-- @Date:   2018-10-18 18:52:47
-- @Last Modified by   ShuaiYang
-- @Last Modified time 2018-10-26 12:36:25

local mkproprety = function(getFun, setFun)
	local instance = {proprety = true}
	instance.get = getFun
	instance.set = setFun
	setmetatable(instance, {__newIndex = function()
		-- error(1)
	end})
	return instance
end

--图片在Res下的根目录
local imageRoot = "yiang/poker/"

--默认数据
local defaultData = {
	cardTByte = 0x3a, --唯一标识 
	cardValue = 1,		--牌值
	cardType = 1,		--花色 1,2,3,4，
	cardStyle = 0,	--样式（背景），正反面 正面:0,反面：1
}

-- 1 - 13
local ValueTypeConfig = {
	[1] = "red_", 
	[2] = "black_", 
	[3] = "red_", 
	[4] = "black_",
}


local CardView = class("CardView",function ()
	local layout = ccui.Layout:create()
	--相对布局排列
    layout:setLayoutType(ccui.LayoutType.RELATIVE)
 --    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- layout:setBackGroundColor(cc.c3b(255, 255, 0));
	return layout
end)


function CardView:ctor(data)
	local peer = tolua.getpeer(self)
	local mt = getmetatable(peer)
	local __index = mt.__index
	mt.__index = function(_, k)
		if type(CardView[k]) == "table" and CardView[k].proprety == true then
			return CardView[k].get(self)
		elseif __index then
			if type(__index) == "table" then
				return __index[k]
			elseif type(__index) == "function" then
				return __index(_, k)
			end
		end
	end
	mt.__newindex = function(_, k, v)
		if type(CardView[k]) == "table" and CardView[k].proprety == true then
			return CardView[k].set(self, v)
		else
			rawset(_, k, v)
		end
	end

	if not data then
		data = {}
	end 

	self.proprety = {
		cardTByte = data.cardTByte or defaultData.cardTByte,
		cardValue = data.cardValue or defaultData.cardValue,	
		cardType = data.cardType or defaultData.cardType,
		cardStyle = data.cardStyle or defaultData.cardStyle,
	}

	self:initView()
	self:checkDataAndUpdate(self.proprety)
end

CardView.cardStyle = mkproprety(function(self)
	return self.proprety.cardStyle
end,function(self, cardStyle)
	self:checkDataAndUpdate({cardStyle = cardStyle})
end)

CardView.cardTByte = mkproprety(function(self)
	return self.proprety.cardTByte
end,function(self, cardTByte)
	self:checkDataAndUpdate({cardTByte = cardTByte})
end)

CardView.cardValue = mkproprety(function(self)
	return self.proprety.cardValue
end,function(self, cardValue)
	self:checkDataAndUpdate({cardValue = cardValue})
end)

CardView.cardType = mkproprety(function(self)
	return self.proprety.cardType
end,function(self, cardType)
	self:checkDataAndUpdate({cardType = cardType})
end)

--------------------------------------------------------------------------------------------
--初始化布局
function CardView:initView()

	--背景（正反面）
	self.bgSprite = ccui.ImageView:create(imageRoot.."bg.png")
	self:setContentSize(self.bgSprite:getContentSize())
	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self:setBackGroundColor(cc.c3b(193, 193, 32))
	--牌值
	self.valueSprite = ccui.ImageView:create()
	-- self.valueSprite = ccui.ImageView:create(imageRoot.."red_1.png")
	--花色
	self.colorSprite = ccui.ImageView:create()
	-- self.colorSprite = ccui.ImageView:create(imageRoot.."color_1_small.png")
	--中心花色图案
	self.centerSprite = ccui.ImageView:create()
	-- self.centerSprite = ccui.ImageView:create(imageRoot.."black_man_11.png")

	local valueParameter = ccui.RelativeLayoutParameter:create()
	valueParameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	valueParameter:setRelativeName("value")
	valueParameter:setMargin({ left = 8, top = 8})
	self.valueSprite:setLayoutParameter(valueParameter)

	local colorParameter = ccui.RelativeLayoutParameter:create()
	colorParameter:setAlign(ccui.RelativeAlign.locationBelowLeftAlign)
	colorParameter:setRelativeToWidgetName("value")
	colorParameter:setMargin({top = 4})
	self.colorSprite:setLayoutParameter(colorParameter)

	local centerParameter = ccui.RelativeLayoutParameter:create()
	centerParameter:setAlign(ccui.RelativeAlign.centerInParent)
	self.centerSprite:setLayoutParameter(centerParameter)
	
	self:addChild(self.bgSprite)
	self:addChild(self.valueSprite)
	self:addChild(self.colorSprite)
	self:addChild(self.centerSprite)
end

--校验数据并更新view
function CardView:checkDataAndUpdate(data)
	local CardValueTB = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
	local CardTypeTB = {1,2,3,4}
	if not data then
		return
	end

	if data.cardTByte then
		if type(data.cardTByte) == "number" then
			local cardType = math.floor(data.cardTByte/16)
			local cardValue = data.cardTByte%16
			dump(cardValue, "cardValue == ")
			dump(cardType, "cardType == ")
			if table.keyof(CardValueTB,cardValue) and table.keyof(CardTypeTB,cardType) then
				self.proprety.cardValue = cardValue
				self.proprety.cardType = cardType
				self.proprety.cardTByte = data.cardTByte
			else
				error("cardTByte 赋值失败")
			end
		else
			dump(data.cardTByte, "data.cardTByte == ")
			error("cardTByte 赋值失败")
		end
	end
	if data.cardValue then
		if type(data.cardValue) == "number" and table.keyof(CardValueTB,data.cardValue) then
			self.proprety.cardValue = data.cardValue
		else
			error("cardValue 赋值失败")
		end
	end
	if data.cardType then
		if type(data.cardType) == "number" and table.keyof(CardTypeTB,data.cardType) then
			self.proprety.cardType = data.cardType
		else
			error("cardType 赋值失败")
		end
	end
	if data.cardStyle then
		if type(data.cardStyle) == "number" and data.cardStyle == 1 or data.cardStyle == 0 then
			self.proprety.cardStyle = data.cardStyle
		else
			error("cardStyle 赋值失败")
		end
	end
	--数据校验完毕，更新view
	self:updateView()
end


--更新view
function CardView:updateView()

	if self.proprety.cardStyle == 1 then --背面
		self.bgSprite:loadTexture(imageRoot.."bg_an.png")
		self.valueSprite:setVisible(false)
		self.colorSprite:setVisible(false)
		self.centerSprite:setVisible(false)
	elseif self.proprety.cardStyle == 0 then --正面
		self.bgSprite:loadTexture(imageRoot.."bg.png")
		self.valueSprite:setVisible(true)
		self.colorSprite:setVisible(true)
		self.centerSprite:setVisible(true)

		if self.proprety.cardValue == 14 then --小王
			self.valueSprite:loadTexture(imageRoot.."small_joker_word.png")
			self.colorSprite:setVisible(false) 
			self.centerSprite:loadTexture(imageRoot.."small_joker.png")

		elseif self.proprety.cardValue == 15 then --大王
			self.valueSprite:loadTexture(imageRoot.."big_joker_word.png")
			self.colorSprite:setVisible(false) 
			self.centerSprite:loadTexture(imageRoot.."big_joker.png") 

		else --1-13
			self.valueSprite:loadTexture(imageRoot..ValueTypeConfig[self.proprety.cardType]..self.proprety.cardValue..".png")
			self.colorSprite:loadTexture(imageRoot.."color_"..self.proprety.cardType.."_small.png") 
			if self.proprety.cardValue < 11 then
				self.centerSprite:loadTexture(imageRoot.."color_"..self.proprety.cardType..".png")
			else
				self.centerSprite:loadTexture(imageRoot..ValueTypeConfig[self.proprety.cardType].."man_"..self.proprety.cardValue..".png")
			end
		end
		self:requestDoLayout() --通知父节点重新刷新界面(Layout自身方法)
	end

end


return CardView