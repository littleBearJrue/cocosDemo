package.path = package.path .. ";../?.lua;"
require("IOEx")
require("StringLib");

local M = {
	modName = "rank"; ---填写场景名称
};

function string.upperOrLower(str)
	local chars = string.toCharArray(str);
	-- 首字母大写
	chars[1] = string.upper(chars[1]);--变大写
	local upperStr = table.concat(chars);

	-- 首字母小写
	chars[1] = string.lower(chars[1]);--变小写
	local lowerStr = table.concat(chars);

	return upperStr,lowerStr;
end

local function getAuthor()
	local t = io.popen("echo %username%")
	local a = t:read("*all");
	a = string.sub(a,1,-2);
	local authorMap = {
		["FuYao"] = "FuYao";
		["BennyHuang"] = "BennyHuang";
		["ZanderWang"] = "ZanderWang";
		["TaylorTan"] = "TaylorTan";
	};
	if not authorMap[tostring(a)] then
		error("请添加中文名配置");
	end
	return authorMap[tostring(a)];
end
local tab = os.date("*t",os.time());
local time = string.format("%s-%s-%s",tab.year,tab.month,tab.day);
local Author = getAuthor();

M.app = "../../../app/hall/";

M.create = function()

	local upStr, lowStr = string.upperOrLower(M.modName);
	M.modName = upStr;
	local modDir = M.app .. lowStr .. "/"; 
	local configName = "SceneConfig";
	local config = modDir .. "config/"
	io.mkdir(modDir);
	io.mkdir(config);

	-- config配置文件
	local file = config .. configName .. ".lua";
	if io.exists("config/SceneConfig.lua") and (not io.exists(file)) then
		local content = io.readfile("config/SceneConfig.lua");
		content = string.format(content,Author,time);
		io.writefile(file, content);
	end

	-- 场景模板
	local file = modDir .. M.modName .."Scene.lua"
	if io.exists("TemplateScene.lua") and (not io.exists(file)) then
		local content = io.readfile("TemplateScene.lua");
		content = string.replaceAll(content,"Template",M.modName)
		content = string.format(content,Author,time);
		io.writefile(file, content);
	end

	-- 控制器模板
	local file = modDir ..M.modName .."Ctr.lua";
	if io.exists("TemplateCtr.lua") and (not io.exists(file)) then
		local content = io.readfile("TemplateCtr.lua");
		content = string.replaceAll(content,"Template",M.modName)
		content = string.format(content,Author,time);
		io.writefile(file, content);
	end

	-- UI模板
	local file = modDir .. M.modName .."UI.lua";
	if io.exists("TemplateUI.lua") and (not io.exists(file)) then
		local content = io.readfile("TemplateUI.lua");
		content = string.replaceAll(content,"Template",M.modName)
		content = string.format(content,Author,time);
		io.writefile(file, content);
	end

	-- 包结构
	local file = modDir .. "init.lua";
	if io.exists("init.lua") and (not io.exists(file)) then
		local content = io.readfile("init.lua");
		content = string.replaceAll(content,"Template",M.modName)
		content = string.format(content,Author,time);
		io.writefile(file, content);
	end

	-- 创建module模板
	if not string.isEmpty(M.moduleName) then
		local path = modDir .. "module/";
		local mode = loadfile("../module/createMod.lua");
		mode().update(path,M.moduleName);
	end

	-- 创建data模板
	local dataModule = M.dataConfig;
	if dataModule then
		if not string.isEmpty(dataModule.modName) then
			local path = modDir .. "data/";
			local mode = loadfile("../data/createMod.lua");
			mode().update(path,dataModule.modName,dataModule.logicName,dataModule.dataName);
		end
	end
end 

M.create();

return M;