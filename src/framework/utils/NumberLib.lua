--[[
	number格式化
]]

local NumberLib = {}
--判断参数是非数字（not a number）
function NumberLib.isNum(_n)
	return tonumber(_n) and true or false;
end

--转换成数字，若无法转换成数字，返回默认值，没给定默认值则返回0
function NumberLib.valueOf(_s, _d)
	return tonumber(_s) or (_d or 0);
end

-- 获取随机数
function NumberLib.getRandom(round)
	return math.random(round);
end

--转换成0x0000格式的十六进制数
function NumberLib.formatToHex(num)
	num = NumberLib.valueOf(num);
	return string.format("0x%04X",num);
end

return NumberLib;