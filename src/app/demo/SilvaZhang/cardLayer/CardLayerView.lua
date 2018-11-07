local Utils = import(".Utils")
local designSize = Utils.designConfig.designSize
local CardLayerView = class("CardLayerView",cc.load("boyaa").mvc.BoyaaLayout)

local CardViewAlign = {
	"alignParentBottomCenterHorizontal",
	"alignParentRightCenterVertical",
	"alignParentTopCenterHorizontal",
	"alignParentLeftCenterVertical",
	"centerInParent",
}

function CardLayerView:ctor( ... )
	--初始化视图
	self:init()
end

function CardLayerView:init( )
	--设置整个牌层
	self:setContentSize(designSize.width,designSize.height)
	self:setBackGroundColor(cc.c3b(111,111,111))
	self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	self:setLayoutType(ccui.LayoutType.RELATIVE)
end

--增加一个节点到牌层
function CardLayerView:addChildNode( view,data )
	local index = 0
	if data.viewType == "hand" then
		index = data.seatId
	elseif data.viewType == "out" then
		index = 5
	end
	--设置布局方式
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign[CardViewAlign[index]])
	view:setLayoutParameter(parameter)
	self:addChild(view)
end

--移除一个从牌层
function CardLayerView:removeChildNode( view,data )
end

return CardLayerView