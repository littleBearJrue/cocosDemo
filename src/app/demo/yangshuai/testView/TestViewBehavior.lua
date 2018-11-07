--[[--ldoc desc
@module TestViewBehavior
@author ShuaiYang

Date   2018-10-22 17:04:45
Last Modified by   ShuaiYang
Last Modified time 2018-10-23 11:06:03
]]

local TestViewBehavior = class("TestViewBehavior",cc.load("boyaa").behavior.BehaviorBase);

local exportInterface = {
    -- "updateView",
    "addBtn",
}



function TestViewBehavior:addBtn(object)
	-- body
	print("TestViewBehavior addBtn");
	
	local testLabel = cc.Label:create()
    testLabel:setString("我是组件添加的view");
	testLabel:addTo(object.layout);
end


function TestViewBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true,false);
        -- object:bindMethod(self, v, handler(self, self[v]));
    end 
end

function TestViewBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end


return TestViewBehavior;