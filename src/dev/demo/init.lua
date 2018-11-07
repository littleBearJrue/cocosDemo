require "dev.demo.event.LogicEvent"
require "dev.demo.event.ViewEvent"

require "dev.demo.include.Const"

require "dev.demo.data.DBManager"

cc.exports.NetManager = require "dev.demo.net.NetManager"

require "dev.demo.net.pbc.protobuf"


local SceneManager = require "dev.demo.scenes.SceneManager"
SceneManager.getInstance()

cc.exports.GameServer = require "dev.demo.net.GameServer"
cc.exports.GameProtocol = require "dev.demo.net.GameProtocol"

if XG_USE_FAKE_SERVER then
    cc.exports.XGFakeServer = require "dev.demo.net.FakeServer.XGFakeServer"
end