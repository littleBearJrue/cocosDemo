function CreateBackMenuItem()
    local function backCallback()
        cc.Director:getInstance():popScene()
    end

    local backItem = cc.MenuItemImage:create(s_pPathB1,s_pPathB1)
    backItem:registerScriptTapHandler(backCallback)
    backItem:setAnchorPoint(1, 0)
    backItem:setPosition(VisibleRect:rightBottom())
    local backMenu = cc.Menu:create()
    backMenu:setPosition(0, 0)
    backMenu:addChild(backItem)
    return backMenu
end
