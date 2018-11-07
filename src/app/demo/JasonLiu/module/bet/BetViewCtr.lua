--[[--ldoc desc
@Module BetViewCtr.lua
@Author JasonLiu

Date: 2018-10-24 19:13:27
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 09:52:40
]]

local BetViewCtr = class("BetViewCtr", cc.load("boyaa").mvc.BoyaaCtr);
local BetView = require("app.demo.JasonLiu.module.bet.BetView")

function BetViewCtr:ctor()
    local chipData = {{value = "5K" , color = 1}, {value = "25K" , color = 2}, {value = "50K" , color = 3}, {value = "250K" , color = 4}}

    self:initView({chipData = chipData})

    self:startBet()
end

function BetViewCtr:initView(data)
	-- body
	local betView = BetView:create(data);
    betView:bindCtr(self);
end

function BetViewCtr:startBet()
    self:getView():setBetEnabled(true)
    self:getView():startCountdown(15, function ()
        self:getView():setBetEnabled(false)
        self:stopBet()
    end)
end

function BetViewCtr:stopBet()
    self:getView():updateWinningState({math.random(0, 21)})

    performWithDelay(self:getView(), function()  
        self:getView():updateWinningState()
        self:getView():clearSmallChip()
        self:getView():resetBetTipss()
        
        self:startBet()
    end, 5)  
end

return BetViewCtr;