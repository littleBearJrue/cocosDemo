

local function createUI()
	local cellTb = {}
    tableView = cc.TableView:create(cc.size(display.width / 3 , display.height/2))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) ----竖直从上往下排列
    tableView:setPosition(display.cx,100)
    tableView:setAnchorPoint(0,0)

   	tableView:setDelegate()

   	local function tableCellTouched(view,cell)
   		dump(cell, "cell == ")

   	end
   	
	local function cellSizeForTable(view,idx)
		return 70,150
   	end

	local function tableCellAtIndex(view,idx)
		local cell  = view:dequeueCell()
		if not cell then
			cell = cc.TableViewCell:create()

			local image = ccui.ImageView:create("HelloWorld.png")
			image:setAnchorPoint(0,0)
	        -- image:setPosition(cc.p(display.cx,display.cy))
	        cell:addChild(image)

	        local sp = ccui.ImageView:create("yiang/caishen.png")
			sp:setAnchorPoint(0,0)
	        cell:addChild(sp)

	        local label = cc.Label:createWithTTF("hello", s_arialPath, 30)
	        label:setAnchorPoint(0,0)
	        cell:addChild(label)
		  
			table.insert(cellTb,cell)
		end
		return cell
   	end

	local function numberOfCellsInTableView(view)
		return 10
   	end


   	--TableView被触摸的时候的回调，主要用于选择TableView中的Cell
   	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
   	--此回调需要返回TableView中Cell的尺寸大小
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    --此回调需要为TableView创建在某个位置的Cell
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    --此回调需要返回TableView中Cell的数量
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:reloadData()
    
    return tableView

end


local function main()
    local scene = cc.Scene:create()
    scene:addChild(createUI())
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main