package.path = package.path .. ";../?.lua;"
require("IOEx")
require("StringLib");

local modName = "JsonBehavior";---填写组件名称

local app = "../../../behaviorDemo/a/b/c"; -- 组件文件存放的路径
local modDir = app .. "/"; 

-- 判断生成目录是否存在，否则直接创建
createDir(modDir);

local function getAuthor()
	local t = io.popen("echo %username%"); -- 调用系统的批处理脚本获取系统的用户名
	local a = t:read("*all");
	a = string.sub(a,1,-2);
	local authorMap = {
		["FuYao"] = "FuYao";
	};
	if not authorMap[tostring(a)] then
		error("请添加中文名配置");
	end
	return authorMap[tostring(a)];
end
local tab = os.date("*t",os.time());
local time = string.format("%s-%s-%s",tab.year,tab.month,tab.day);
local Author = getAuthor();

if io.exists("Template.lua") then
	local content = io.readfile("Template.lua");
	content = string.replaceAll(content,"Template",modName)
	content = string.format(content,Author,time,Author,time);
	local path = modDir .. modName ..".lua";
	io.writefile(path,content);
end