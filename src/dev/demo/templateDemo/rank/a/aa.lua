
local aa = class("aa",cc.Node);


function aa:ctor()
	self:init();
end

function aa:init()

	local layer = cc.Layer:create();
	self:addChild(layer);
    
	local title = cc.Label:createWithSystemFont("demoaaaaaaaaaa","",36);
	title:setPosition(display.cx,display.height-70);
	layer:add(title);

	local bb = require(".b.bb")
    self:addChild(bb:create())
end

return aa;