local const = {
	-- 点击状态定义
	kDPadTouchNone = -1;
	kDPadTouchDown = 0;
	kDPadTouchMove = 1;
	kDPadTouchUp = 2;

	-- 横竖屏常量定义
	ScrollHorizontal = 0;
	ScrollVertical = 1;

	-- socket状态定义
	SERVER_STATUS_NON = -1; -- 初始状态
	SERVER_STATUS_CONNECTING = 0; -- 开始连接
	SERVER_STATUS_CONNECTED = 1; -- 连接成功
	SERVER_STATUS_CONNECTFAIL = 2; -- 连接失败
	SERVER_STATUS_DISCONNECT = 3; -- 连接断开


	-- socket的服务类型定义
	NET_SOCKET_COMMON = 0;
	NET_SOCKET_IM = 1;


	LanguageType = {
	    Zh = 1,
	    En = 2,
	};
};

return const;