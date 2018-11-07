local logicEventId = 10000
local function getLogicIndex()
    logicEventId = logicEventId+1
    return  logicEventId

end

cc.exports.LogicEvent =
{	
    EVENT_ON_BACK_PRESSED= getLogicIndex(),

    EVENT_NET_LOGOUT_COMPLETED = getLogicIndex(),
    EVENT_NET_LAUNCH_VERSION_CHECK = getLogicIndex(),
    EVENT_NET_LAUNCH_LOGIN = getLogicIndex(),
    EVENT_NET_LAUNCH_ENTER_SERVER = getLogicIndex(),

    EVENT_SCENE_ENTER = getLogicIndex(),
	EVENT_SCENE_EXIT = getLogicIndex(),
	EVENT_SCENE_CHANGE = getLogicIndex(),
	EVENT_SCENE_RESUME = getLogicIndex(),
	EVENT_SCENE_PAUSE = getLogicIndex(),
    EVENT_SCENE_TOBERUN = getLogicIndex(),
    
    EVENT_SERVER_CREATE = getLogicIndex(),
    EVENT_SERVER_CLOSE = getLogicIndex(),
    EVENT_SERVER_STATUS = getLogicIndex(),


    EVENT_DOWNLOADER_ON_PROGRESS = getLogicIndex(),
    EVENT_DOWNLOADER_ON_DATA_SUCCESS = getLogicIndex(),
    EVENT_DOWNLOADER_ON_FILE_SUCCESS = getLogicIndex(),
    EVENT_DOWNLOADER_ON_ERROR = getLogicIndex(),

}


cc.exports.XGEventPriority = 
{
    LOWEST = -2,
    LOWER = -1,
    LOW = 0,
    NORMAL = 1,
    HIGH = 2,
    HIGHER = 3,
    HIGHEST = 4,
}
