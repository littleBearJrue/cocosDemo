local _M = {}

_M.showList = {
    "TestScene",
    "ImageViewTest",
    "CheckBoxTest",
    "LayoutTest",
    "LoadingAndProgressTest",
    "MenuItemTest",
    "SilderTest",
    "ScheduleTest",
    "ScrollViewTest",
    "PageViewTest",
    "TableViewTest",
    "demoScene",
    "sszScene",
}

_M.TestScene = import(".TestScene")
_M.ImageViewTest = import(".ImageViewTest")
_M.CheckBoxTest = import(".CheckBoxTest")
_M.LayoutTest = import(".LayoutTest")
_M.LoadingAndProgressTest = import(".LoadingAndProgressTest")
_M.MenuItemTest = import(".MenuItemTest")
_M.SilderTest = import(".SilderTest")
_M.ScheduleTest = import(".ScheduleTest")
_M.ScrollViewTest = import(".ScrollViewTest")
_M.PageViewTest = import(".PageViewTest")
_M.TableViewTest = import(".TableViewTest")
_M.demoScene = import(".chipTest.demoScene")
_M.sszScene = import(".changePokerTest.sszScene")

return _M
