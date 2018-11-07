module模板使用：

可修改的参数：
modName = "aa"; ---填写场景名称
moduleName = "bb"; -- 要创建module模板名称
dataConfig = {
	modName = "cc"; -- 填写模块名称,生成对应的interface接口类
	logicName = "dd"; -- data的逻辑模板名称
	dataName = "ee"; -- data的数据模板名称
}; -

1、修改M.modName
2、Ctrl+B生成模板

生成3个文件：
1、modeName .. "Scene.lua" (模块场景类)
1、modeName .. "Ctr.lua" (模块逻辑类)
2、modeName .. "UI.lua"(模板UI类)

如果需要生成模块对应的data模板，设置dataConfig，就会生成对应的data模板
如果需要生成模块对应的module模板，设置模块名称moduleName，就会生成对应的module模板


目录结构：

modName
	init.lua
	config
		SceneConfig.lua
	modName .. "Scene.lua"
	modName .. "Ctr.lua"
	modName .. "UI.lua"
	moduleName
		moduleName
			moduleName .. "ModuleCtr.lua"
			moduleName .. "ModuleUI.lua"
		moduleName2
			......
	dataModule.modName
		dataModule.modName
			dataModule.modName .. "Interface.lua"(数据接口类提供给外部访问的)
			dataModule.logicName .. "Logic.lua"
			dataModule.dataName .. "Data.lua"
		dataModule.modName2
			......

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
scene中获取加载的module模块，Ctr中加载data模块
local func = self.getModule+配置的模块名称;
if func then
	local module = func(); -- 得到模块的pkg对象
end

如：
local SceneConfig = {
	-- 获取用户信息模块
	moduleConfig = {
		payModule = {
			file = {pkg = "scripts/app/hall/modules/payModule"};
		};
	};

	-- 获取数据模块
	dataConfig = {
		pay = {
			file = {pkg = g_ModuleConfig.pay};
		};	
	};
};
XxxScene.lua中获取payModule对象
local func = self.getModulepayModule;
if func then
	local module = func();
end
XxxCtr.lua中获取pay对象
local func = self.getModulepay;
if func then
	local module = func();
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------