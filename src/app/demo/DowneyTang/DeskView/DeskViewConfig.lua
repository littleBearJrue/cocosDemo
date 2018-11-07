local DeskViewConfig = {}

--触摸区域配置
--参数1【scaleX:区域划分图片的X轴缩放】
--参数2【scaleY:区域划分图片的Y轴缩放】
--参数3【position:区域划分图片位置摆放】
--参数4【startPos:小筹码筹码运动起始位置】
--参数5【endPos:小筹码筹码运动终点位置划分，前两个参数是x轴范围，后两个参数是y轴范围】
function DeskViewConfig:getSpaceMap()
    local spaceMap = {
        --牌桌上方6个大区域
        { scaleX = 2.62, scaleY = 1.86, position = cc.p(-130, 360), startPos = cc.p(0, -1000), endPos = {-70, -190, 340, 380} },
        { scaleX = 2.62, scaleY = 1.86, position = cc.p(130, 360), startPos = cc.p(0, -1000), endPos = {70, 190, 340, 380} },
        { scaleX = 2.62, scaleY = 1.86, position = cc.p(-130, 180), startPos = cc.p(0, -1000), endPos = {-70, -190, 160, 200} },
        { scaleX = 2.62, scaleY = 1.86, position = cc.p(130, 180), startPos = cc.p(0, -1000), endPos = {70, 190, 160, 200} },
        { scaleX = 2.62, scaleY = 1.86, position = cc.p(-130, 0), startPos = cc.p(0, -1000), endPos = {-70, -190, -20, 20} },
        { scaleX = 2.62, scaleY = 1.86, position = cc.p(130, 0), startPos = cc.p(0, -1000), endPos = {70, 190, -20, 20} },
        --牌桌下方6个小区域
        { scaleX = 1.78, scaleY = 1.66, position = cc.p(-175, -175), startPos = cc.p(0, -1000), endPos = {-125, -225, -125, -225} },
        { scaleX = 1.78, scaleY = 1.66, position = cc.p(0, -175), startPos = cc.p(0, -1000), endPos = {-50, 50, -125, -225} },
        { scaleX = 1.78, scaleY = 1.66, position = cc.p(175, -175), startPos = cc.p(0, -1000), endPos = {125, 225, -125, -225} },
        { scaleX = 1.78, scaleY = 1.66, position = cc.p(-175, -340), startPos = cc.p(0, -1000), endPos = {-125, -225, -390, -290} },
        { scaleX = 1.78, scaleY = 1.66, position = cc.p(0, -340), startPos = cc.p(0, -1000), endPos = {-50, 50, -390, -290} },
        { scaleX = 1.78, scaleY = 1.66, position = cc.p(175, -340), startPos = cc.p(0, -1000), endPos = {125, 225, -390, -290} },
        --牌桌左上角、右上角的小区域
        { scaleX = 0.56, scaleY = 0.56, position = cc.p(-230, 425), startPos = cc.p(0, -1000), endPos = {-232, -228, 420, 430} },
        { scaleX = 0.56, scaleY = 0.56, position = cc.p(230, 425), startPos = cc.p(0, -1000), endPos = {228, 232, 420, 430} },
        -- --牌桌6个大区域的7个重叠小区域
        { scaleX = 1.58, scaleY = 0.52, position = cc.p(-130, 270), startPos = cc.p(0, -1000), endPos = {-160, -100, 267, 273} },
        { scaleX = 1.58, scaleY = 0.52, position = cc.p(130, 270), startPos = cc.p(0, -1000), endPos = {100, 160, 267, 273} },
        { scaleX = 1.58, scaleY = 0.52, position = cc.p(-130, 90), startPos = cc.p(0, -1000), endPos = {-160, -100, 87, 93} },
        { scaleX = 1.58, scaleY = 0.52, position = cc.p(130, 90), startPos = cc.p(0, -1000), endPos = {100, 160, 87, 93} },

        { scaleX = 0.52, scaleY = 1.18, position = cc.p(0, 0), startPos = cc.p(0, -1000), endPos = {-4, 4, -20, 20} },
        { scaleX = 0.52, scaleY = 1.18, position = cc.p(0, 180), startPos = cc.p(0, -1000), endPos = {-4, 4, 160, 200} },
        { scaleX = 0.52, scaleY = 1.18, position = cc.p(0, 360), startPos = cc.p(0, -1000), endPos = {-4, 4, 340, 380} },
    }
    return spaceMap
end

return DeskViewConfig