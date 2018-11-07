local _M = class("testAutoBindData",cc.Node)
local bind = require("dev.demo.data.autobind.bindbase")



function _M:ctor()
    self:enableNodeEvents()
end

function _M:onEnter()
    	--测试自动绑定数据
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
        -- self:testNodeFunction()
        self:testUpdateNode()
        -- self:testDataListener()
    end)))
end

function _M:testNodeFunction()
    local sameData = {aa = 20,bb = 30,cc = 80}
    local container = {}
    print("start")
    for i=1,5 do
        local node = display.newNode()
        self:addChild(node)
        local tmp1 = bind.bindNode(sameData,"aa",node,function(node,value) 
            print("set i" .. tostring(i) .. "value" .. tostring(value))
        end,function ( node,value )
            print("get i" .. tostring(i) .. "value" .. tostring(value))
        end)
        local tmp2 = bind.bindNode(sameData,"bb",node,function(node,value) 
            print("set i" .. tostring(i) .. "value" .. tostring(value))
        end,function ( node,value )
            print("get i" .. tostring(i) .. "value" .. tostring(value))
        end)
        if i == 3 then
            tmp2()
        end
        container[i] = node
    end
    sameData.aa = 200
    sameData.bb = 2000
    container[3]:removeSelf()
    dump(sameData)
    bind.dump(sameData)
    for i=1,4 do
        container[i]:removeSelf()
    end
    dump(sameData)
    container[5]:removeSelf()
    dump(sameData)
    print("finish")
end

function _M:runDelayAction(delayTime,callback)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function() 
        if callback then
            callback()
        end
    end)))
end

function _M:testUpdateNode()
    local sameData = {aa = 20,bb = 30,cc = 80}
    local container = {}
    print("start")
    for i=1,5 do
        local content = "default"
        local node = cc.Label:createWithTTF(tostring(content),  "fonts/arial.ttf", 20)
        node:setColor(cc.c3b(255,0,0))
        node:setPosition(cc.p(100 * i,100 * i))
        self:addChild(node)
        bind.bindUpdateNode(sameData,"aa",node,"setString",function(node,value) 
            print("aaaaaa")
            return tostring(tostring(i) .. " aa " .. tostring(value))
        end)
        local unbind = bind.bindUpdateNode(sameData,"bb",node,"setString",function(node,value) 
            print("bbbbbbbbb")
            return tostring(tostring(i) .. " bb " .. tostring(value))
        end)
        if i == 3 then
            unbind()
        end
        container[i] = node
    end
    sameData.aa = 200
    sameData.bb = 2000
   
    self:runDelayAction(1.0,function() 
        for i,v in ipairs(container) do
            v:removeSelf()
        end
    end)

    print("finish")
end


function _M:testDataListener()
    local sameData = {aa = 20,bb = 90}
    local unbind = bind.bindDataListener(sameData,"aa",function(_,value) 
        print("aa new value is " .. tostring(value))
    end)
    sameData.aa = 90
    unbind()
    sameData.aa = 110
end

return _M