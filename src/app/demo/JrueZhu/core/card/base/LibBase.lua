local LibBase = class()

function LibBase:ctor(uniqueId)
	self.uniqueId = uniqueId;
	self.m_config = {}
end

function LibBase:updateConfig(config)
	for k,v in pairs(config) do
		self.m_config[k] = v;
	end
end

return LibBase;