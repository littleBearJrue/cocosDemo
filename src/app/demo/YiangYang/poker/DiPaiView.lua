-- @Author: YiangYang
-- @Date:   2018-10-24 17:15:40
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 17:12:47

local DiPaiView = class("DiPaiView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend
local CardView = require("app.demo.YiangYang.CardView")
BehaviorExtend(DiPaiView)
local ImageRoot = "yiang/cangkulan/"

function DiPaiView:ctor(data)
	self:initLayout(data)
end

function DiPaiView:initLayout(data)
	self:setLayoutType(ccui.LayoutType.VERTICAL)
	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self:setBackGroundColor(cc.c3b(255, 255, 0));

	--头部描述
	self.title = ccui.Text:create()
	-- self.title:setAnchorPoint(cc.p(0.5,0.5))
	self.title:setString("18张")
	self.title:setFontSize(20)
	-- self.title:setTextColor(cc.c4b(55,55,55,255))

	--parameter
	local tp = ccui.LinearLayoutParameter:create()
    tp:setGravity(ccui.LinearGravity.centerHorizontal) --横向居中
    self.title:setLayoutParameter(tp)
    self:addChild(self.title)

    --底部布局
    local blayout = ccui.Layout:create()
    blayout:setLayoutType(ccui.LayoutType.RELATIVE)
 --    blayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- blayout:setBackGroundColor(cc.c3b(255, 0, 0));

    --底部布局parameter
    local lp = ccui.LinearLayoutParameter:create()
    lp:setGravity(ccui.LinearGravity.centerHorizontal) --横向居中
    -- lp:setMargin({top = 50})
    blayout:setLayoutParameter(lp)
    -- blayout:setAnchorPoint(0.5,1)
    self:addChild(blayout)

    --底部背景
    self.bg = ccui.ImageView:create(ImageRoot.."poker_cover.png")
    self.bg:setScale(0.7,0.7)
    -- dump(self.bg:getContentSize(), "ContentSize = ")
    local w = self.bg:getContentSize().width
    local h = self.bg:getContentSize().height

    blayout:setContentSize(cc.size(w*0.7,h*0.7))
    self:setContentSize(cc.size(w*0.7,h*0.7+30))

    --底部背景parameter
	local bgp = ccui.RelativeLayoutParameter:create()
	bgp:setAlign(ccui.RelativeAlign.centerInParent)
    self.bg:setLayoutParameter(bgp)
    blayout:addChild(self.bg)
    -- 底牌
    self.cardview = CardView.new()
    self.cardview:setScale(0.3,0.3)
    self.cardview.cardStyle = 1 -- 背面
    self.cardview:setLayoutParameter(bgp:clone())
    blayout:addChild(self.cardview)

end

--获取底牌世界坐标
function DiPaiView:getDiPaiWorldPos()
	local pos = {}
	local localPos = cc.p(self.cardview:getPositionX(),self.cardview:getPositionY())
	local worldPos = self.cardview:getParent():convertToWorldSpaceAR(localPos)
	pos.x = worldPos.x
	pos.y = worldPos.y
	-- dump(pos, "pos => ")
	return pos
end

--复制一张底牌
function DiPaiView:getCloneDiPai()
	local card = self.cardview:clone()
	card:addTo(self.cardview:getParent())
	return card
end

--[[
	更新界面
	data.title
	data.cardStyle
]]
function DiPaiView:updateView( data )
	if data then
		if data.show then
			self.cardview:setVisible(true)
		else
			self.cardview:setVisible(false)
		end
		if data.title then
			self.title:setString(data.title.."张")
		else
			self.title:setString("弃牌区")
		end
		if data.cardStyle then
			self.cardview.cardStyle = data.cardStyle
		end
		
		if data.cardTByte then
			self.cardview.cardTByte = data.cardTByte
		end

		if data.cardValue then
			self.cardview.cardValue = data.cardValue
		end

		if data.cardType then
			self.cardview.cardType = data.cardType
		end

	end
end

return DiPaiView