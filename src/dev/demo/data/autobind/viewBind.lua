

--内部方法
local extendFieldName = "__extendFieldName内部使用"
local function _innerBind(tab,bindID,callbacks,keyField)
    if callbacks == nil then
        callbacks = {}
    end
    if keyField == nil then
        keyField = ""
    else
        keyField = keyField .. "_"
    end
    local extendField = tab[extendFieldName]
    if extendField == nil then
        tab[extendFieldName] = {}
        extendField = tab[extendFieldName]
    end
    for k,v in pairs(tab) do
        if k ~= extendFieldName then
            if type(v) == "table" then
                tab[extendFieldName][k] = _innerBind(v,bindID,callbacks,keyField .."".. tostring(k))
            else
                tab[extendFieldName][k] = v
            end
            tab[k] = nil
        end
    end
    local oldmeta = getmetatable(tab)
    if oldmeta == nil then
        setmetatable(tab, {__hasnotmeta = true})
    end
    oldmeta = getmetatable(tab)
    if oldmeta.__has_modify_meta_flag == nil then
        oldmeta.__has_modify_meta_flag = true
        --备份，撤销绑定时候需要
        oldmeta.__old__index = oldmeta.__index
        oldmeta.__old__newindex = oldmeta.__newindex

        oldmeta.__bindCallbacks = {}
        oldmeta.__index = function(_,key)
            for k,v in pairs(oldmeta.__bindCallbacks) do
                if v then
                    v("get",keyField .. tostring(key))
                end
            end
            local ret
            if oldmeta.__old__index then
                ret = oldmeta.__old__index(_,key)
            end
            if ret == nil then
                ret = tab[extendFieldName][key]
            end
            return ret
        end
        oldmeta.__newindex = function(_,key,value)
            if type(value) == "table" then
                tab[extendFieldName][key] = _innerBind(value,bindID,callbacks,keyField .."".. tostring(key))
            else
                tab[extendFieldName][key] = value
            end
            if oldmeta.__old__newindex then
                oldmeta.__old__newindex(_,key,value)
            end
            for k,v in pairs(oldmeta.__bindCallbacks) do
                if v then
                    v("set",keyField .. tostring(key),value)
                end
            end
        end
        setmetatable(tab, oldmeta)
    end
    oldmeta.__bindCallbacks[bindID] = callbacks
    return tab
end

local function _innerUnBind(tab,bindID)
    local extendField = rawget(tab,extendFieldName)
    if extendField == nil then
        return tab
    end
    local oldmeta = getmetatable(tab)
    if oldmeta and oldmeta.__bindCallbacks then
        oldmeta.__bindCallbacks[bindID] = nil
    end
    local binds = 0
    for k,v in pairs(oldmeta.__bindCallbacks) do
        binds = binds + 1
    end
    if binds == 0 then
        oldmeta.__has_modify_meta_flag = nil
        oldmeta.__index = oldmeta.__old__index
        oldmeta.__newindex = oldmeta.__old__newindex
        oldmeta.__old__index = nil
        oldmeta.__old__newindex = nil
        if oldmeta.__hasnotmeta == true then
            setmetatable(tab, nil)
        else
            oldmeta.__hasnotmeta = nil
            setmetatable(tab, oldmeta)
        end
        for k,v in pairs(extendField) do
            if k ~= extendFieldName then
                if type(v) == "table" then
                    tab[k] = clone(_innerUnBind(v,bindID))
                else
                    tab[k] = v
                end
            end
        end
        tab[extendFieldName] = nil
    end
    return tab
end

local function bind(tab,bindID,callbacks,name)
    return _innerBind(tab,bindID,callbacks,name)
end

local function unbind(tab,bindID)
    return _innerUnBind(tab,bindID)
end






--该方法需要扩展NodeEx.lua文件支持自定义退出回调
--  node 绑定结点，支持Node即子元素
--  exitCallbackID 分组回调，相关一组为同一值
--  tab 绑定数据源
--  bindID 用于区分数据源上的不同绑定ID ，不同结点绑定相同数据源需要使用该字段来区分
--  callbacks 绑定数据回调
--  name 用于自定义名称，默认不传

local isFirstLoad = true --第一次需要校验NodeEx中是否有自定义方法
local function bindNode(node,exitCallbackID,tab,bindID,callbacks,name)
    if isFirstLoad then
        assert(cc.Node.addExitCallback ~= nil ,"需要扩展支持自定义销毁")
        assert(cc.Node.getExitCallbackByName ~= nil ,"需要扩展支持自定义销毁")
        isFirstLoad = false
    end
    
    node:enableNodeEvents()
    bind(tab,bindID,callbacks,name)
    if node:getExitCallbackByName(exitCallbackID) == nil then
        node:addExitCallback(exitCallbackID,{}) 
    end
    local ExitIDTab = node:getExitCallbackByName(exitCallbackID)
    local unbindFuc = function() 
        unbind(tab,bindID)
    end
    ExitIDTab[#ExitIDTab + 1] = unbindFuc
    return function() 
        unbindFuc()
        local ExitIDTab = node:getExitCallbackByName(exitCallbackID)
        local i = 0
        for i,v in ipairs(ExitIDTab) do
            if v ==  unbindFuc then
                break
            end
        end
        if i > 0 then
            table.remove( ExitIDTab, i )
        end
        if i == 1 then
            node:addExitCallback(exitCallbackID,nil) 
        end
    end
end


return {
    bind = bind,
    unbind = unbind,
    bindNode = bindNode
}
