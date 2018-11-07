--[[--ldoc desc
@Module Table.lua
@Author JasonLiu

Date: 2018-10-23 19:20:56
Last Modified by: JasonLiu
Last Modified time: 2018-10-25 14:33:06
]]

local Table = class("Table", cc.load("boyaa").mvc.BoyaaView);
local BehaviorExtend = cc.load("boyaa").behavior.BehaviorExtend;

BehaviorExtend(Table);

local margin = {
    top = 4, left = 4, right = 4, buttom = 4
}

local areaSize = {
    [1] = {
        w = 64.5, h = 45.5
    },    
    [2] = {
        w = 43, h = 41
    },  
    [3] = {
        w = 14, h = 31
    },
    [4] = {
        w = 39, h = 14
    },
    [5] = {
        w = 18, h = 18
    },
}

--获取行和列
local function getRowAndCol(v , m)
    local row = math.modf( v / m )
    local col = math.fmod( v , m )
    if col == 0 then
        col = m
        row = row - 1
    end

    return row, col - 1
end

--平面两点间的距离
local function twoPointToDistance(x1, y1, x2, y2)
    return math.sqrt(math.pow((y2 - y1), 2) + math.pow((x2 - x1), 2))
end

function Table:ctor()
    self:initView()
end

--[[
    @function initView      初始化View
]] 
function Table:initView()
    self:addTableBg()
    self:addTableAreas()
end

--[[
    @function addTableBg      添加桌子背景
]] 
function Table:addTableBg()
    self.bg = cc.Sprite:create("Images/koprokdice/bet/koprok_dice_bet.png"):setContentSize(cc.size(136.5, 234.5))
    self:addChild(self.bg)
end

 --[[
     @function addTableAreas      添加桌子下注区域
 ]] 
 function Table:addTableAreas()
    -- 添加下注区域，调整区域大小和位置
    self.areas = {}
    for i = 1, 21 do
        self.areas[i] = ccui.ImageView:create("Images/koprokdice/bet/koprok_dice_bet_hight_light2.png"):setOpacity(0)
        self.areas[i]:setAnchorPoint(cc.p(0, 1.0))
            :setScale9Enabled(true)
            :setTouchEnabled(true)
        self.areas[i]:addTouchEventListener(function(sender, eventType)
                if eventType == 2 and self.clickListener then
                    if i == 20 or i == 21 then
                        local p = self.areas[i]:convertToNodeSpace(self.areas[i]:getTouchBeganPosition())
                        if (i == 20 and twoPointToDistance(p.x, p.y, 0, self.areas[i]:getContentSize().height) < self.areas[i]:getContentSize().height) or 
                                    (i == 21 and twoPointToDistance(p.x, p.y, self.areas[i]:getContentSize().width, self.areas[i]:getContentSize().height) < self.areas[i]:getContentSize().height) then
                            self.clickListener(i)
                        else
                            self.clickListener(i == 20 and 1 or 2)
                        end
                    else
                        self.clickListener(i)
                    end
                end
            end)
        local startPosX = - self.bg:getContentSize().width / 2 + margin.top
        local startPosY = self.bg:getContentSize().height / 2 - margin.top
        if i < 7 then
            self.areas[i]:setContentSize(cc.size(areaSize[1].w, areaSize[1].h))
            local row,col = getRowAndCol(i, 2)
            self.areas[i]:move(startPosX + self.areas[1]:getContentSize().width * col, startPosY - self.areas[1]:getContentSize().height * row)
        elseif i < 13 then
            self.areas[i]:setContentSize(cc.size(areaSize[2].w, areaSize[2].h))
            local row,col = getRowAndCol(i - 6, 3)
            startPosY = startPosY - self.areas[1]:getContentSize().height * 3
            self.areas[i]:move(startPosX + self.areas[7]:getContentSize().width * col, startPosY - self.areas[7]:getContentSize().height * row)
        elseif i < 16 then
            self.areas[i]:setContentSize(cc.size(areaSize[3].w, areaSize[3].h))
            startPosX = startPosX + self.areas[1]:getContentSize().width - areaSize[3].w / 2
            startPosY = startPosY - (self.areas[1]:getContentSize().height  - areaSize[3].h) / 2
            self.areas[i]:move(startPosX, startPosY - self.areas[1]:getContentSize().height * (i - 13))
        elseif i < 20 then
            self.areas[i]:setContentSize(cc.size(areaSize[4].w, areaSize[4].h))
            local row,col = getRowAndCol(i - 15, 2)
            startPosX = startPosX + (self.areas[1]:getContentSize().width - areaSize[4].w) / 2
            startPosY = startPosY - self.areas[1]:getContentSize().height  + (areaSize[4].h / 2)
            self.areas[i]:move(startPosX + col * self.areas[1]:getContentSize().width, startPosY - row * self.areas[1]:getContentSize().height)
        elseif i < 22 then
            self.areas[i]:setContentSize(cc.size(areaSize[5].w, areaSize[5].h))
            local row,col = getRowAndCol(i - 19, 2)
            self.areas[i]:move(startPosX + col * (self.areas[1]:getContentSize().width * 2 - areaSize[5].w), startPosY)
        end

        self:addChild(self.areas[i])
    end
 end

--[[
    @function getRandomAreaPos      获取区域内的筹码随机位置
    @param #areaNo int              区域编号
    @param #offSize int             偏移值
]] 
function Table:getRandomAreaPos(areaNo, offSize)
    offSize = offSize or 0
    local x, y
    if areaNo == 1 then
        x = math.random(0 + offSize, areaSize[1].w - areaSize[3].w / 2 - offSize)
        if x < areaSize[5].w then
            y = math.random(areaSize[5].h + offSize, areaSize[1].h - areaSize[4].h / 2 - offSize)
        else
            y = math.random(0 + offSize, areaSize[1].h - areaSize[4].h / 2 - offSize)
        end
    elseif areaNo == 2 then
        x = math.random(areaSize[3].w / 2 + offSize, areaSize[1].w - offSize)
        if x > (areaSize[1].w - areaSize[5].w) then
            y = math.random(areaSize[5].h + offSize, areaSize[1].h - areaSize[4].h / 2 - offSize)
        else
            y = math.random(0 + offSize, areaSize[1].h - areaSize[4].h / 2 - offSize)
        end
    elseif areaNo == 3 then
        x = math.random(0 + offSize, areaSize[1].w - areaSize[3].w / 2 - offSize)
        y = math.random(areaSize[4].h / 2 + offSize, areaSize[1].h - areaSize[4].h / 2 - offSize)
    elseif areaNo == 4 then
        x = math.random(areaSize[3].w / 2 + offSize, areaSize[1].w - offSize)
        y = math.random(areaSize[4].h / 2 + offSize, areaSize[1].h - areaSize[4].h / 2 - offSize)
    elseif areaNo == 5 then
        x = math.random(0 + offSize, areaSize[1].w - areaSize[3].w / 2 - offSize)
        y = math.random(areaSize[4].h / 2 + offSize, areaSize[1].h - offSize)
    elseif areaNo == 6 then
        x = math.random(areaSize[3].w / 2 + offSize, areaSize[1].w - offSize)
        y = math.random(areaSize[4].h / 2 + offSize, areaSize[1].h - offSize)
    elseif areaNo == 20 then
        x = math.random(0 + offSize, areaSize[5].w - offSize)
        y = math.random(0 + offSize, areaSize[5].h - x)
    elseif areaNo == 21 then
        x = math.random(0 + offSize, areaSize[5].w - offSize)
        y = math.random(0 + offSize, x)
    else
        x, y = math.random(0 + offSize, self.areas[areaNo]:getContentSize().width - offSize), math.random(0 + offSize, self.areas[areaNo]:getContentSize().height - offSize)
    end

    return x, y
end

--[[
    @function addClickListener      添加点击事件
    @param #callback function       回调方法
]] 
function Table:addClickListener(callback)
    self.clickListener = callback
end

--[[
    @function getContentSize   获取内容大小
    @return size_table#size_table ret (return value: size_table)
]] 
function Table:getContentSize()
    return self.bg:getContentSize()
end

--[[
    @function getAreaMoveTime   获取对应区域筹码移动时间
    @param #areaNo int          区域编号
    @return #time float 
]] 
function Table:getAreaMoveTime(areaNo)
    local time = 0.1
    if areaNo == 1 or areaNo == 2 or areaNo == 13 or areaNo == 20 or areaNo == 21 or areaNo == 16 or areaNo == 17 then
        time = time * 5
    elseif areaNo == 3 or areaNo == 4 or areaNo == 14 or areaNo == 18 or areaNo == 19 then
        time = time * 4
    elseif areaNo == 5 or areaNo == 6 or areaNo == 15 then
        time = time * 3
    elseif areaNo == 7 or areaNo == 8 or areaNo == 9 then
        time = time * 2
    elseif areaNo == 10 or areaNo == 11 or areaNo == 12 then
        time = time
    end

    return time + 0.1
end

--[[
    @function updateTableWinningArea   更新桌子中奖区域
    @param #data table          中奖数据
]] 
function Table:updateTableWinningArea(data)
    for i, v in ipairs(self.areas) do
        if data and table.keyof(data, i) then
            v:setOpacity(255)
        else
            v:setOpacity(0)
        end
    end
end

return Table