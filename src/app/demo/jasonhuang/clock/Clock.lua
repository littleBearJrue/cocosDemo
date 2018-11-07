local Clock = class("Clock",function()
	return cc.Node:create()
end)

function Clock:ctor(data)
    self.m_time = data and data.time
    self.m_time = 15
    self:initView()
    -- self:countDown()
end

function Clock:initView()
    self.m_bg = display.newSprite("Images/clock/clock_default.png")
    self.m_bg:setPosition(display.cx,display.cy)
    self:addChild(self.m_bg)

    local contentSize = self.m_bg:getContentSize()
    self.m_timeTxt = cc.LabelTTF:create("", "Arial", 20)
    self.m_timeTxt:setColor(cc.c3b(255, 220, 94))
    self.m_timeTxt:setPosition(cc.p(contentSize.width/2,contentSize.height/2))
    self.m_bg:addChild(self.m_timeTxt)
end

function Clock:countDown()
    local cc = self.m_time
    schedule(self.m_timeTxt,function()
        cc = cc - 1
        self.m_timeTxt:setString(cc)
    end,1)
end

return Clock