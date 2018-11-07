local _M = {}

_M.showList = {
    "GameScene1",
    "GameScene2",
    "GameScene3",
    "GameScene4",
    -- "GameScene5",
    "GameScene6",
    -- "GameScene7",
    "GameScene8",
    "GameScene9",
}

_M.GameScene1 = import(".scene.GameScene1")
_M.GameScene2 = import(".scene.GameScene2")
_M.GameScene3 = import(".scene.GameScene3")
_M.GameScene4 = import(".scene.GameScene4")
-- _M.GameScene5 = import(".scene.GameScene5")
_M.GameScene6 = import(".scene.GameScene6")
-- _M.GameScene7 = import(".scene.GameScene7")
_M.GameScene8 = import(".scene.GameScene8")
_M.GameScene9 = import(".scene.GameScene9")

return _M
