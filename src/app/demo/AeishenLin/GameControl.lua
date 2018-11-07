--[[--ldoc desc
@Module GameControl.lua
@Author AeishenLin

Date: 2018-10-18 18:29:31
Last Modified by: AeishenLin
Last Modified time: 2018-10-18 18:29:38
]]
local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local visibleSize = director:getVisibleSize()
local numMoneyGet = 0



local GameControl = {
    setDuration = {},
    totalDt = 0,
    enemies = {},
    money = {},
    scoreLabel = cc.LabelBMFont:create("Score: "..0, "fonts/futura-48.fnt"),

    onEnter = function(self)
        director:setDisplayStats(false);
        self.scoreLabel:setTag(2);
        self.scoreLabel:setPosition(cc.p(origin.x + 50, origin.y + visibleSize.height - 10))
        self:getOwner():addChild(self.scoreLabel) 
    end,

    update = function(self, dt)
        local durationTime = self.setDuration[1] or 2;
        self.totalDt = self.totalDt + dt
        if self.totalDt > durationTime then
            self:addNewEnemy();
            self.totalDt = 0
        end
    end,
    
    addNewEnemy = function(self)
        local moneyOrEnemy = nil;

        math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
        local falg = math.random(1,6)
        
        if falg <= 2 then 
            moneyOrEnemy = cc.Sprite:create("Images/SpinningPeas.png")
            moneyOrEnemy:setScale(1.6 * falg, 1.6 * falg)
        else
            moneyOrEnemy = cc.Sprite:create("Images/Pea.png")
            moneyOrEnemy:setScale(falg / 4, falg / 4)
        end
        
        local moneyComponent = cc.ComponentLua:create("app/demo/AeishenLin/NodeScript/money.lua")   
        moneyComponent:setName("moneyComponent");         
        moneyOrEnemy:addComponent(moneyComponent)  
        local layer = self:getOwner();
        layer:addChild(moneyOrEnemy)

        if falg <= 2 then 
            table.insert(self.enemies, moneyOrEnemy)
        else
            table.insert(self.money, moneyOrEnemy)
        end
    end,


    addScore = function(self)
        numMoneyGet = numMoneyGet + 10;
        self.scoreLabel:setString("Score: "..numMoneyGet)
        if numMoneyGet >= 10 and numMoneyGet < 100 then 
            table.insert(self.setDuration,1,1.5)
        elseif numMoneyGet >= 100 and numMoneyGet < 200 then  
            table.remove(self.setDuration, 1)
            table.insert(self.setDuration,1,1)
        end
    end,

    looseGame = function(self)
        local myEvent = cc.EventCustom:new("game over")
        print(numMoneyGet)
        myEvent.result = numMoneyGet
        director:getEventDispatcher():dispatchEvent(myEvent)
    end,

    winGame = function(self)  
    end,
}

return GameControl