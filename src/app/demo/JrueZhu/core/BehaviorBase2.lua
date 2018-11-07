-- @Author: RonanLuo
-- @Date:   2017-12-27 18:26:12
-- @Last Modified by   RonanLuo
-- @Last Modified time 2018-03-09 16:13:24

local BehaviorBase = require(g_BYFrameworkPath.."behaviors.BehaviorBase")
local BehaviorBase2 = class(BehaviorBase, "BehaviorBase2");

BehaviorBase2.static_ = false;

BehaviorBase2.exportInterface = {
	-- "foo"
	-- {method = "foo", deprecatedOriginMethod = true, callOriginMethodLast = false}
}

BehaviorBase2.exportData = {}

function BehaviorBase2:ctor( ... )
    -- body
end

function BehaviorBase2:bindMethod(object, info)
    assert(self.getDepends)
    if type(info) == "string" then
		local foo = self.static_ and self[info] or handler(self, self[info]);
        object:bindMethod(self, info, foo);
    elseif type(info) == "table" then
		local foo = self.static_ and self[info.method] or handler(self, self[info.method]);
        object:bindMethod(self, info.method, foo, info.deprecatedOriginMethod == true, info.callOriginMethodLast == true)
    end
end

function BehaviorBase2:bind(object)
    for i,v in ipairs(self.exportInterface) do
    	self:bindMethod(object, v);
    end

    for k,v in pairs(self.exportData) do
        assert(not object[k], "object already have field : "..k);
        if type(v) == "table" then
            object[k] = table.copyTab(v);
        else
            object[k] = v;            
        end
    end

end

return BehaviorBase2;