local _M = {}

_M.showList = {
    "MVC",
    "Behavior",
    "PlayCard",
    "NewMvcScene",
    
}

_M.MVC = import(".TestScene")

_M.Behavior = import(".BehaviorScene")
_M.Observer = import(".ObserverScene")
_M.NewMvcScene = import(".NewMvcScene")
_M.PlayCard = require("app.demo.yangshuai.PlayCard.PlayCardScene")



return _M
