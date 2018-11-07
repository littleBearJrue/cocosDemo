

local config = {};

config.debug = true;

config.logFlag = "HALL";

-- 日志上报类型
config.reportType = {
	ERROR = "error"; -- 错误日志
	COMMON = "common"; -- 普通日志
	HEART = "heart"; -- 心跳日志
	CONNECT = "connect"; -- 连接日志
	CLOSE = "close"; -- socket关闭日志
	RECEIVE = "receive"; -- 收包日志
	CDN = "cdn"; -- cnd日志
};

config.Constants = {
	SOCKET_REQUEST_TIMEOUT = -1; -- 消息响应超时
	SOCKET_CONNECT_ING = -2; -- 正在连接
	SOCKET_CONNECT_SUCCESS = -3; -- 连接成功
	SOCKET_CONNECT_FAILED = -4; -- 连接失败
	SOCKET_HEARTBEAT_TIMEOUT = -5; -- 心跳超时
	SOCKET_USER_CLOSING = -6; -- 正在关闭socket
	SOCKET_USER_CLOSED = -7; -- socket已经关闭
	SOCKET_RECONNECT_ING = -8; -- 重连中
	SOCKET_RECONNECT_SUCCESS = -9; -- 重连成功
	SOCKET_RECONNECT_FAILED = -10; -- 重连失败
	SOCKET_FIRST_CONNECTED = -11; -- 应用启动后首次连接成功
};

-- socket模块的组件配置
config.behaviorConfig = {
	-- SocketManager要绑定的组件
	mamager = {
		-- 必要的组件
		socketHeadBehavior = require("behavior.QPHeadBehavior"); -- socket协议包头组件
		managerBehavior = require("behavior.ManagerBehavior"); -- socket管理类的自定义组件
		msgBehavior = require("behavior.MsgQueueBehavior"); -- 消息队列组件    
		-- 可扩展的组件
		-- xxxxxx
	};
	-- 心跳需要绑定的组件
	heart = {
		-- 必要的组件
		heartBehavior = require("behavior.HeartBehavior"); -- 心跳组件
		-- 可扩展的组件
		-- xxxxxx
	};
	connect = {
		-- 必要的组件
		velocityBehavior = require("behavior.VelocityBehavior"); -- 网络连接组件    
		reportBehavior = require("behavior.ReportBehavior"); -- 网络数据上报组件  
		-- 可扩展的组件
		-- connectBehavior = ""; -- socket连接类的自定义组件
	};
	-- 默认的cdn配置
	cdndata = {
		imDataBehavior = require("behavior.CdnDataBehavior");
	};	
	socketReader = {
		readerBehavior = require("behavior.ReaderBehavior"); -- socket读包组件
	};
	socketWrite = {
		writeBehavior = require("behavior.WriteBehavior"); -- socket写包组件
	};
};

config.SVR_LINK_TIME_OUT = 5; -- socke连接超时时间
config.SVR_RCV_TIME_OUT = 5; -- server收包的超时时间为5s
config.HEART_TIME = 10; -- 心跳包间隔时间
config.MAX_HEART_RECORD = 50; -- 记录最近50次的心跳情况
config.CONNECT_TIME_OUT = 75000; -- 默认的连接失败时间
config.CONNECT_DEFAULT_TIME = 5000; -- 默认的连接时间,5s
config.HTTP_TIME_OUT = 5; -- htpp 下载超时时间15s

-- 特殊的测速域名
config.specialDaomain = {
	ip = "www.baidu.com";
	port = 80;
};

-- cdn配置的文件名称
config.cdnFileName = "socketConfig";

return config;