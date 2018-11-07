
local _M = {}
local boyaaPath = "packages.boyaa"

_M.mvc = {
	BoyaaCtr = require(boyaaPath..".mvc.BoyaaCtr"),
	BoyaaView = require(boyaaPath..".mvc.BoyaaView"),
	BoyaaLayout = require(boyaaPath..".mvc.BoyaaLayout"),
	BoyaaWidgetExtend = require(boyaaPath..".mvc.BoyaaWidgetExtend"),
}


_M.mvp = {
	BoyaaLayoutWidget = require(boyaaPath..".mvp.BoyaaLayoutWidget"),
	BoyaaPresenter = require(boyaaPath..".mvp.BoyaaPresenter"),
	BoyaaViewWidget = require(boyaaPath..".mvp.BoyaaViewWidget"),
	BoyaaWidgetExtend = require(boyaaPath..".mvp.BoyaaWidgetExtend"),
}


_M.data = {
	DataBase = require(boyaaPath..".data.DataBase"),
}

_M.behavior = {
	BehaviorBase = require(boyaaPath..".behavior.BehaviorBase"),
	BehaviorFactory = require(boyaaPath..".behavior.BehaviorFactory"),
	BehaviorExtend = require(boyaaPath..".behavior.BehaviorExtend"),
	BehaviorMap = require(boyaaPath..".behavior.BehaviorMap"),
}


return _M
