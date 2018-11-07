require("lfs")
-- 检查文件是否存在
function io.exists(path)
	
	local file,err = io.open(path, "r")
	if file then
		io.close(file)
		print("path " .. path);
		return true
	end
	-- print("err " .. err);
	return false
end

function io.mkdir(path)
    if not io.exists(path) then
        return lfs.mkdir(path)
    end
    return true
end

function io.rmdir(path)
   
    if io.exists(path) then
    	 print("os.rmdir:", path)
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

-- 读取文件内容
function io.readfile(path)
	local file = io.open(path, "r")
	if file then
		local content = file:read("*a")
		io.close(file)
		return content
	end
	return nil
end

-- 写入文件
function io.writefile(path, content, mode)
	mode = mode or "w+"
	local file = io.open(path, mode)
	if file then
		if file:write(content) == nil then return false end
		io.close(file)
		return true
	else
		return false
	end
end

-- 解析文件路径信息
function io.pathinfo(path)
	local pos = string.len(path)
	local extpos = pos + 1
	while pos > 0 do
		local b = string.byte(path, pos)
		if b == 46 then -- 46 = char "."
			extpos = pos
		elseif b == 47 then -- 47 = char "/"
			break
		end
		pos = pos - 1
	end

	local dirname = string.sub(path, 1, pos)
	local filename = string.sub(path, pos + 1)
	extpos = extpos - pos
	local basename = string.sub(filename, 1, extpos - 1)
	local extname = string.sub(filename, extpos)
	return {
		dirname = dirname,
		filename = filename,
		basename = basename,
		extname = extname
	}
end

-- 获取文件大小
function io.filesize(path)
	local size = false
	local file = io.open(path, "r")
	if file then
		local current = file:seek()
		size = file:seek("end")
		file:seek("set", current)
		io.close(file)
	end
	return size
end

function io.getpaths(rootpath, pathes)
    pathes = pathes or {}
    for entry in lfs.dir(rootpath) do
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath..'/'..entry
            local attr = lfs.attributes(path)
            assert(type(attr) == 'table')
            if attr.mode == 'directory' then
                io.getpaths(path, pathes)
            else
                table.insert(pathes, path)
            end
        end
    end
    return pathes
end

-- 判断生成目录是否存在，否则直接创建
function createDir(dir)
	if not io.exists(dir) then
		local new_filename = ""
		if dir then
			-- 去掉尾部的"/"，可能没有，但为了防止连接字符串出错，还是做一次判断
			dir = string.gsub(dir, "\\", "\\\\")
			dir = string.gsub(dir, "[/\\]*$", "")
			
			-- 判断目录是否存在，其中>nul和2>nul是将修改重定向到空，否则当目录不存在时，会有错误提示
			if os.execute("cd " .. "\"" .. dir .. "\" >nul 2>nul") == 0 then
				new_filename = dir .. "/" .. new_filename
			elseif os.execute("mkdir " .. "\"" .. dir .. "\" >nul 2>nul") == 0 then
				new_filename = dir .. "/" .. new_filename
			else
				print("指定的目录有问题，请重新指定")
				return
			end
		end
		print("生成的组件文件存放路径：",new_filename)
	end
end