
cc.exports.Scene = class("Scene",cc.Scene)

Scene.XG_SCENE_WELCOME = 1
Scene.XG_SCENE_STARTUP_LOADING = 2
Scene.XG_SCENE_UPDATE = 3
Scene.XG_SCENE_LOGIN = 4




function Scene:ctor()
     self:onCreate()
end

function Scene:dtor()
end

return Scene