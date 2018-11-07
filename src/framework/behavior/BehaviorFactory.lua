--[[
    组件工厂类
]]

local behaviorsClass = {
    
}

local BehaviorFactory = {}

function BehaviorFactory.createBehavior(behaviorName)
    local classObj = behaviorsClass[behaviorName] 
    assert(classObj ~= nil, string.format("BehaviorFactory.createBehavior() - Invalid behavior name \"%s\"", tostring(behaviorName)))
    if classObj.create then
        return classObj:create();
    end
    error("behavior 不合法 ")
end


function BehaviorFactory.createBehaviorByClass(behavior)
    local classObj = behavior
    assert(classObj ~= nil, string.format("BehaviorFactory.createBehavior() - Invalid behavior name \"%s\"", tostring(behavior)))
    if classObj.create then
        return classObj:create()
    end
    error("behavior 不合法 ")
end

function BehaviorFactory.combineBehaviorsClass(newBehaviorsClass)
    for k, v in pairs(newBehaviorsClass) do
        assert(behaviorsClass[k] == nil, string.format("BehaviorFactory.combineBehaviorsClass() - Exists behavior name \"%s\"", tostring(k)))
        behaviorsClass[k] = v   
    end
end

function BehaviorFactory.merge(newBehaviorsClass)
    for k, v in pairs(newBehaviorsClass) do
        behaviorsClass[k] = v   
    end
end


function BehaviorFactory.removeBehaviorsClass(removeBehaviorsClass)
    for k, v in pairs(removeBehaviorsClass) do
        behaviorsClass[k] = nil;      
    end
end

function BehaviorFactory.hasBehavior(key)
    return behaviorsClass[key]
end

return BehaviorFactory