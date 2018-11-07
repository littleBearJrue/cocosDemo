--[[--ldoc desc
	定义大厅需要用到的全局对象
]]
local Global = {};
setmetatable(Global, {
    __newindex = function(_, name, value)
        cc.exports[name] = value;
    end,

    __index = function(_, name)
        return cc.exports[name]
    end
})


-----------------------------------------------------
-- -- 定义业务会用到的全局数据
-- 加载自定义事件模块
local event = import("framework.event");
Global.g_event = event.Event; -- 事件定义
Global.g_eventDispatcher = event.EventDispatcher; -- 事件处理器

-- 加载工具类
local utils = import("framework.utils");
Global.g_base64 = utils.Base64;
Global.g_bitUtil = utils.BitUtil;
Global.g_listLib = utils.ListLib;
Global.g_mathLib = utils.MathLib;
Global.g_moneyFormatUtil = utils.MoneyFormatUtil;
Global.g_numberLib = utils.NumberLib;
Global.g_stringLib = utils.StringLib;
Global.g_tableLib = utils.TableLib;
Global.g_timeLib = utils.TimeLib;
Global.g_nodeUtils = utils.NodeUtils;


local behavior = import("framework.behavior");
Global.BehaviorBase = behavior.BehaviorBase
Global.BehaviorExtend = behavior.BehaviorExtend
Global.BehaviorMap = behavior.BehaviorMap 

-- 加载protobuf
local pb = import("framework.pbc");
Global.g_protobuf = pb.pbManage;

local sys = import("framework.sys")
Global.NativeCall = sys.NativeCall;

local config = import("app.config.config");
Global.g_tableLib.merge(Global,config.Const);
Global.CMD = config.Cmd;


local extend = import("framework.extend");
Global.g_schedule = extend.Schedule;
Global.delete = extend.NodeEx.delete;
Global.deleteWithChildren = extend.NodeEx.deleteWithChildren;

-------------------------------------------------
-- 初始化公共模块
local function initData()
	local socket = import("framework.socket")
	Global.g_socket = socket.SocketManager:create();
end

return initData;