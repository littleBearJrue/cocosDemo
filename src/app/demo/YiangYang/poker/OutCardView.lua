-- @Author: YiangYang
-- @Date:   2018-10-24 10:01:07
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-29 17:13:15

local OutCardView = class("OutCardView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend
local DiPaiView = require("app.demo.YiangYang.poker.DiPaiView")
BehaviorExtend(OutCardView)

function OutCardView:ctor(data)
	self.outCardList = {0x11,0x12,0x13} --临时数据
	self.remainNum = 24
	self:initLayout()
end

function OutCardView:initLayout()
	self:setLayoutType(ccui.LayoutType.HORIZONTAL)
	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self:setBackGroundColor(cc.c3b(255, 255, 0));

	self.dipaiView = DiPaiView.new() --底牌，未摸
	self.chupaiView = DiPaiView.new()--出牌

	self:addChild(self.dipaiView)	
	self:addChild(self.chupaiView)
	local w = self.dipaiView:getContentSize().width
	local h = self.dipaiView:getContentSize().height
	self:setContentSize(cc.size(2*w,h))	

	--改变view
	self.chupaiView:updateView({show = true,cardStyle = 0,cardTByte = 0x11})
	self.dipaiView:updateView({show = true,title = 24 })
end

--获取底牌上面的cardview对象世界坐标
function OutCardView:getDiPaiWorldPos()

	return self.dipaiView:getDiPaiWorldPos()
end

--获取出牌上面的cardview对象世界坐标
function OutCardView:getChuPaiWorldPos()
	return self.chupaiView:getDiPaiWorldPos()
end

--抓牌动画
--data.pos --最终牌的世界坐标位置
function OutCardView:grabCard(data)
	--克隆一张底牌
	local cardview = self.dipaiView:getCloneDiPai()
	--获取底牌的世界坐标
	local worldPos = self:getDiPaiWorldPos()
	--世界坐标的偏移差
	local pos = {x = data.pos.x - worldPos.x , y = data.pos.y - worldPos.y}
	local grapFunc = function ()
		cardview:removeFromParent()
		self:updateViewWithGrabCard()
		--抓牌动画完成发送消息 添加相应手牌
		local myEvent = cc.EventCustom:new("GrabCardAfterAnimaEvent")
		myEvent.grabData = data
	
		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
       	customEventDispatch:dispatchEvent(myEvent)
	end
	--执行抓牌动画
	cardview:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(pos.x, pos.y)), cc.CallFunc:create(grapFunc)))
end


--根据出牌更新界面
function OutCardView:updateViewWithOutCard( data )
	self.chupaiView:updateView({show = true,cardStyle = 0,cardTByte = data})
	--出牌数据缓存起来
	table.insert(self.outCardList,data)
end

--根据抓牌更新界面
function OutCardView:updateViewWithGrabCard()
	if self.remainNum == 0 then return end
	self.remainNum = self.remainNum - 1 --默认每次减一张
	local isShow = self.remainNum > 0 and true or false
	self.dipaiView:updateView({show = isShow,title = self.remainNum})
end



return OutCardView