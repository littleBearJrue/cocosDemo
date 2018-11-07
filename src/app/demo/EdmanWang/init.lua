-- @Author: EdmanWang
-- @Date:   2018-10-16 17:11:41
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-29 18:09:10
local _M = {}

_M.showList = {
    "XXY_NEW",
    -- "Sprite_Test",
    -- "Anchor_Test",
    -- -- "BMFont_Test",
    -- -- "TTF_Test",
    -- "Label_Test",
    -- "Button_Test",
    -- "CheckBox_Test",
    -- "Card_Test",
    -- "Node_Test",
    -- "Meun_Test",
    -- "YXX_Test",
    -- -- "chipTest",
    -- -- "YuXiaXie_Util",
    -- "chip",
}

--测试精灵
-- _M.Sprite_Test = import(".Sprite_Test")
-- --测试锚点
-- _M.Anchor_Test = import(".Anchor_Test")
-- --  在cocos-lua中label 创建的两种方式（1：TTF 2:BMFont）下面做介绍
-- _M.Label_Test = import(".Label_Test")
-- -- _M.TTF_Test = import(".TTF_Test")
-- -- _M.BMFont_Test = import(".BMFont_Test")
-- --测试Button
-- _M.Button_Test = import(".Button_Test")
-- --测试CheckBox
-- _M.CheckBox_Test = import(".CheckBox_Test")
-- -- 单张牌
-- _M.Card_Test = import(".Card_Test")
-- -- 简单节点的创建
-- _M.Node_Test = import(".Node_Test")
-- --菜单测试，加入菜单项的点击事件
-- _M.Meun_Test = import(".Meun_Test")
-- -- 鱼虾蟹测试
-- _M.YXX_Test = require("app.demo.EdmanWang.yuxiaxie.YXX_Test")

-- -- _M.chipTest = import("app.EdmanWang.yuxiaxie.chip.chipTest")

-- _M.chip = require("app.demo.EdmanWang.XXY.chip.chipTest")

-- _M.YuXiaXie_Util = import("app.EdmanWang.yuxiaxie.YuXiaXie_Util")
_M.XXY_NEW = require("app.demo.EdmanWang.XXY.YXX_Test")
return _M