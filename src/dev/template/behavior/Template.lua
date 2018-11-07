--[[--ldoc desc
@module Template
@author %s

Date   %s
Last Modified by   %s
Last Modified time %s
]]

---对外导出接口
local exportInterface = {
	"getExportProperties",
	"clearExportProperties",
};

---对外导出属性
local exportProperties = {
};

local BehaviorBase = require("framework.behavior.BehaviorBase")

local Template = class("Template",BehaviorBase)
Template.className_  = "Template";

function Template:ctor()
    Template.super.ctor(self, "Template", nil, 1);
    self.exportProperties_ = clone(exportProperties);
end

function Template:dtor()
	
end

-- 组件的方法绑定到object
function Template:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]), true);
    end 
end

-- object解绑组件的方法
function Template:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

function Template:getExportProperties()
    return self.exportProperties_
end

function Template:clearExportProperties()
    self.exportProperties_ = {}
end

-- 组件重置
function Template:reset(object)

end

return Template;