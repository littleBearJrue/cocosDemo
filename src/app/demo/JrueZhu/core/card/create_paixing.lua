--[[--ldoc desc
@module create_paixing
@author SinChen

Date   2018-03-02 15:45:33
Last Modified by   RonanLuo
Last Modified time 2018-05-28 11:26:30
]]
--[[
使用方法：
在game.oa.com上下载，CardConfig.lua放到game层的config目录下,
然后ctrl+b
]]

package.path 	= package.path..';E:/paodekuai/trunk/server/GameServer/Resource/scripts/GameServer/bin/?.lua'..';'
g_BasePath 		= "game.base.";
g_CommonPath 	= "game.commmon.";
g_GamePath 		= "game.game.";
CardConfig 		= require(g_GamePath.."config.CardConfig")

local sortTemplate = require(g_BasePath.."core.card.sort.paidiandaxiao_template") 
local typeTemplate = require(g_BasePath.."core.card.type.paixing_template") 
-- string.gsub(typeTemplate, "\\", function(char) return "" end)	

local function createFile(fileName,typeName)
	local fd,err = io.open("./"..typeName.."/"..fileName)
	if err == nil then --文件存在则不创建
		io.close(fd)
		return
	end
	
	local fd = io.open("./"..typeName.."/"..fileName,"w+")
	io.output(fd)
	if typeName == "sort" then
		io.write(sortTemplate)
	elseif typeName == "type" then
		io.write(typeTemplate)
	end
	io.close(fd)
end 

-- createFile("paixing_1566_1"..".lua","type")

local function createAllCardFill( ... )
	local cardSortList = {}		--排序算法列表
	local cardTypeList = {}		--牌型算法列表

	for i,v in ipairs(CardConfig) do
		local sortId = v.sortRule[1].id
		local typeId = v.typeRule.id
		table.insert(cardSortList,sortId)
		table.insert(cardTypeList,typeId)
	end

	for i,fileName in ipairs(cardSortList) do
		createFile(fileName..".lua","sort")
	end

	for i,fileName in ipairs(cardTypeList) do
		createFile(fileName..".lua","type")
	end
end
createAllCardFill()