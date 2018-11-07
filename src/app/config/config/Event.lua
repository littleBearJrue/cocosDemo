--
-- Author: Your Name
-- Date: 2018-01-18 16:25:50
--
-- 获取框架定义的event对象
local event = g_event;

-- 扩展大厅自定义的事件ID定义
local Event = event;

-- socket广播消息定义
Event.SOCKET_EVENT_CONNECT_BEGIN = event.getUniqueID(); -- 开始连接socket
Event.SOCKET_EVENT_CONNECT_COMPLETE = event.getUniqueID(); -- socket连接成功
Event.SOCKET_EVENT_CONNECT_FAILED = event.getUniqueID(); -- socket连接失败
Event.SOCKET_EVENT_CONNECT_TIMEOUT = event.getUniqueID(); -- socket连接超时
Event.SOCKET_EVENT_CONNECT_ERROR = event.getUniqueID(); -- socket连接，参数错误
Event.SOCKET_EVENT_CLOSED = event.getUniqueID(); -- 关闭socket
Event.SOCKET_EVENT_RECV = event.getUniqueID(); -- 收到socket消息
Event.SOCKET_EVENT_SEND = event.getUniqueID(); -- 发送socket消息



-- ------------------------------ 登录 start -------------------------------------------------
-- Event.HALL_LOGIN_SUCCESSED 								= event.getUniqueID(); -- 大厅登录成功
-- Event.HALL_LOGIN_FAILED 								= event.getUniqueID(); -- 大厅登录失败
-- Event.HALL_LOGIN_STOP 									= event.getUniqueID(); -- 登录中断
-- Event.HALL_LOGIN_SHOW_GUEST_VIEW 						= event.getUniqueID(); -- 游客登录界面
-- Event.HALL_LOGIN_SHOW_PHONE_VIEW 						= event.getUniqueID(); -- 手机号登录界面
-- Event.HALL_LOGIN_SHOW_WECHAT_VIEW 						= event.getUniqueID(); -- 微信登录界面
-- Event.HALL_LOGIN_SHOW_PHONE_RESET_PWD_VIEW 				= event.getUniqueID(); -- 手机号密码修改
-- Event.HALL_LOGIN_AUTO 									= event.getUniqueID(); -- 自动登录
-- Event.HALL_LOGIN_DATA_LOGIN_THIRD_PARTY_RESPONSE 		= event.getUniqueID(); -- 第三方登录
-- Event.HALL_LOGIN_DATA_BIND_THIRD_PARTY_RESPONSE 		= event.getUniqueID(); -- 第三方绑定

-- -- 获取验证码
-- Event.HALL_LOGIN_DATA_GET_PHONE_CAPTCHA_RESPONSE 		= event.getUniqueID();
-- Event.HALL_LOGIN_DATA_GET_EMAIL_CAPTCHA_RESPONSE 		= event.getUniqueID();
-- Event.HALL_LOGIN_DATA_GET_VOICE_CAPTCHA_RESPONSE 		= event.getUniqueID();

-- Event.HALL_LOGIN_PHONE_RESET_PWD_REQUEST 				= event.getUniqueID(); -- 手机号密码重置
-- Event.HALL_LOGIN_PHONE_RESET_PWD_RESPONSE 				= event.getUniqueID(); -- 手机号密码重置
-- Event.HALL_LOGIN_EXIT 									= event.getUniqueID(); -- 退出
-- ------------------------------ 登录 end -------------------------------------------------

-- ------------------------------ 弹框 start -------------------------------------------------
-- Event.HALL_DIALOG_PUSH 									= event.getUniqueID();
-- Event.HALL_DIALOG_POP 									= event.getUniqueID();
-- Event.HALL_DIALOG_BACK_ENABLE 							= event.getUniqueID();
-- Event.HALL_DIALOG_SHOW_DEFAULT 							= event.getUniqueID();
-- Event.HALL_DIALOG_SHOW_DEFAULT2 						= event.getUniqueID();
-- Event.HALL_DIALOG_SHOW_DEFAULT3 						= event.getUniqueID();
-- Event.HALL_DIALOG_SHOW_DEFAULT3Close 					= event.getUniqueID();
-- Event.HALL_DIALOG_REMOVE 								= event.getUniqueID();
-- Event.HALL_DIALOG_EXIT 									= event.getUniqueID();
-- Event.HALL_DIALOG_BROADCAST_ENTER 						= event.getUniqueID();
-- Event.HALL_DIALOG_BROADCAST_EXIT 						= event.getUniqueID();
-- Event.HALL_DIALOG_BROADCAST_REMOVE 						= event.getUniqueID();
-- ------------------------------ 弹框 end -------------------------------------------------

-- ------------------------------ 绑定 start -------------------------------------------------
-- Event.HALL_BIND_SUCCESSED 								= event.getUniqueID(); -- 绑定成功
-- Event.HALL_BIND_FAILED 									= event.getUniqueID(); -- 绑定失败

-- Event.HALL_BIND_SHOW_BIND_VIEW 							= event.getUniqueID(); -- 绑定界面
-- Event.HALL_CANCLE_BIND 									= event.getUniqueID(); --取消绑定
-- ------------------------------ 绑定 end -------------------------------------------------

-- ------------------------------ 天梯 start -------------------------------------------------
-- Event.AWARD_GET_AWARD_LIST								= event.getUniqueID(); -- 查看所有奖励
-- Event.SEASON_GET_SEASON_INFO							= event.getUniqueID(); -- 查看赛季总结
-- ------------------------------ 天梯 end -------------------------------------------------

-- ------------------------------ native start -------------------------------------------------
-- Event.NATIVE_CALLBACK 									= event.getUniqueID(); --原生调用lua的回调
-- Event.NATIVE_OPENSHAREAPP 								= event.getUniqueID(); --openWeiXin的回调
-- Event.NATIVE_WECHAT_SHARE_RESULT 						= event.getUniqueID(); -- 微信分享结果回调
-- Event.NATIVE_PAY_RESULT 								= event.getUniqueID(); -- sdk支付结果回调
-- Event.NATIVE_LOGIN_RESULT 								= event.getUniqueID(); -- sdk登陆结果回调
-- Event.NATIVE_IS_SWITCH_ACCOUNT 							= event.getUniqueID(); -- sdk是否支持切换账号结果回调
-- Event.NATIVE_SWITCH_ACCOUNT_RESULT 						= event.getUniqueID(); -- sdk切换账号结果回调
-- Event.NATIVE_IS_LOGOUT_ACCOUNT 							= event.getUniqueID(); -- sdk是否支持登出账号结果回调
-- Event.NATIVE_LOGOUT_ACCOUNT_RESULT 						= event.getUniqueID(); -- sdk登出账号结果回调
-- Event.NATIVE_SPECIAL_METHOD 							= event.getUniqueID(); -- 调用GOD提供的特殊方法结果回调
-- Event.NATIVE_GET_PUSHTOKEN 								= event.getUniqueID(); -- 获取推送的token结果回调
-- ------------------------------ native start -------------------------------------------------

-- ------------------------------ socket start -------------------------------------------------

-- Event.SOCKET_IM_CONNECT_SUCCESS 						= event.getUniqueID(); -- IM的socket连接成功
-- Event.SOCKET_IM_CONNECT_FAILED 							= event.getUniqueID(); -- IM的socket连接失败
-- Event.SOCKET_IM_CLOSED 									= event.getUniqueID(); -- IM的socket关闭
-- Event.SOCKET_MULTI_DEVICELOGIN 							= event.getUniqueID(); -- 异地登陆
-- Event.SOCKET_KICKOUT 									= event.getUniqueID(); -- 踢除用户;大厅踢人/在后台管理页面踢人
-- Event.SOCKET_HALL_LOGIN_SUCCESS 						= event.getUniqueID(); -- 大厅登陆成功
-- Event.SOCKET_RELOGIN 									= event.getUniqueID(); -- socket异常，需要重新登录
-- Event.SOCKET_SERVER_ERROR_BUS 							= event.getUniqueID(); -- socket异常，新的cdn也无法连接
-- Event.SOCKET_SERVER_ERROR_IM 							= event.getUniqueID();  -- IM,socket异常，新的cdn也无法连接
-- Event.SOCKET_NETWORK_INVALID 							= event.getUniqueID();  -- 没有网络连接

-- ------------------------------ socket end -------------------------------------------------

return Event;

