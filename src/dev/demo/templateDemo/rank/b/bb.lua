
local bb = class("bb",cc.Node);


function bb:ctor()
	self:init();
end

function bb:init()

	local layer = cc.Layer:create();
	self:addChild(layer);
    
	local title = cc.Label:createWithSystemFont("demobbbbbbbbbb","",36);
	title:setPosition(display.cx,display.height-100);
	layer:add(title);
end

return bb;