local CardTest = {}
local CardView = import(".CardView")
local director = cc.Director:getInstance()
local view = director:getOpenGLView()
local designSize = view:getDesignResolutionSize()

--主函数
function CardTest:main( ... )
	--创建场景
	local scene = cc.Scene:create()
	self.scene = scene
	--可更改属性和值
	self.property = {
		cardType = 1,
		cardValue = 1,
		cardByte = 0x11,
		cardStyle = 1,
	}
	--标签列表
	self.lableList = {}
	--创建左边选择按钮布局
	self:createLeftLayout()
	--创建右边单牌布局
	self:createRightLayout()
	scene:addChild(CreateBackMenuItem())
	return scene
end

--修改函数
function CardTest:updateLabel( data )
	--修改cardByte同时修改cardType和cardValue
	if data.cardStyle then
		self.property.cardStyle = data.cardStyle
		self.lableList.cardStyle:setString("cardStyle:"..data.cardStyle)
		self.cardView.cardStyle = self.property.cardStyle
	end
	if data.cardByte then
		local cardType = math.floor(data.cardByte/16)
		local cardValue = data.cardByte%16
		self.property.cardByte = data.cardByte
		self.lableList.cardByte:setString("cardByte:"..data.cardByte)
		self.cardView.cardByte = self.property.cardByte
		self.property.cardType = cardType
		self.lableList.cardType:setString("cardType:"..self.property.cardType)
		self.property.cardValue = cardValue
		self.lableList.cardValue:setString("cardValue:"..self.property.cardValue)
	end
	--修改cardType同时修改cardByte
	if data.cardType then
		self.property.cardType = data.cardType
		self.lableList.cardType:setString("cardType:"..self.property.cardType)
		self.cardView.cardType = self.property.cardType
		self.property.cardByte = self.property.cardType * 16 + self.property.cardValue
		self.lableList.cardByte:setString("cardByte:"..self.property.cardByte)
	end
	--修改cardValue同时修改cardByte
	if data.cardValue then
		self.property.cardValue = data.cardValue
		self.lableList.cardValue:setString("cardValue:"..self.property.cardValue)
		self.cardView.cardValue = self.property.cardValue
		self.property.cardByte = self.property.cardType * 16 + self.property.cardValue
		self.lableList.cardByte:setString("cardByte:"..self.property.cardByte)
	end
end

function CardTest:createLeftLayout( ... )
	--创建左边布局
	local leftLayout = ccui.Layout:create()
	leftLayout:setContentSize(designSize.width/2,designSize.height)
	leftLayout:setPosition(0,0)
	self.scene:addChild(leftLayout)
	--设置背景色
	-- leftLayout:setBackGroundColor(cc.c3b(255,0,0))
	-- leftLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	--设置垂直弹性布局
	leftLayout:setLayoutType(ccui.LayoutType.VERTICAL)
	--对所有属性添加增减按钮和标签
	for key,value in pairs(self.property) do
		local layout = ccui.Layout:create()
		layout:setContentSize(designSize.width/2,designSize.height/4)
		leftLayout:addChild(layout)
		--设置水平弹性布局
		layout:setLayoutType(ccui.LayoutType.HORIZONTAL)
		--标签
		local valueLabel = ccui.Text:create(key..":"..self.property[key], s_arialPath, 18)
		self.lableList[key] = valueLabel
		--减按钮
		local sub = ccui.Button:create("Images/b2.png","Images/b2.png")
		layout:addChild(sub)
		local leftcallback = function(tag)
			self:updateLabel({[key] = self.property[key] - 1})
    	end
    	sub:addClickEventListener(leftcallback)
    	layout:addChild(valueLabel)
    	--加按钮
		local add = ccui.Button:create("Images/f2.png","Images/f2.png")
		layout:addChild(add)
		local rightcallback = function(tag)
			self:updateLabel({[key] = self.property[key] + 1})
    	end
		add:addClickEventListener(rightcallback)
	end

end

function CardTest:createRightLayout( ... )
	--创建右边布局
	local rightLayout = ccui.Layout:create()
	rightLayout:setContentSize(designSize.width/2,designSize.height)
	rightLayout:setPosition(designSize.width/2,0)
	self.scene:addChild(rightLayout)
	--设置背景色
	-- rightLayout:setBackGroundColor(cc.c3b(0,255,0))
	-- rightLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	--设置相对布局
	rightLayout:setLayoutType(ccui.LayoutType.RELATIVE)

	--添加单牌
	local cardView = CardView:create()
	self.cardView = cardView
	rightLayout:addChild(cardView)
	--设置单牌布局
	local parameter	= ccui.RelativeLayoutParameter:create()
	parameter:setAlign(ccui.RelativeAlign.centerInParent)
	cardView:setLayoutParameter(parameter)
end


return handler(CardTest, CardTest.main)