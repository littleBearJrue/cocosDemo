--[[
 -- @Author: Jrue 
 -- @Date: 2018-10-18 10:34:31 
 -- @Last Modified by   JrueZhu
 -- @Last Modified time 2018-10-31 10:21:32
 --]]

local _M = {}

_M.showList = {
    "HomeScene",
    "PlayScene",
    "SingleCardScene",
   --  "PokerScene",
    "PokerRoomScene",
    "SSZViewScene",
}

_M.HomeScene = import(".HomeScene");
_M.PlayScene = import(".PlayScene");
_M.SingleCardScene = import(".SingleCardScene");
-- _M.PokerScene = import(".PokerScene");
_M.PokerRoomScene = import(".PokerRoomScene");
_M.SSZViewScene = import(".ssz.SSZViewScene");

return _M
