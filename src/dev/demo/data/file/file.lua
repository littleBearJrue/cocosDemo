local _M = {}

---------------------基础API start-----------------------
--所有写入需要写入权限，需要放在device.writablePath 目录下面
local fu = cc.FileUtils:getInstance()
local uf = cc.UserDefault:getInstance()
local writablePath = device.writablePath
local directorySeparator = device.directorySeparator

--二进制文件读写
local function readBin(path)
    return fu:getDataFromFile(path)
end

local function writeBin(path,content)
    return io.writefile(path,content,"w+b")
end


--字符串读写
local function readStr(path)
    return fu:getStringFromFile(path)
end

local function writeStr(path,content)
    return fu:writeStringToFile(path,content)
end
---------------------基础API end-----------------------

function _M.readFile(path,isStr)
    if isStr == nil then
        isStr = true
    end
    if isStr then
        return readStr(path)
    else
        return readBin(path)
    end
end

function _M.writeFile(path,content,isStr)
    if isStr == nil then
        isStr = true
    end
    if content == nil then
        return;
    end
    if not string.find( path,writablePath) then
        if path == nil then
            return
        end
        if string.find( path, directorySeparator) == 1 then
            path = string.sub( path, #directorySeparator + 1)
        end
        path = writablePath .. directorySeparator .. path
    end
    if isStr then
        return writeStr(path,content)
    else
        return writeBin(path,content)
    end
end

function _M.getUF()
    return uf
end

function _M.getFU()
    return fu
end

--其他API需要手动调用系统方法，这里不提供
--fuction io.pathinfo /  io.filesize / io.exists /io.readfile /io.writefile 
-- lua提供了 io.open 等类似C，可以实现定位读写
-- local file = io.open(path, "r")
-- if file then
--     local current = file:seek()
--     size = file:seek("end")
--     file:seek("set", current)
--     io.close(file)
-- end



return _M