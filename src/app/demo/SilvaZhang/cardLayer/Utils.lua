local Utils = {}
local function getDesignConfig()
	local designConfig = {}
	local director = cc.Director:getInstance()
	local view = director:getOpenGLView()
	local designSize = view:getDesignResolutionSize()
	designConfig.designSize = designSize
	return designConfig
end
Utils.designConfig = getDesignConfig()
return Utils