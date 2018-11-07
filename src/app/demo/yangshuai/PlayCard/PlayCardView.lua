--[[--ldoc desc
@module PlayCardView
@author ShuaiYang

Date   2018-10-24 10:22:31
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:08:02
]]
local appPath = "app.demo.yangshuai"

local PlayCardView = class("PlayCardView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local resRootPath = "Images/yangshuai/";
local CardView = require(appPath..".PlayCard.CardView")


BehaviorExtend(PlayCardView);

PlayCardView.config = {
	cardScale = {x = 0.35, y = 0.35}, --缩放
	isShowCard = true,--是否显示手牌
}

PlayCardView.aminConfig = {
	[1] = {
		moPai = {
			time = 0.5,
			endPos = {x= 0,y = -160},
			startPos = {x= -45,y = 40},
		},
		chuPai = {
			time = 0.5,
			endPos = {x= 10,y = 40},
			startPos = {x= 15,y = -150},
		},
	},


}

function PlayCardView:ctor()
	-- body
	self.bgSprite = ccui.ImageView:create(resRootPath.."table_bg.png")
	-- self:setContentSize(cc.Director:getInstance():getWinSize())
	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self:setBackGroundColor(cc.c3b(193, 193, 32))
	


	self.btnLayout = ccui.Layout:create();
  	self.btnLayout:setLayoutType(ccui.LayoutType.HORIZONTAL);

  	local moPaiBtn = ccui.Button:create()
	moPaiBtn:setTitleText("摸牌")
	moPaiBtn:addClickEventListener(function(sender)
        self:getCtr():moPaiAction()
    end)
	self.btnLayout:addChild(moPaiBtn)

	local faPaiBtn = ccui.Button:create()
	faPaiBtn:setTitleText("发牌")
	faPaiBtn:addClickEventListener(function(sender)
		self:getCtr():faPai()
    end)
	self.btnLayout:addChild(faPaiBtn)

	self.bgSprite:addTo(self)

	self.btnLayout:addTo(self)
end

-- byte 牌值  seyle 牌面类型  userId 用户id  animType 动画类型 1出牌 2摸牌
function PlayCardView:cardActionAnim(byte,style,userId,animType)
	-- body
	if not userId  then
		return
	end

	local config;

	if animType == 1 then
		config = PlayCardView.aminConfig[userId].chuPai;
	else
		config = PlayCardView.aminConfig[userId].moPai;
	end

	local card  = CardView:create()
	card.cardTByte = byte;
	card.cardStyle = style;
	card:setScale(PlayCardView.config.cardScale.x,PlayCardView.config.cardScale.y);

	local moveAction = cc.MoveTo:create(config.time, cc.p(config.endPos.x, config.endPos.y))

	local callback = cc.CallFunc:create(handler(self,function ()
		--动画执行完毕发送event
		self:removeChild(card,true);

		if animType == 1 then
			self:getCtr():chuPaiResult(byte)
		else
			self:getCtr():moPai();
		end
	end))
	
	card:setPosition(config.startPos.x,config.startPos.y)

	self:addChild(card)
	card:runAction(cc.Sequence:create(moveAction,callback))

end



return  PlayCardView;