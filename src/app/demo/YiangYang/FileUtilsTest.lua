
local function saveFile( fileName ,data)
	print("fileName = ",fileName)
	local file
	if fileName == nil then
		error(("文件路径'%s' 为nil"):format(fileName))
	else
		local err
		file,err = io.open(fileName,"wb")
		if file == nil then
			error(("Unable to write '%s': %s"):format(fileName, err))
		end
	end
	-- data = json.encode(data)
	file:write(data)
	if fileName ~= nil then
		file:close()
	end
end


local function loadFile( fileName )
	local file
	if fileName == nil then
		error(("文件路径'%s' 为nil"):format(fileName))
	else
		local err
		file,err = io.open(fileName,"rb")
		if file == nil then
			error(("Unable to read '%s': %s"):format(fileName, err))
		end
	end
	local data = file:read("*a")-- 读取所有内容

	if fileName ~= nil then
		file:close()
	end

	if data == nil then
		error(("Failed to read '%s'"):format(fileName))
	end
	-- data = json.decode(data)
	return data
end 


local function doTest()
	local utils = cc.FileUtils:getInstance()
	local path = utils:getWritablePath().."/yiang.txt"
	local data = "写个文本保存起来"
	saveFile(path,data)
	print("=======保存之后获取=======")
	local ss = loadFile(path)
	print("data = ",ss)
end



local function main()
    local scene = cc.Scene:create()
    local s = cc.Director:getInstance():getWinSize() -- 获取屏幕大小
	local  label = cc.Label:createWithTTF("FileUtilsTest see log", s_arialPath, 28)-- 创建标签
	scene:addChild(label, 0)
	label:setAnchorPoint(cc.p(0.5, 0.5))
	label:setPosition( cc.p(s.width/2, s.height-50) )
    scene:addChild(CreateBackMenuItem())
    doTest()
    return scene

end

return main