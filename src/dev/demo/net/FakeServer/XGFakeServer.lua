require "dev.demo.net.FakeServer.XGFakeDBStorage"


 local XGFakeServer = class("XGFakerServer")

 function XGFakeServer.getInstance()
	if not XGFakeServer.s_instance then
		XGFakeServer.s_instance = XGFakeServer:create()
	end
	return XGFakeServer.s_instance
end

function XGFakeServer:ctor()
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_LOGIN"),self.onCLI_CMD_LOGIN,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_RETURN"),self.onCLI_CMD_RETURN,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_SITDOWN"),self.onCLI_CMD_SITDOWN,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_STAND"),self.onCLI_CMD_STAND,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_BET"),self.onCLI_CMD_REQ_BET,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_AUTOSIT"),self.onCLI_CMD_REQ_AUTOSIT,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_CANCEL_AUTOSIT"),self.onCLI_CMD_REQ_CANCEL_AUTOSIT,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_SEND_MSG"),self.onCLI_CMD_REQ_SEND_MSG,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_SEND_EMOTION"),self.onCLI_CMD_REQ_SEND_EMOTION,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_SHOW_HAND_CARD"),self.onCLI_CMD_REQ_SHOW_HAND_CARD,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_SEND_CHIPS"),self.onCLI_CMD_REQ_SEND_CHIPS,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_SEND_GIFT"),self.onCLI_CMD_SEND_GIFT,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_SEND_HD"),self.onCLI_CMD_SEND_HD,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_CHANGE_GIFT"),self.onCLI_CMD_CHANGE_GIFT,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_ADD_FRIEND"),self.onCLI_CMD_ADD_FRIEND,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_HEART_BEAT"),self.onCLI_CMD_HEART_BEAT,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_NEXT_STAND"),self.onCLI_CMD_NEXT_STAND,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_BACK_SEAT"),self.onCLI_CMD_BACK_SEAT,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_SEND_DEALER_MONEY"),self.onCLI_CMD_SEND_DEALER_MONEY,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_BUY_NEXT_LOTTO"),self.onCLI_CMD_BUY_NEXT_LOTTO,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_AUTO_BUY_LOTTO"),self.onCLI_CMD_AUTO_BUY_LOTTO,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_CANCEL_AUTO_BUY_LOTTO"),self.onCLI_CMD_CANCEL_AUTO_BUY_LOTTO,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_DELAY_AUTO_BUY_LOTTO"),self.onCLI_CMD_DELAY_AUTO_BUY_LOTTO,self)
  NetSys:regEventHandler(GameProtocol.getEventType("CLI_CMD_REQ_SEND_MSG_NEW"),self.onCLI_CMD_REQ_SEND_MSG_NEW,self)

end


function XGFakeServer:dtor()
  
  
end


function XGFakeServer:delayExcuteEvent(func,delay)

  local scheduler = cc.Director:getInstance():getScheduler()
  local loopHandler =0
  loopHandler = scheduler:scheduleScriptFunc(function (  )
    scheduler:unscheduleScriptEntry(loopHandler)
    func()
  end,delay, false) 
  return loopHandler
end

function XGFakeServer:httpPost(url,data,obj,onResult,onError)
  local func = function ( )
    
  end
  self:delayExcuteEvent(func,0.05)
end



function XGFakeServer:onCLI_CMD_LOGIN()

  local res = 
  {
    smallBlind = 1;                 --小盲注
    minBuyIn = 2;                 --最小买入
    maxBuyIn = 3;                 --最大买入
   tableName = "test";              --桌子名字
    roomType = 5;         --房间场别
    tableLevel = 6;         --房间级别
    userChips = 7;                 --用户钱数
    betInExpire = 8;         --下注最大时间
    gameStatus = 9;          --游戏状态
    maxSeatCount = 10;          --最大座位数量
    roundCount = 11;              --游戏局数
    dealerSeatId = 12;          --庄家座位
    chipsPotsCount = 13;          --奖池数量
  chipsPots ={
  },
  publicCards ={

  },
 betInSeatId = 1; --目前正在下注的座位

callNeedChips = 17;  --跟注需要钱数
minRaiseChips = 18;  --加注最小钱数
maxRaiseChips = 19;  --加注最大钱数

playerCount = 1;   --玩家数量(坐下)

tableUserData = {
  {
    seatId          = 1;--座位id (lua下标从1开始)
    uid             = 2;    --用户id
    totalChips      = 3; --用户钱数
    exp             = 4;   --用户经验
    vip             = 5;  --VIP标识
    name            = "test";  --用户名
    gender          = "nv";  --性别
    photoUrl        = "url";  --用户图片url
    winRound        = 1;   --用户赢盘数
    loseRound       = 1;   --用户输盘数
    currentPlace    = "we"; --用户所在地
    homeTown        = "t"; --用户家乡
    giftId          = 1;  --用户默认道具
    seatChips       = 14; --座位的钱数
    betInChips      = 15; --座位的总下注数
    operationStatus = 16;  --当前操作类型
  }
},

    handCardFlag = 0; --是否有手牌
    handCard1 = 0; 
    handCard2 = 0; 

   platFlags = {

   };

    tableFlag = 26;
    playerAnte = 27; --该轮下的前注
  }

  --self:delayExcuteEvent()
  NetSys:onEvent(GameServerId.SVR_CMD_LOGIN_SUCC,res)
end

function XGFakeServer:onCLI_CMD_RETURN()
end

function XGFakeServer:onCLI_CMD_SITDOWN()
end

function XGFakeServer:onCLI_CMD_STAND()
end

function XGFakeServer:onCLI_CMD_REQ_BET()
end

function XGFakeServer:onCLI_CMD_REQ_AUTOSIT()
end

function XGFakeServer:onCLI_CMD_REQ_CANCEL_AUTOSIT()
end

function XGFakeServer:onCLI_CMD_REQ_SEND_MSG()
end

function XGFakeServer:onCLI_CMD_REQ_SEND_EMOTION()
end

function XGFakeServer:onCLI_CMD_REQ_SHOW_HAND_CARD()
end

function XGFakeServer:onCLI_CMD_REQ_SEND_CHIPS()
end

function XGFakeServer:onCLI_CMD_SEND_GIFT()
end

function XGFakeServer:onCLI_CMD_SEND_HD()
end

function XGFakeServer:onCLI_CMD_CHANGE_GIFT()
end

function XGFakeServer:onCLI_CMD_ADD_FRIEND()
end

function XGFakeServer:onCLI_CMD_HEART_BEAT()
end

function XGFakeServer:onCLI_CMD_NEXT_STAND()
end

function XGFakeServer:onCLI_CMD_BACK_SEAT()
end

function XGFakeServer:onCLI_CMD_SEND_DEALER_MONEY()
end

function XGFakeServer:onCLI_CMD_BUY_NEXT_LOTTO()
end

function XGFakeServer:onCLI_CMD_AUTO_BUY_LOTTO()
end

function XGFakeServer:onCLI_CMD_CANCEL_AUTO_BUY_LOTTO()
end

function XGFakeServer:onCLI_CMD_DELAY_AUTO_BUY_LOTTO()
end

function XGFakeServer:onCLI_CMD_REQ_SEND_MSG_NEW()
end



return XGFakeServer