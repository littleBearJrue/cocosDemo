-- local DeskView = class("DeskView", function()
-- 	bg = ccui.ImageView:create("DowneyTang/koprokdice/bet/koprok_dice_bet.png")
-- 	return bg 
-- end)
local DeskView = class("DeskView",cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;
BehaviorExtend(DeskView);

function DeskView:addTouchSpace(spaceMap)

end

function DeskView:init()
	local bg = ccui.ImageView:create("DowneyTang/koprokdice/bet/koprok_dice_bet.png")
	bg:addTo(self)  
	--牌桌下方的提示文字
	local deskTips = ccui.Text:create("hello", "Arial", 40)
    deskTips:setString("  單骰=1:1   雙骰=1:2   全骰=1:3   組合押注=1:5")                    
    deskTips:setTextColor(cc.c3b(128, 0, 128))     
    deskTips:setPosition(240, 33)            
	deskTips:setFontSize(20) 
	deskTips:addTo(bg)                              
end

function DeskView:ctor()
   self:init()
end

return DeskView;