--[[--ldoc desc
@module HandCardView
@author ShuaiYang

Date   2018-10-24 09:46:24
Last Modified by   ShuaiYang
Last Modified time 2018-10-30 16:07:59
]]
local appPath = "app.demo.yangshuai"
local HandCardView = class("HandCardView",cc.load("boyaa").mvc.BoyaaLayout)
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
local CardView = require(appPath..".PlayCard.CardView")
local resRootPath = "Images/yangshuai/";

BehaviorExtend(HandCardView);

HandCardView.config = {
	cardScale = {x = 0.5, y = 0.5}, --缩放
	numSpacing = 10,--数字间隔
	isShowCard = true,--是否显示手牌
	rowSpacing = 15,--手牌间隔
	popupOffset = 10,--弹起高度
}

local function createNumImage(self,num)
	-- body
	print("createNumImage  :"..num)
	if checkint(num) then
		local numStr = tostring(num);
		local view = ccui.Layout:create();
  		view:setLayoutType(ccui.LayoutType.ABSOLUTE);
  		local xImage = ccui.ImageView:create(resRootPath.."num_positive/score_win_times.png")
		xImage:addTo(view);

		local lastX = HandCardView.config.numSpacing;
		for i = 1, string.len(numStr) do
			local num = string.sub(num, i, i);
  			local numImage = ccui.ImageView:create(resRootPath..string.format("num_positive/score_win_%s.png",num))
  			
  			local name = string.format("num_%d",i)
			numImage:setPosition(lastX,0);
			numImage:addTo(view);

			lastX = lastX + HandCardView.config.numSpacing;
						
		end

		return view;

	else
		error("必须是数字")
	end
	

end



function HandCardView:ctor()
  	print("HandCardView");
  	self:setLayoutType(ccui.LayoutType.RELATIVE);


  	self.cardAmountLayout = ccui.Layout:create();
  	self.cardAmountLayout:setLayoutType(ccui.LayoutType.RELATIVE);
  	-- self.cardAmountLayout:setSize(100,100);
  	local cardAmountParameter = ccui.RelativeLayoutParameter:create()
	cardAmountParameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	cardAmountParameter:setRelativeName("cardAmountLayout")
	cardAmountParameter:setMargin({ left = 8, top = 8})
	self.cardAmountLayout:setLayoutParameter(cardAmountParameter)
	-- self.cardAmountLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	-- self.cardAmountLayout:setBackGroundColor(cc.c3b(193, 193, 32))

	self.cardAmountLayout:addTo(self)

	self.chuBaiBtn = ccui.Button:create()
	self.chuBaiBtn:setTitleText("出牌")
	self.chuBaiBtn:addClickEventListener(function(sender)
        self:getCtr():chuPai()
    end)
   	local chuBaiParameter = ccui.RelativeLayoutParameter:create()
	chuBaiParameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	chuBaiParameter:setRelativeName("chuBaiBtn")
	chuBaiParameter:setMargin({ left = 8, bottom = 8})
	chuBaiParameter:setRelativeToWidgetName("cardAmountLayout")
	chuBaiParameter:setAlign(ccui.RelativeAlign.locationAboveLeftAlign)
	self.chuBaiBtn:setVisible(false)
	self.chuBaiBtn:setLayoutParameter(chuBaiParameter)
	self.chuBaiBtn:addTo(self)



	local view = createNumImage(self,0)
	view:addTo(self.cardAmountLayout)

	self.cardsLayout = ccui.Layout:create();
  	self.cardsLayout:setLayoutType(ccui.LayoutType.ABSOLUTE);
  	local cardsLayoutParameter = ccui.RelativeLayoutParameter:create()
	cardsLayoutParameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
	cardsLayoutParameter:setRelativeName("cardsLayout")
	cardsLayoutParameter:setRelativeToWidgetName("cardAmountLayout")
	cardsLayoutParameter:setAlign(ccui.RelativeAlign.locationBelowLeftAlign)
	cardsLayoutParameter:setMargin({top = 6 + HandCardView.config.popupOffset})
	self.cardsLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	self.cardsLayout:setBackGroundColor(cc.c3b(165, 71, 216))
	local size  = CardView:create():getContentSize()
	local w = size.width*HandCardView.config.cardScale.x;	
	local h = size.height*HandCardView.config.cardScale.y;	
	self.cardsLayout:setContentSize(cc.size(w,h))

	self.cardsLayout:setLayoutParameter(cardsLayoutParameter)
	self.cardsLayout:addTo(self)


	

end


local function addCardListener(self,cardView)
	-- body
	if cardView then
		print("addCardListener addCardListener.. ")

		cardView.isCardSelected = false;
		local object = self;
		local callback = function(self,event)
			print("sprite onTouchesEnded.. "..event)
			if event == 0 then 
	            --需要返回true
	            return true;
	        elseif event == 1 then 
	        elseif event == 2 then 
	        	local posx,posy = self:getPosition();
				if self.isCardSelected then
					self:setPosition(posx,posy-HandCardView.config.popupOffset);
					self.isCardSelected = false;
					object:getCtr():removeSelectedCard({byte = self.cardTByte , name = self:getName()})

				else
					self:setPosition(posx,posy+HandCardView.config.popupOffset);
					self.isCardSelected = true;
					object:getCtr():addSelectedCard({byte = self.cardTByte , name = self:getName()})

				end
	        end
		end
		cardView:setTouchEnabled(true)
		cardView:addTouchEventListener(callback)
	end

end


local function updataCards(self,cardDatas,isAmin)
	-- body
	local sortCards = self:sortCards(cardDatas);

	self.cardsLayout:removeAllChildren();
	local cardStyle = "";
	if  self.isShowCard then
		cardStyle = 0;
	else
		cardStyle = 1;
	end
	
	local cardOffsetX = 0;
	local cardOffsetY = 0;
	local cardW = 0;
	local cardH = 0;
	local index = 1;
	if isAmin then
		self.shl = self:scheduler(handler(self,function (self)
			-- body
			if index > #sortCards then
				self:unScheduler(self.shl);
			else
				local v = sortCards[index]
				local card  = CardView:create()
				card.cardTByte = v.byte;
				card.cardStyle = cardStyle;
				card:setScale(HandCardView.config.cardScale.x,HandCardView.config.cardScale.y);

				self.cardsLayout:addChild(card,1,v.name);

				if self.isShowCard then
					addCardListener(self,card)
				end


				card:setPosition(cardOffsetX,cardOffsetY);


				cardOffsetX = cardOffsetX + HandCardView.config.rowSpacing;
				local size = card:getContentSize();
				cardW = size.width; 
				cardH = size.height; 

				local w = (cardW+cardOffsetX)*HandCardView.config.cardScale.x;
				local h = (cardH+cardOffsetY)*HandCardView.config.cardScale.y;
				-- print(string.format("cardW :%d,==== cardH :%d,==== cardOffsetX :%d,==== cardOffsetY :%d",cardW,cardH,cardOffsetX,cardOffsetY));
				-- print(string.format("cardW+cardOffsetX :%d,==== cardH+cardOffsetY :%d,",cardW+cardOffsetX,cardH+cardOffsetY));

				self.cardsLayout:setContentSize(cc.size(w,h))
				index = index +1;
			end
			
		end),0.5,false)
	else

		for i,v in ipairs(sortCards) do
			local card  = CardView:create()
			card.cardTByte = v.byte;
			card.cardStyle = cardStyle;
			card:setScale(HandCardView.config.cardScale.x,HandCardView.config.cardScale.y);
			
			addCardListener(self,card)

			self.cardsLayout:addChild(card,1,v.name);
			card:setPosition(cardOffsetX,cardOffsetY);


			cardOffsetX = cardOffsetX + HandCardView.config.rowSpacing;
			local size = card:getContentSize();
			cardW = size.width; 
			cardH = size.height; 

			local w = (cardW+cardOffsetX)*HandCardView.config.cardScale.x;
			local h = (cardH+cardOffsetY)*HandCardView.config.cardScale.y;
			-- print(string.format("cardW :%d,==== cardH :%d,==== cardOffsetX :%d,==== cardOffsetY :%d",cardW,cardH,cardOffsetX,cardOffsetY));
			-- print(string.format("cardW+cardOffsetX :%d,==== cardH+cardOffsetY :%d,",cardW+cardOffsetX,cardH+cardOffsetY));

			self.cardsLayout:setContentSize(cc.size(w,h))
		end


	end
	

end


function HandCardView:isShowCard(isShow)
	-- body
	self.isShowCard = isShow;
end

function HandCardView:addCards(bytes)
	-- body
	local cardDatas = {}
	local newCardDatas = {}
	for i,byte in ipairs(bytes) do
		local key = tostring(byte);	

		local data = {
			byte = byte,
			name = key,
		}
		table.insert(newCardDatas,data);
	end

	table.merge(cardDatas,newCardDatas);

	local cards = self.cardsLayout:getChildren();

	if cards then
		for k,v in pairs(cards) do
			local data = {
				byte = v.cardTByte,
				name = v:getName(),
			}
			table.insert(cardDatas,data);
		end
	end
	

	updataCards(self,cardDatas,true);

	-- print("------------------------",#cardDatas)
	self.cardAmountLayout:removeAllChildren();
	local view = createNumImage(self,#cardDatas)
	view:addTo(self.cardAmountLayout)
	return newCardDatas;
end



function HandCardView:addCard(_byte)
	-- body

	
	local _key = tostring(_byte);	

	local cards = self.cardsLayout:getChildren();
	local cardDatas = {}

	if cards then
		for k,v in pairs(cards) do
			local data = {
				byte = v.cardTByte,
				name = v:getName(),
			}
			table.insert(cardDatas,data);
		end
	end
	local data = {
		byte = _byte,
		name = _key,
	}
	table.insert(cardDatas,data);

	updataCards(self,cardDatas);

	self.cardAmountLayout:removeAllChildren();
	local view = createNumImage(self,#cardDatas)
	view:addTo(self.cardAmountLayout)

	return {key=_key,byte=_byte};
end


function HandCardView:removeCard(data)
	-- body
	local cards = self.cardsLayout:getChildren();
	local cardDatas = {}

	if cards then
		local isCard = true;
		for k,v in pairs(cards) do
			if v.cardTByte == data.byte then
				if not isCard then
					local setData = {
						byte = v.cardTByte,
						name = v:getName(),
					}
					table.insert(cardDatas,setData);
				else
					isCard = false;
				end
			else
				local setData = {
					byte = v.cardTByte,
					name = v:getName(),
				}
				table.insert(cardDatas,setData);
			end
		end
	end

	updataCards(self,cardDatas);

	self.cardAmountLayout:removeAllChildren();
	local view = createNumImage(self,#cardDatas)
	view:addTo(self.cardAmountLayout)
end


function HandCardView:sortCards(cards)
	-- body
	return cards;
end



return HandCardView;