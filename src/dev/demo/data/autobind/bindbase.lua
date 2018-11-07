
-- local methodField = "__methodField" --方法字段，aa bb cc
-- local methodFieldPart = "__methodFieldPart" --方法字段

-- local nodeFiedld = "__nodeFiedld" --没法方法字段对应的绑定字段值
-- local funcFiedld = "__funcFiedld"
-- local realValueField = "__realValueField"

-- local function bind(tab,fieldName,node,func)
--     if node.enableNodeEvents == nil then
--         assert(false,"该node结点不支持")
--     end
--     node:enableNodeEvents()
--     local firstValue = tab[fieldName]
--     tab[fieldName] = nil
--     if tab[methodField] == nil then
--         local methodTab = {}
--         setmetatable(tab, {
--             __index = function(_,key)
--                 if key == methodField then
--                     return methodTab
--                 end
--             end,
--             __newindex = function ( _,key,value )
--                 if key == methodField then
--                     methodTab = value
--                 end
--             end
--         })
--     end
--     local methodTab = tab[methodField]
--     if methodTab[fieldName .. methodFieldPart] == nil then
--         local valueTab = {[nodeFiedld] = {},[realValueField] = {},[funcFiedld] = {}}
--         methodTab[fieldName .. methodFieldPart] =  valueTab
--         local oldMeta = getmetatable(tab)
--         setmetatable(tab, {
--             __index = function(_,key)
--                 if key == fieldName then
--                     return valueTab[realValueField]
--                 elseif key == fieldName .. methodFieldPart then
--                     return valueTab
--                 else
--                     return oldMeta.__index(_,key)
--                 end
--             end,
--             __newindex = function ( _,key,value )
--                 oldMeta.__newindex(_,key)
--                 if key == fieldName .. methodFieldPart then
--                     assert(false,"不能赋值")
--                 elseif key == fieldName then
--                     valueTab[realValueField] = value
--                     for i,v in ipairs(valueTab[nodeFiedld]) do
--                         local func = valueTab[funcFiedld][i]
--                         if func then
--                             func(v,value)
--                         end
--                     end
--                 end
--             end
--         })
--     end
--     local tableValue = tab[fieldName .. methodFieldPart]
--     tableValue[realValueField] = firstValue
--     tableValue[nodeFiedld][#tableValue[nodeFiedld] + 1] = node
--     tableValue[funcFiedld][#tableValue[funcFiedld] + 1] = func
--     local function unbind()
--         local index = 0
--         for i,v in ipairs(tableValue[nodeFiedld]) do
--             if v == self then
--                 index = i
--                 break
--             end
--         end
--         if index > 0 then
--             table.remove( tableValue[nodeFiedld], index)
--             table.remove( tableValue[funcFiedld], index)
--         end
--     end
--     local oldOnExit = node.onExit
--     node.onExit = function ( self )
--         unbind()
--         oldOnExit()
--     end
--     return function() 
--         unbind()
--         node.onExit = oldOnExit
--     end
-- end


-- return bind

-- local autoBind = require("app.data.autobind.bindbase")
-- local sameData = {aa = 20,bb = 30}
-- for i=1,5 do
--     local node = display.newNode()
--     self:addChild(node)
--     autoBind(sameData,"aa",node,function(node,value) 
--         print("current i" .. tostring(i) .. "value" .. tostring(value))
--     end)
--     autoBind(sameData,"bb",node,function(node,value) 
--         print("current bb i" .. tostring(i) .. "value" .. tostring(value))
--     end)
-- end
-- sameData.aa = 200
-- sameData.bb = 2000
-- print(sameData.aa)
-- print(sameData.bb)



--使用新版
local innerFieldName = "__内部使用"
local function _innerBind(valueTable,fieldName,node,setFunc,getFunc)
    if string.find( fieldName,innerFieldName ) or fieldName == nil then
        assert(false,"不能使用内部字段作为fieldName 或者 fieldName 不能为nil" .. tostring(fieldName))
        return nil
    end
    
    local innerTable = valueTable[innerFieldName]
    if innerTable == nil then
        local oldMeta = getmetatable(valueTable)
        local innerTableValue = {}
        setmetatable(valueTable, {
            __index = function(_,key)
                if key == innerFieldName then
                    return innerTableValue
                end
                return oldMeta.__index(_,key)
            end,
            __newindex = function(_,key,value)
                if key == innerFieldName then
                    if value == nil then
                    else
                        assert(false,"禁止赋值")
                    end
                else
                    oldMeta.__newindex(_,key,value)
                end
            end,
        })
        innerTable = valueTable[innerFieldName]
    end
    local fieldTableValue = innerTable[fieldName .. innerFieldName]
    if fieldTableValue == nil then
        local oldMeta = getmetatable(valueTable)
        fieldTableValue = {readlValue = clone(rawget(valueTable,fieldName)),callback = {}}
        innerTable[fieldName .. innerFieldName] = fieldTableValue
        rawset(valueTable,fieldName,nil)
        setmetatable(valueTable, {
            __index = function(_,key)
                if key == fieldName then
                    local realValue = fieldTableValue.readlValue
                    local callbackTable = fieldTableValue.callback
                    for i,callback in ipairs(callbackTable) do
                        if callback and callback.get then
                            callback.get(callback.node,realValue)
                        end
                    end
                    return realValue
                elseif key == fieldName .. innerFieldName then
                    return fieldTableValue
                end
                return oldMeta.__index(_,key)
            end,
            __newindex = function(_,key,value)
                if key == fieldName then
                    fieldTableValue.readlValue = value
                    local callbackTable = fieldTableValue.callback
                    for i,callback in ipairs(callbackTable) do
                        if callback and callback.set then
                            callback.set(callback.node,value)
                        end
                    end
                elseif key == fieldName .. innerFieldName then
                    --释放闭包
                    if value == nil then
                        if innerTable == nil then
                            dump(valueTable[innerFieldName])
                            return
                        end
                        local count = 0
                        for k,v in pairs(innerTable) do
                            count = count + 1
                            if v == fieldTableValue then
                                innerTable[k] = nil
                                break;
                            end
                        end
                        fieldTableValue = nil
                        if count == 1  then
                            valueTable[innerFieldName] = nil
                        end
                    else
                        assert(false,"禁止赋值")
                    end
                else
                    oldMeta.__newindex(_,key,value)
                end
            end,
        })
    end
    
    local callback = {node = node,get = getFunc,set = setFunc}
    fieldTableValue.callback[#fieldTableValue.callback + 1] = callback
    local function unbind()
        local index = 0
        for i,callback in ipairs(fieldTableValue.callback) do
            if callback.node == node then
                index = i;
                break;
            end
        end
        if index > 0 then
            table.remove(fieldTableValue.callback,index)
            if #fieldTableValue.callback == 0 then
                rawset(valueTable,fieldName,fieldTableValue.readlValue)
                valueTable[fieldName .. innerFieldName] = nil
            end
        end
    end
    return unbind
end

--绑定继承node结点
local function bindNode(valueTable,fieldName,node,setFunc,getFunc)
    local unbind = _innerBind(valueTable,fieldName,node,setFunc,getFunc)
    node:enableNodeEvents()
    local oldExitFunc = node.onExit
    if node.onExitRemoveNodeTab == nil then
        node.onSourceExit = node.onExit
        node.onExitRemoveNodeTab = {}
        node.onExit = function()
            dump(node.onExitRemoveNodeTab)
            for _,func in ipairs(node.onExitRemoveNodeTab) do
                func()
            end
            node.onSourceExit(node)
        end
    end
    node.onExitRemoveNodeTab[#node.onExitRemoveNodeTab + 1] = unbind
    return function() 
        unbind()
        for index,func in ipairs(node.onExitRemoveNodeTab) do
            if func == unbind then
                table.remove(node.onExitRemoveNodeTab,index)
                break
            end
        end
        if #node.onExitRemoveNodeTab == 0 then
            node.onExitRemoveNodeTab = nil
            node.onExit = node.onSourceExit
            node.onSourceExit = nil
        end
    end
end

--绑定通用控件赋值
local function bindUpdateNode(valueTable,fieldName,node,updateFucName,transFunc)
    return _innerBind(valueTable,fieldName,node,function(node,value) 
        if transFunc then
            value = transFunc(node,value)
        end
        node[updateFucName](node,value)
    end)
end

--该方法注册数据监听需要手动移除
local function bindDataListener(valueTable,fieldName,updateFunc)
    return _innerBind(valueTable,fieldName,_,updateFunc)
end


--打印
local g_dump = dump
local function dump(valueTable)
    local innerTable = valueTable[innerFieldName]
    if innerTable then
        g_dump(innerTable)
    end
    g_dump(valueTable)
end

--test node
return {
    bindNode = bindNode,
    bindUpdateNode = bindUpdateNode,
    bindDataListener = bindDataListener,
    dump = dump
}
