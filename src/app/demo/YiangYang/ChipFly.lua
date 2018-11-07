-- @Author: YiangYang
-- @Date:   2018-10-22 14:11:00
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-10-22 17:28:42

local ChipFly = class("ChipFly",function ( )
	return cc.Layer:create()
end)

function ChipFly:ctor( )
	-- body
end

--根据筹码值，创建相应的Node
function ChipFly:getChipNode( chip )
	local coin = ccui.ImageView:create("yiang/coin.png")
	self:addChild(coin,1)
	return coin
end

--执行飞筹码动画
--startPos @cc.p
--endPos @cc.p
function ChipFly:playFlyChipAnim(startPos,endPos,chip)
	local chipNode = self:getChipNode(chip)
	--曲线参数
	local bezier = {
		startPos,
		cc.p((startPos.x + endPos.x)*0.5,(startPos.y + endPos.y)*0.5),
		endPos,
	}
	local delayTime = cc.DelayTime:create(0.05)
	local bezieract = cc.BezierTo:create(1.0,bezier)
	local moveEase = cc.EaseSineOut:create(bezieract)
	local callback = cc.CallFunc:create(function ()
		dump("callback")
		-- chipNode:removeFromParentAndCleanup(true)
	end)
	local action = cc.Sequence:create(delayTime,moveEase,callback)

	chipNode:runAction(action)

end



return ChipFly