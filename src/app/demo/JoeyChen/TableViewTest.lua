-- @module: TableViewTest
-- @author: JoeyChen
-- @Date:   2018-10-22 17:36:25
-- @Last Modified by   JoeyChen
-- @Last Modified time 2018-10-22 18:34:35

local function createUI()
	local cellTb = {}
    tableView = cc.TableView:create(cc.size(200,200))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- 从上往下排列  
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(0.5,0.5)
    tableView:setPosition(display.cx, 80)

   	tableView:setDelegate()

   	local function tableCellTouched(view,cell)
   		dump(cell, "点击cell")
   	end
   	
	local function cellSizeForTable(view,idx)
		return 50,50
   	end

	local function tableCellAtIndex(view,idx)
		local cell  = view:dequeueCell()
		if not cell then
			cell = cc.TableViewCell:new()

			local sprite = cc.Sprite:create("JoeyChen/4.png")
			sprite:setAnchorPoint(0,0)
			sprite:addTo(cell)
		end
		return cell
   	end

	local function numberOfCellsInTableView(view)
		return 8
   	end

   	--触摸回调
   	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
   	-- 需返回TableView中Cell的尺寸大小
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    -- 需为TableView创建在某个位置的Cell
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    -- 需返回TableView中Cell的数量
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