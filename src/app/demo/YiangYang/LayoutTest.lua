
--[[
	layout 默认是绝对布局排列方式的
	当设置排列方式（横/纵向）后，子节点会自动计算size及position，
	从layout左上角开始排列，设置子view position没有效果

	Layout容器下布局
	ccui.LayoutType =
	{
	ABSOLUTE = 0, --绝对布局 默认 子元素按照绝对位置排列
	VERTICAL = 1, --垂直平铺
	HORIZONTAL = 2, --横向平铺
	RELATIVE = 3, --相对布局
	}

	ccui.LinearGravity =
	{
	none = 0,
	left = 1, --左侧对齐
	top = 2, --顶部对齐
	right = 3, --右侧对齐
	bottom = 4, --底部对齐
	centerVertical = 5, --垂直居中对齐线性布局
	centerHorizontal = 6, --水平居中对齐线性布局
	}

]]
local function createUI()
    -- 创建layout,内容添加到layout
    local layout = ccui.Layout:create()
    -- layout大小
    layout:setContentSize(display.width,display.height)
    -- layout:setBackGroundColor(cc.c3b(255,255,255))
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	layout:setBackGroundColor(cc.c3b(255, 255, 0));
  
    layout:setPosition(0,0)

    --纵向排列
    -- layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
    --横向排列
    layout:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)

 
    local parameter	=  ccui.LinearLayoutParameter:create()
    parameter:setGravity(ccui.LinearGravity.centerVertical) --纵向居中
    -- parameter:setGravity(ccui.LinearGravity.centerHorizontal) --横向居中
    parameter:setMargin({ left = 20, top = 0, right = 0, bottom  = 0 } ) --marginleft 20
    -- parameter:setMargin({ left = 0, top = 20, right = 0, bottom  = 0 } ) --margintop 20

    for i=1,3 do
	    local image = ccui.ImageView:create("HelloWorld.png")
	    layout:addChild(image)
	   	image:setLayoutParameter(parameter)
    end
    local sp = ccui.ImageView:create("yiang/caishen.png")

    sp:setLayoutParameter(parameter)
    sp:setPosition(cc.p(layout:getContentSize().width / 2,layout:getContentSize().height / 2))
    layout:addChild(sp)

    return layout
end

--[[
	
ccui.RelativeAlign =
{
    alignNone = 0,
    alignParentTopLeft = 1,
    alignParentTopCenterHorizontal = 2,
    alignParentTopRight = 3,
    alignParentLeftCenterVertical = 4,
    centerInParent = 5,
    alignParentRightCenterVertical = 6,
    alignParentLeftBottom = 7,
    alignParentBottomCenterHorizontal = 8,
    alignParentRightBottom = 9,
    
    locationAboveLeftAlign = 10,
    locationAboveCenter = 11,
    locationAboveRightAlign = 12,
    locationLeftOfTopAlign = 13,
    locationLeftOfCenter = 14,
    locationLeftOfBottomAlign = 15,
    locationRightOfTopAlign = 16,
    locationRightOfCenter = 17,
    locationRightOfBottomAlign = 18,
    locationBelowLeftAlign = 19,
    locationBelowCenter = 20,
    locationBelowRightAlign = 21,
}
]]
local function createRelativeUI()
    -- 创建layout,内容添加到layout
    local layout = ccui.Layout:create()
    -- layout大小
    layout:setContentSize(display.cx,display.cy)
    -- layout:setBackGroundColor(cc.c3b(255,255,255))
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	layout:setBackGroundColor(cc.c3b(255, 255, 0));
  
    layout:setPosition(0,0)


    --相对布局排列
    layout:setLayoutType(ccui.LayoutType.RELATIVE)


    local parameter	=  ccui.RelativeLayoutParameter:create()
    -- parameter:setAlign(ccui.RelativeAlign.alignNone)

    -- parameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentTopCenterHorizontal)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentTopRight)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentLeftCenterVertical)
    parameter:setAlign(ccui.RelativeAlign.centerInParent)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentRightCenterVertical)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentLeftBottom)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentBottomCenterHorizontal)
    -- parameter:setAlign(ccui.RelativeAlign.alignParentRightBottom)

    -- parameter:setMargin({ left = 20, top = 0, right = 0, bottom  = 20 } )
    parameter:setRelativeName("image") --给组件布局属性设置一个名字，别人可以找到它

    local image = ccui.ImageView:create("HelloWorld.png")
   	image:setLayoutParameter(parameter)
    layout:addChild(image)

    local spParameter	=  ccui.RelativeLayoutParameter:create()
    spParameter:setAlign(ccui.RelativeAlign.locationAboveLeftAlign)
    spParameter:setRelativeToWidgetName("image")--设定当前组件要与哪个组件对齐
    local sp = ccui.ImageView:create("yiang/caishen.png")

    sp:setLayoutParameter(spParameter)
    layout:addChild(sp)
    -- layout:setOpacity(50)
    -- layout:setScale(2,2)
    return layout
end


local function main()
    local scene = cc.Scene:create()
    -- scene:addChild(createUI())
    scene:addChild(createRelativeUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main