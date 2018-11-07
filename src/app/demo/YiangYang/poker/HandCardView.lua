-- @Author: YiangYang
-- @Date:   2018-10-24 09:51:56
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 17:13:00

local HandCardView = class("HandCardView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend

local CardView = require("app.demo.YiangYang.CardView")
local ImageRoot = "yiang/cangkulan/"

BehaviorExtend(HandCardView)

local LOWIDTH = 200
local LOHEIGHT = 90
local UPHEIGHT = 10 	--牌选中后上升


function HandCardView:ctor()
	self.seatID = 1				--座位id
	self.cardlist = {}			--存放cardTByte
	self.remainNum = 0 			--剩余牌张		
	self.selectCardView = nil	--选中的牌
	self.cardSpacing = 20		--牌间距 

	self:initLayout()
end

function HandCardView:initLayout()
	--总容器
	self:setLayoutType(ccui.LayoutType.VERTICAL)
	--数字容器
	self.numLayout = ccui.Layout:create()
	self.numLayout:setLayoutType(ccui.LayoutType.HORIZONTAL)
 --    self.numLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self.numLayout:setBackGroundColor(cc.c3b(255,0,0))
	self.xImg = ccui.ImageView:create(ImageRoot.."score_win_times.png"):setScale(0.7,0.7):addTo(self.numLayout)
	--十位上的数字图片
	self.tenImg = ccui.ImageView:create(ImageRoot.."score_win_1.png"):setScale(0.7,0.7):addTo(self.numLayout)
	--个位上的数字图片
	self.geImg = ccui.ImageView:create(ImageRoot.."score_win_0.png"):setScale(0.7,0.7):addTo(self.numLayout)
	--设置数字容器大小
	self.numLayout:setContentSize(cc.size(3*self.xImg:getContentSize().width,self.xImg:getContentSize().height))

	self:addChild(self.numLayout)
	--牌容器
	self.cardLayout = ccui.Layout:create()
	--相对布局排列
    self.cardLayout:setLayoutType(ccui.LayoutType.RELATIVE)
 --    self.cardLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self.cardLayout:setBackGroundColor(cc.c3b(255, 255, 0));
	self.cardLayout:setContentSize(cc.size(LOWIDTH,LOHEIGHT))
	self.cardLayout:addTo(self)

end


--[[
	手牌数据排序
	@data 手牌TByte值集合
]]
local function sortData(data)
	table.sort(data,function (a,b)
		local av = a%16
		local at = math.floor(a/16)
		local bv = b%16
		local bt = math.floor(b/16)
		if at>bt then --花色大的在前
			return true
		elseif at<bt then
			return false
		elseif at == bt then
			if av >= bv then --牌值小的在前
				return false
			elseif av < bv then
				return true 
			end
		end
		return false
	end)
end


--更新界面
function HandCardView:updateView(data,seatID)
	-- body
	self.seatID = seatID or self.seatID
	self.cardlist = data
	self:updateHandCards()

	self:playDealCard()
end

--更新数字
function HandCardView:updateNum( num )
	self.remainNum = num
	if num>9 then
		local ten = math.floor(num/10)
		local ge = num%10
		self.geImg:setVisible(true)
		self.tenImg:loadTexture(ImageRoot.."score_win_"..ten..".png")
		self.geImg:loadTexture(ImageRoot.."score_win_"..ge..".png")
	else
		self.geImg:setVisible(false)
		self.tenImg:loadTexture(ImageRoot.."score_win_"..num..".png")
	end
end

--更新牌张之间间距
function HandCardView:updateSpacing()
	-- if self.seatID == 1 and self.remainNum >=10 then --第一玩家手牌数量多于10张时，换行
	-- 	--TODO
	-- else
		self.cardSpacing = self.remainNum > 5 and (LOWIDTH - 60)/self.remainNum or 25
	-- end
end

--更新手牌
function HandCardView:updateHandCards()
	--清空牌，根据数据重新创建
	self.cardLayout:removeAllChildren()

	self:updateNum(table.nums(self.cardlist))
	self:updateSpacing()
	sortData(self.cardlist)
	self:createHandCards(self.cardlist)
end

--创建手牌
function HandCardView:createHandCards( data )
	if not data or #data<=0 then
		return
	end 

	for i,v in ipairs(data) do
		local cardview = CardView:create()
		cardview:setScale(0.3,0.3)
		cardview:setCascadeOpacityEnabled(true)

		cardview.cardTByte = v
		if self.seatID == 1 then
			cardview.cardStyle = 0
			cardview:setTouchEnabled(true)
		else 
			cardview.cardStyle = 1
		end
		local parameter	=  ccui.RelativeLayoutParameter:create()
		parameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
		parameter:setMargin({ left = self.cardSpacing * (i-1)} )
		cardview:setLayoutParameter(parameter)
	
		self.cardLayout:addChild(cardview)

		local callback = function (sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				self:touchCallback(sender)
			end
		end
		cardview:addTouchEventListener(callback)
	end

end

--牌触摸
function HandCardView:touchCallback(cardview)

	for i,v in pairs(self.cardLayout:getChildren()) do
		--选中牌 界面
		if v == cardview then 
			local cp = cardview:getLayoutParameter()
			if cp:getMargin().top == 0 then
				cp:setMargin({left = cp:getMargin().left, top = -UPHEIGHT})
				--选中
				self.selectCardView = v
			else
				cp:setMargin({left = cp:getMargin().left, top = 0})
				--移除
				self.selectCardView = nil
			end
		else
			--非选中牌 界面
			local vp = v:getLayoutParameter()
			vp:setMargin({left = vp:getMargin().left ,top = 0})
		end
	end
	--刷新界面
	self.cardLayout:requestDoLayout()

end

--执行发牌
function HandCardView:playDealCard()
	--谈入
	self.cardLayout:setCascadeOpacityEnabled(true)
	self.cardLayout:setOpacity(0)
	self.cardLayout:runAction(cc.FadeIn:create(1))
end



--执行出牌
function HandCardView:playOutCard(data)

	local selectCardView = self:getSelectView()
	if selectCardView then
		--获取出牌的世界坐标
		local worldPos = self:getLastHandCardWorldPos(selectCardView)
		--世界坐标的偏移差
		local pos = {x = data.pos.x - worldPos.x , y = data.pos.y - worldPos.y}
		--一号玩家实际选中牌出牌or其他玩家根据数据出牌
		local cardTByte = self.seatID == 1 and selectCardView.cardTByte or data.cardTByte

		local outFunc = function ()
			selectCardView:removeFromParent()
			self:removeCard(cardTByte)
			selectCardView = nil	
			--出牌动画完成发送消息 添加弃牌区 出牌
			local myEvent = cc.EventCustom:new("OutCardAfterAnimaEvent")
			myEvent.outData = cardTByte
			local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
	       	customEventDispatch:dispatchEvent(myEvent)
		end
		--执行抓牌动画
		selectCardView:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(pos.x, pos.y)), cc.CallFunc:create(outFunc)))
		print("出牌")
	else
		print("没有选中的card")
	end 

end


--获取选中的牌
function HandCardView:getSelectView()
	if self.seatID == 1 then
		return self.selectCardView
	else
		return self.cardLayout:getChildren()[#self.cardlist]
	end
end

--抓牌
function HandCardView:addCard(data)
	table.insert(self.cardlist,data.cardTByte)
	self:updateHandCards()
end

--出牌(单张)
function HandCardView:removeCard(cardData)
	--去除打出的牌
	local index = 0 --下标
	for i,v in ipairs(self.cardlist) do
		if v == cardData then
			index = i
		end
	end
	table.remove(self.cardlist,index) --根据下标移除
	self:updateHandCards()
end


--获取手牌选中那张牌或者最后那张牌的世界坐标（用于摸牌动画位移最终位置）
function HandCardView:getLastHandCardWorldPos(myCardview)
	local cardview = myCardview or self.cardLayout:getChildren()[#self.cardlist]
	local pos = {}
	local localPos = cc.p(cardview:getPositionX(),cardview:getPositionY())
	local worldPos = cardview:getParent():convertToWorldSpaceAR(localPos)
	pos.x = worldPos.x
	pos.y = worldPos.y
	return pos
end



return HandCardView