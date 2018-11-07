


-- 删除对象
local function delete(obj)
  	do
	    local destory =
	    function(c)
	      	while c do
	        	if type(c) =="userdata" then
	          		if c.dtor then
	             	c.dtor(obj)
	          		end
		        else
		          	if type(c) =="table" then
		             	if rawget(c,"dtor") then
		                	c.dtor(obj)
		             	end
		          	end
	        	end
	        	c = getmetatable(c)
	        	c = c and c.__index
	      	end
	    end
    	destory(obj);
  	end
end

-- 删除对象的子节点
local function deleteWithChildren(node)
  	if node then
	    local chidren = node:getChildren()
	    for k,v in pairs(chidren) do
	      	deleteWithChildren(v)
	    end
    	delete(node)
  	end
end

return {delete = delete, deleteWithChildren = deleteWithChildren };