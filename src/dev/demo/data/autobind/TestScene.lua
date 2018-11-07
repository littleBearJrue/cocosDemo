local TestScene = class("TestScene",cc.Node)
local viewBind = require("dev.demo.data.autobind.viewBind")
local exitCallbackID = "dataSourceID"
local bindDataID = "fromTestScene"

function TestScene:ctor()
    self:initView()
end

function TestScene:onEnter()

end

function TestScene:onExit()

end

function TestScene:initView()
    self.m_root = NodeUtils:getRootNodeInCreator('creator/Scene/test_autoview.ccreator')
    self:addChild(self.m_root)

    
    local dataSource = {}
    local callbacks = function(method,key,value)
        if method == "set" then
            if key == "label1" or key == "label2" or key == "label3" or key == "label4" then
                self.m_root:seekNodeByName(key):setString(value)
            elseif key == "progressBar" then
                self.m_root:seekNodeByName(key):setPercent(value * 100)
            elseif key == "button" then
                local button = self.m_root:seekNodeByName(key)
                button:seekNodeByName("Label"):setString(value)
            elseif key == "selectIDx" then
                local parent = self.m_root:seekNodeByName("toggleContainer")
                parent:seekNodeByName("toggle" .. tostring(value)):setSelected(true)
            end
        end
    end
    viewBind.bindNode(self,exitCallbackID,dataSource,bindDataID,callbacks)
    dataSource.label1 = "initView_label1"
    dataSource.label2 = "initView_label2"
    dataSource.label3 = "initView_label3"
    dataSource.label4 = "initView_label4"
    dataSource.progressBar = 0.55
    dataSource.button = "clickMe"
    dataSource.selectIDx = 3
end

function TestScene:updateView()

end

return TestScene