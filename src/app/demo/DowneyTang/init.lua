local _M = {}

_M.showList = {
    "SceneTest",
    -- "Createclock",
    "EventTest",
    -- "MyTest",
    -- "UseChip",
    "BetTest",
    "SszTest",
}

_M.SceneTest = import(".SceneTest")
-- _M.Createclock = import(".Createclock")
_M.EventTest = import(".EventTest")
-- _M.MyTest = import(".MyTest")
-- _M.UseChip = import(".UseChip")
_M.BetTest = import(".BetTest")
_M.SszTest = import(".CapsaSusun.SszTest")

return _M
