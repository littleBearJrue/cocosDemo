local SszCardConfig = {}

--触摸区域配置
--参数1【scaleX:区域划分图片的X轴缩放】
--参数2【scaleY:区域划分图片的Y轴缩放】
--参数3【position:区域划分图片位置摆放】
--参数4【startPos:小筹码筹码运动起始位置】
--参数5【endPos:小筹码筹码运动终点位置划分，前两个参数是x轴范围，后两个参数是y轴范围】
function SszCardConfig:getSpaceMap()
    local spaceMap = {
        --【第1组牌坐标】
        {cc.p(240, 803), cc.p(325, 803), cc.p(410, 803)},
        
        --【第2组牌坐标】
        {cc.p(240, 668), cc.p(325, 668), cc.p(410, 668), cc.p(495, 668), cc.p(580, 668)},
         
        --【第3组牌坐标】
        {cc.p(240, 533), cc.p(325, 533), cc.p(410, 533), cc.p(495, 533), cc.p(580, 533)},

        -- --【第1组牌坐标】
        -- {cc.p(200, 749), cc.p(285, 749), cc.p(370, 749)},
        
        -- --【第2组牌坐标】
        -- {cc.p(200, 614), cc.p(285, 614), cc.p(370, 614), cc.p(455, 614), cc.p(540, 614)},
         
        -- --【第3组牌坐标】
        -- {cc.p(200, 480), cc.p(285, 480), cc.p(370, 480), cc.p(455, 480), cc.p(540, 480)},



    }
    return spaceMap
end

return SszCardConfig