local layoutFile = "creator/Scene/KevinZhang/pokerView.ccreator"
local SSZView = class("CardView", function() 
    local creatorReader = creator.CreatorReader:createWithFilename(layoutFile);
    creatorReader:setup();
	local view = creatorReader:getNodeGraph();
	return view
end)
return SSZView