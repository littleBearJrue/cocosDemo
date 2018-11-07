--[[--ldoc desc
@module TestObserverBehavior
@author ShuaiYang

Date   2018-10-23 10:02:52
Last Modified by   ShuaiYang
Last Modified time 2018-10-23 11:05:21
]]

local TestObserverBehavior = class("TestObserverBehavior",cc.load("boyaa").behavior.BehaviorBase);

local DataBase = cc.load("boyaa").data.DataBase

local exportInterface = {
    -- "updateView",
    -- "addBtn",
    "initObserver",
    "changeData",
}

local exportProperties = {
    btnList = {
		[1] = {
			name = "观察者",
			fn = "initObserver",
		},
		[2] = {
			name = "数据改变",
			fn = "changeData",
		},

	},

}



function TestObserverBehavior:initObserver(object)
	object.test = DataBase.new();
	object.test:init();

	local t = {};
	t.onNotifyDataChange = function(self,key,value,oldValue)
			local str = string.format("数据改变了key=%s,value=%s,oldValue=%s",tostring(key),tostring(value),tostring(oldValue));
			if object.observerLabel then
				object.observerLabel:setString(str);
			else
				object.observerLabel = cc.Label:create();
				object.observerLabel:addTo(object.layout);
			end
			
	end

	object.test:addObserver(t) --添加数据变化观察者
	-- body
end

function TestObserverBehavior:changeData(object)
	-- body
	math.newrandomseed();
	object.test.a = math.random();
end

-- function TestObserverBehavior:addBtn(object)
-- 	-- body
-- 	print("TestObserverBehavior addBtn");
	
-- 	local testLabel = cc.Label:createWithTTF("", s_arialPath, 20)
-- 	testLabel:addTo(object.layout);
-- end


function TestObserverBehavior:bind(object)
	object.btnList = exportProperties.btnList;
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true,false);
    end 
end

function TestObserverBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end


return TestObserverBehavior;                                                                                                                                                           