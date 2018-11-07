local BiMap = {}

-- local __mt = {
-- 	__index = function (t,k)
-- 		return t._forward[k];
-- 	end
-- }
-- setmetatable(BiMap, __mt)

function BiMap:ctor(tbl)
	self._forward = {}
	self._reverse = {}
	if tbl then
		self:init(tbl);
	end
end

function BiMap:init(tbl)
	for k,v in pairs(tbl) do
		self:set(k,v);
	end
end

function BiMap:set(k, v)
	assert(not self._reverse[v], "value already exist!");
	self._forward[k] = v;
	self._reverse[v] = k;
end

function BiMap:get(k)
	return self._forward[k]
end

function BiMap:rget(k)
	return self._reverse[k]
end

function BiMap:getValueByKey(k)
	return self._forward[k];
end

function BiMap:getKeyByValue(v)
	return self._reverse[v];
end

function BiMap:getKeyValueMap(noCopy)
	if noCopy == true then return self._forward end
	local t = {}
	for k,v in pairs(self._forward) do
		t[k] = v
	end
	return t;
end

function BiMap:getValueKeyMap(noCopy)
	if noCopy == true then return self._reverse end
	local t = {}
	for k,v in pairs(self._reverse) do
		t[k] = v
	end
	return t;
end

return BiMap;