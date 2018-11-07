

local BehaviorBase = import(".BehaviorBase");

---组件工厂类
local behaviorsClass = {
    
}

local BehaviorFactory = {}

function BehaviorFactory.typeof( obj,classObj )
    -- body
    if  obj.__supers then
        local isType
        
        isType =  function (objData,name)
            -- body
            if objData.__supers and #objData.__supers>0 then

                for k,v in pairs(obj.__supers) do

                    if isType(v,name) then
                        return true;
                    end

                end

                return false;
            else
                 return objData.__cname == name; 
            end
        end

        return isType(obj,classObj.__cname)
       
    end
end

function BehaviorFactory.createBehavior(behaviorName)
    local classObj = behaviorsClass[behaviorName] 
    assert(classObj ~= nil, string.format("BehaviorFactory.createBehavior() - Invalid behavior name \"%s\"", tostring(behaviorName)))
    if BehaviorFactory.typeof(classObj,BehaviorBase) then
        return classObj.new()
    elseif type(classObj) == "table" and classObj.require and classObj.path then
        classObj = classObj.require(classObj.path);
        return classObj.new()
    else
        classObj = require(classObj);
        return classObj.new()
    end
    
end


function BehaviorFactory.createBehaviorByClass(behavior)
    local classObj = behavior
    -- dump(behavior)
    assert(classObj ~= nil, string.format("BehaviorFactory.createBehavior() - Invalid behavior name \"%s\"", tostring(behavior)))
    if BehaviorFactory.typeof(classObj,BehaviorBase) then
        print("yangshuai  BehaviorFactory.typeof true")
        return classObj.new()
    elseif type(classObj) == "table" and classObj.require and classObj.path then
        classObj = classObj.require(classObj.path);
         print("yangshuai  BehaviorFactory.typeof false")
        return classObj.new()
    end
     print("yangshuai  BehaviorFactory.typeof false")
    if type(behavior) == "string" then 
        error("behavior 不合法 类型是string")
    end
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