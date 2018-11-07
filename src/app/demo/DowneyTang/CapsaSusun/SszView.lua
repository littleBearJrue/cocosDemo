local SszView = class("SszView",cc.load("boyaa").mvc.BoyaaView);
local CardView = require("app.demo.SilvaZhang.card.CardView")
local ClockWidget = require("app.demo.DowneyTang.CapsaSusun.ClockWidget")
local SszCardConfig = require("app.demo.DowneyTang.CapsaSusun.SszCardConfig")

local spaceMap = SszCardConfig:getSpaceMap()
local byteMap, bg
--*******************【加载单牌部件】
local function createCards()
	for i = 1, #byteMap do
		for j = 1, #byteMap[i] do
			local newCardView = CardView.new({cardByte = byteMap[i][j]})
			bg:addChild(newCardView)		
			newCardView:setPosition(spaceMap[i][j])
			newCardView:setScale(0.4)
			newCardView:setTag(i*10+j)
			newCardView:setAnchorPoint(cc.p(0.5,0.5))
		end
	end		
end

-- function SszView:getByteMap()
-- 	return self.byteMap
-- end

--*******************【加载时钟部件】
local function createClock()
	local  newClockWidget = ClockWidget.create()
	newClockWidget:setListener(function ()
		print("倒计时结束")
		-- self:getCtr():getByteMap(byteMap)
	end)
	newClockWidget:setPosition(340, 1000)
	bg:addChild(newClockWidget)	
end

--*******************【第2、3行交换牌】
function SszView:changeRowCards()
	local changeBtn = bg:getChildByName("change_btn")
	changeBtn:addClickEventListener(function()
		local newByte = {
			{},{},{},
		}
		for i = 1, #byteMap[2] do
			newByte[2][i] = byteMap[3][i]
		end
		for i = 1, #byteMap[3] do
			newByte[3][i] = byteMap[2][i]
		end
		for i = 2, #byteMap do
			for j = 1, #byteMap[i] do
				byteMap[i][j] = newByte[i][j]
				local node = bg:getChildByTag(i*10+j)
				node.cardByte = newByte[i][j]
			end
		end
		print("6666666666666666666666666666666666666")
		dump(byteMap)
		self:getCtr():getByteMap(byteMap)
	end) 	
end
--*******************【“完成”的按钮】
function SszView:changeOver()
	local overBtn = bg:getChildByName("over_btn")
	overBtn:addClickEventListener(function()
		dump("123123123") 
	end) 	
end

--*******************【牌型检测】
function SszView:cardJudge(dataCheck, dataPaiXing)
	local judge1_R = bg:getChildByName("judge1_R")
	local judge1_W = bg:getChildByName("judge1_W")
	local judge2_R = bg:getChildByName("judge2_R")
	local judge2_W = bg:getChildByName("judge2_W")
	local judge3_R = bg:getChildByName("judge3_R")
	local judge3_W = bg:getChildByName("judge3_W")
	if dataCheck[1] then
		judge1_R:setOpacity(255)
		judge1_W:setOpacity(0)
	else
		judge1_R:setOpacity(0)
		judge1_W:setOpacity(255)
	end	
	if dataCheck[2] then
		judge2_R:setOpacity(255)
		judge2_W:setOpacity(0)
	else
		judge2_R:setOpacity(0)
		judge2_W:setOpacity(255)
	end	
	if dataCheck[3] then
		judge3_R:setOpacity(255)
		judge3_W:setOpacity(0)
	else
		judge3_R:setOpacity(0)
		judge3_W:setOpacity(255)
	end
	local tips1 = bg:getChildByName("tips1")
	local tips2 = bg:getChildByName("tips2")
	local tips3 = bg:getChildByName("tips3")
	local tips = {}
	table.insert(tips, tips1)
	table.insert(tips, tips2)
	table.insert(tips, tips3)
	dump(tips)
	dump(dataPaiXing)
	for i = 1, #dataPaiXing do
		if dataPaiXing[i] < 200 then
			tips[i]:setString("高牌")
		elseif dataPaiXing[i] < 300 then
			tips[i]:setString("一对")
		elseif dataPaiXing[i] < 400 then
			tips[i]:setString("两对")
		elseif dataPaiXing[i] < 500 then
			tips[i]:setString("三条")
		elseif dataPaiXing[i] < 600 then
			tips[i]:setString("顺子")
		elseif dataPaiXing[i] < 700 then
			tips[i]:setString("同花")
		elseif dataPaiXing[i] < 800 then
			tips[i]:setString("葫芦")
		elseif dataPaiXing[i] < 900 then
			tips[i]:setString("铁支")
		elseif dataPaiXing[i] < 1000 then
			tips[i]:setString("同花顺")
		elseif dataPaiXing[i] > 1000 then
			tips[i]:setString("皇家同花顺")
		end
	end
end

--*******************【对牌添加监听事件】
function SszView:changeCards()
	local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(true)
	local node, x0, y0, x, y = nil--【node:开始触摸的牌的节点 x0:开始触摸的X值 y0:开始触摸的Y值  x:结束触摸的X值 y:结束触摸的Y值】
	local arr, brr, arrX, arrY = nil--【arr:保存第1次点击牌的byte值 brr:保存第2次点击牌的byte值 arrX、arrY:保存第1次点击牌的X、Y值】
	local nodeZOrder = 1--设置渲染顺序
	--【开始触摸】
	listener:registerScriptHandler(function(touch, event)
		print("TOUCH_BEGAN")
		--获得开始触摸的牌的节点
		local point = bg:convertToNodeSpace(cc.p(touch:getLocation().x, touch:getLocation().y))
		print("point.x"..point.x)
		print("point.y"..point.y)
		for i = 1, #byteMap do
			for j = 1, #byteMap[i] do
				local rect = cc.rect(spaceMap[i][j].x-40, spaceMap[i][j].y-50, 80, 96)
				if cc.rectContainsPoint(rect, point) then
					x0, y0 = i, j
					node = bg:getChildByTag(i*10+j)
					node:setScale(0.43)
				end 
			end
		end
		node:setLocalZOrder(nodeZOrder)
		nodeZOrder = nodeZOrder + 1
		--点击换牌的实现
		if not arr and x0 and y0 then
			arr = byteMap[x0][y0]
			arrX = x0 
			arrY = y0
		elseif arr and x0 and y0 then
			if arrX== x0 and arrX== y0 then
				local node_1 = bg:getChildByTag((x0)*10+y0)
				node_1:setScale(0.4)
				arr, arrX, arrY, node_1 = nil
			else
				local arrNode = bg:getChildByTag(arrX*10+arrY)
				local brrNode = bg:getChildByTag((x0)*10+y0)
				arrNode:setScale(0.4)
				brrNode:setScale(0.4)
				brr = byteMap[x0][y0]
				byteMap[x0][y0] = arr
				byteMap[arrX][arrY] = brr
				arrNode.cardByte = brr
				brrNode.cardByte = arr
				arr, brr, arrX, arrY, arrNode, brrNode = nil
				self:getCtr():getByteMap(byteMap)
			end
		end

		return  true;
	end,cc.Handler.EVENT_TOUCH_BEGAN)
	--【触摸移动】
	listener:registerScriptHandler(function(touch, event)
		arr, brr, arrX, arrY = nil --当触摸移动时不管是否直接将
		print("TOUCH_MOVED")
		local currentPosX , currentPosY = node:getPosition();
		local diff = touch:getDelta();
		node:setPosition(cc.p(currentPosX + diff.x,currentPosY + diff.y));
		local node_
		for i = 1, #byteMap do
			for j = 1, #byteMap[i] do
				local rect = cc.rect(spaceMap[i][j].x+5, spaceMap[i][j].y+10, 50, 60)
				if cc.rectContainsPoint(rect, cc.p(currentPosX + diff.x,currentPosY + diff.y)) then
					x, y = i, j
					node_ = bg:getChildByTag(x*10+y)
					node_:setScale(0.43)
					node_ = nil
					print("--------------i="..i.."++++++++++j="..j)
					local cosX , cosY = node:getPosition();
					print("--------------x="..cosX.."++++++++++j="..cosY)
				end 
			end
		end
		if node_ then
			node_:setScale(0.4)
			node_ = nil
		end
	end,cc.Handler.EVENT_TOUCH_MOVED)
	--【结束触摸】
	listener:registerScriptHandler(function(touch, event)
		print("TOUCH_ENDED")
		local node1 --【结束触摸进行交换的牌的结点】
		local byte_0, byte_1,byte_0x,byte_0y,byte_1x,byte_1y--【byte_0:开始触摸的牌的byte值 byte_0x、byte_0y:开始触摸的X、Y值】
															--【byte_1:结束触摸的牌的byte值 byte_1x、byte_1y:开始触摸的X、Y值】
		if x and y then
			node1 = bg:getChildByTag(x*10+y)
			print("node1x="..x.."........".."node1y="..y)
			byte_1 = byteMap[x][y]
			byte_1x = x
			byte_1y = y
			node.cardByte = byteMap[x][y]
			x , y = nil 
		end
		if x0 and y0 then
			byte_0 =byteMap[x0][y0]
			print("node0x="..x0.."........".."node0y="..y0)
			byte_0x = x0
			byte_0y = y0
			if node1 then
				node1.cardByte = byteMap[x0][y0]
			end
			node:setPosition(spaceMap[x0][y0])
			x0 , y0 = nil 
		end
		if byte_0x and byte_0y and byte_1x and byte_1y then
			print(byte_0x.."byte_0x"..byte_0y.."byte_0y"..byte_1x.."byte_1x"..byte_1y.."byte_1y")
			byteMap[byte_1x][byte_1y] = byte_0
			byteMap[byte_0x][byte_0y] = byte_1
			byte_0, byte_1,byte_0x,byte_0y,byte_1x,byte_1y = nil
			self:getCtr():getByteMap(byteMap)
			node:setScale(0.4)
			node1:setScale(0.4)
		end
	end,cc.Handler.EVENT_TOUCH_ENDED);

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end


function SszView:init(data)
	byteMap = data
	self.byteMap = data --从Ctr获得牌的数据
	--*******************【加载场景】
	local creatorReader = creator.CreatorReader:createWithFilename("creator/Scene/SSZ.ccreator")
    creatorReader:setup()
	local gameScene = creatorReader:getNodeGraph()
	gameScene:addTo(self)
    bg = gameScene:getChildByName("bg")
	--*******************【加载单牌部件】
	createCards()
	--*******************【加载时钟部件】
	createClock()
	--*******************【第2、3行交换牌】
	self:changeRowCards()
	--*******************【对牌添加监听事件】
	self:changeCards()
	--*******************【“完成”的按钮】
	self:changeOver()	
end

function SszView:ctor()
	print("SszView")
end

return SszView;