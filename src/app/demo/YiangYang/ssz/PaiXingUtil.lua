-- @Author: YiangYang
-- @Date:   2018-11-01 16:16:46
-- @Last Modified by:   YiangYang
-- @Last Modified time: 2018-11-02 15:54:23

local PaiXingUtil = {}

PaiXingUtil.Config = {
	{fun = "paiXingTHS",	name = "同花顺",	sortID = 10}	,
	{fun = "paiXingSiTiao",	name = "四条",	sortID = 9},	
	{fun = "paiXingHL",		name = "葫芦",	sortID = 8},	
	{fun = "paiXingTH",		name = "同花",	sortID = 7},	
	{fun = "paiXingSZ",		name = "顺子",	sortID = 6},	
	{fun = "paiXingSanTiao",name = "三条",	sortID = 5},	
	{fun = "paiXingLD",		name = "两对",	sortID = 4},	
	{fun = "paiXingDZ",		name = "对子",	sortID = 3},	
	{fun = "paiXingGP",		name = "高牌",	sortID = 2},	

}



--高牌，对子，两对，三条，顺子，同花，葫芦，四条，同花顺
local function sort( data )
	table.sort( data, function (a,b) --从小到大
		if a >= b then
			return false
		else
			return true
		end
	end )
end

--解析数据
-- 返回排序后 牌值跟花色 两个表
local function analysisData(cardBytes)
	local values = {}
	local types = {}
	for i,v in ipairs(cardBytes) do
		local cardType = tonumber(math.floor(v/16))
		local cardValue = v%16
		table.insert(types,cardType)
		table.insert(values,cardValue)
	end
	-- dump(values, "values == ")
	-- dump(types, "types == ")
	sort(types)
	sort(values)

	return values,types
end

--高牌
function PaiXingUtil.paiXingGP(cardBytes)
	local values, types = analysisData(cardBytes)
	
	--将A移到最后
	local num = 0
	for i = #values,1,-1 do
		if values[i] == 1 then
			num = num + 1
			table.remove(values,i)
		end
	end
	if num >0 then
		for i=1,num do
			table.insert(values,1)
		end
	end
	--将A移到最后


	local value = values[#values]
	local tem = {}
	for i,v in ipairs(cardBytes) do
		if value == v%16 then
			table.insert(tem,v)
		end
	end
	return true,tem
end

--对子
function PaiXingUtil.paiXingDZ(cardBytes)
	local values, types = analysisData(cardBytes)
	local commTB = {}
	for i=1,#values-1 do
		if values[i] == values[i+1] then	--牌值相等
			table.insert(commTB,values[i])
		end
	end

	if #commTB == 1 then
		local tem = {}
		for i,v in ipairs(cardBytes) do
			if commTB[1] == v%16 then
				table.insert(tem,v)
			end
		end
		return true,tem
	end

	return false
end


--两对
function PaiXingUtil.paiXingLD(cardBytes)
	local values, types = analysisData(cardBytes)
	local commTB = {}
	for i=1,#values-1 do
		if values[i] == values[i+1] then	--牌值相等
			table.insert(commTB,values[i])
		end
	end

	if #commTB == 2 then
		local tem = {}
		for i,v in ipairs(cardBytes) do
			if commTB[1] == v%16 or commTB[2] == v%16 then
				table.insert(tem,v)
			end
		end
		return true,tem
	end
	return false
end


--三条
function PaiXingUtil.paiXingSanTiao(cardBytes)
	local values, types = analysisData(cardBytes)
	local nums = 2
	local value
	for i=2,#values-1 do
		if values[i-1] == values[i] and values[i] == values[i+1] then	--牌值相等
			nums = nums + 1
			value = values[i]
		end
	end
	--三条
	if nums == 3 then
		local tem = {}
		for i,v in ipairs(cardBytes) do
			if value == v%16 then
				table.insert(tem,v)
			end
		end
		return true,tem
	else
		return false
	end
end


--顺子
function PaiXingUtil.paiXingSZ(cardBytes)
	local values, types = analysisData(cardBytes)
	for i=1,#values-1 do
		if values[i]+1 ~= values[i+1] then	--牌值是否相同
			return false
		end
	end
	return true,cardBytes
end


--同花
function PaiXingUtil.paiXingTH(cardBytes)
	local values, types = analysisData(cardBytes)
	for i=1,#types-1 do
		if types[i] ~= types[i+1] then	--花色是否相同
			return false
		end
	end
	return true,cardBytes
end

--葫芦
function PaiXingUtil.paiXingHL(cardBytes)
	local values, types = analysisData(cardBytes)
	local nums = 2
	local value
	for i=1,#values-2 do
		if values[i] == values[i+1] and values[i] == values[i+2] then	--牌值相等
			nums = nums + 1
			value = values[i]
		end
	end
	if nums == 3 then	--有三条
		local tem = {}
		for i,v in ipairs(values) do
			if value~=v then
				table.insert(tem,v)
			end
		end
		if tem[1] == tem[2] then --剩余两张是否对子
			return true,cardBytes
		end
	end

	return false

end

--四条
function PaiXingUtil.paiXingSiTiao(cardBytes)
	local values, types = analysisData(cardBytes)
	local nums = 2
	local value
	for i=2,#values-1 do
		if values[i-1] == values[i] and values[i] == values[i+1] then	--牌值相等
			nums = nums + 1
			value = values[i]
		end
	end
	--四条
	if nums == 4 then
		local tem = {}
		for i,v in ipairs(cardBytes) do
			if value == v%16 then
				table.insert(tem,v)
			end
		end
		return true,tem
	else
		return false
	end
end

--同花顺
function PaiXingUtil.paiXingTHS(cardBytes)
	local values, types = analysisData(cardBytes)
	for i=1,#types-1 do
		if types[i] ~= types[i+1] then	--花色是否相同
			return false
		end
	end

	for i=1,#values-1 do
		if values[i]+1 ~= values[i+1] then	--牌值是否相同
			return false
		end
	end

	return true,cardBytes
end


--遍历判断获取类型
--return
--typeData 	类型需要点亮的数据
--name 		类型名称
--sortID  	用于比较大小
function PaiXingUtil.getPaiXingData(cardBytes)
	for i,v in ipairs(PaiXingUtil.Config) do
	 	local isTrue,data =  PaiXingUtil[v.fun](cardBytes)
	 	if isTrue then
	 		return {typeData = data,name = v.name,sortID = v.sortID}
	 	end
	end
end

--获取判断排序后的牌型数据
function PaiXingUtil.getSortThreePaiXingData(data)
	local pxData = {}
	for i,v in ipairs(data) do
		table.insert(pxData,PaiXingUtil.getPaiXingData(v))
	end
	
	if pxData[1].sortID < pxData[2].sortID then
		pxData[1].state = true
	end

	if pxData[3].sortID > pxData[2].sortID then
		pxData[3].state = true
	end

	if pxData[3].sortID > pxData[2].sortID and pxData[1].sortID < pxData[2].sortID then
		pxData[2].state = true
	end

	return pxData
end

--[[
	牌型数据结构
	{
	    1 = {
	        "name"     = "高牌"
	        "sortID"   = 2
	        "typeData" = {
	            1 = 37
	        }
	    }
	    2 = {
	        "name"     = "高牌"
	        "sortID"   = 2
	        "typeData" = {
	            1 = 29
	        }
	    }
	    3 = {
	        "name"     = "四条"
	        "sortID"   = 9
	        "state"    = true
	        "typeData" = {
	            1 = 57
	            2 = 25
	            3 = 41
	            4 = 73
	        }
	    }
	}
]]

return PaiXingUtil