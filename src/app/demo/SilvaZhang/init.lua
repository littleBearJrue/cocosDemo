local _M = {}

_M.showList = {
    "GameTest",
    "ScreenTest",
    "CardTest",
    "ClockTest",
    "CardLayerTest",
    "SwapCardTest",
}

_M.GameTest = import(".GameTest")
_M.ScreenTest = import(".ScreenTest")
_M.CardTest = import(".card.CardTest")
_M.ClockTest = import(".clock.ClockTest")
_M.CardLayerTest = import(".cardLayer.CardLayerTest")
_M.SwapCardTest = import(".swap.SwapTest")

return _M
