--[[
	定义大厅用到的协议命令字
]]
local CMD = {};

---客户端发送命令到服务器
CMD.C2S = {
    HALL_REQUEST 			= 0xEEEF, -- RPC请求
    HEART_REQUEST 			= 0x2008, -- 心跳
    IM_REQUEST 				= 0xEEF0, -- IM消息
    MATCH_REQUEST           = 0xEEEC, -- 比赛消息
};

---服务器发送命令到客户端，协议都是双数
CMD.S2C = {
	HALL_RESPONSE 			= 0xEEEF, -- 大厅和后端交互的rpc消息
	HEART_RESPONSE 			= 0x600D, -- 心跳响应消息
	IM_RESPONSE 			= 0xEEF0, -- IM消息
    MATCH_RESPONSE          = 0xEEEC, -- 比赛消息
};

-- ingonre：ture，收到socket消息不入队列，收到即广播；false：收到消息后先压入消息队列中
CMD.op = {
	[CMD.S2C.HEART_RESPONSE] = {ingnore = true};
};


return CMD;