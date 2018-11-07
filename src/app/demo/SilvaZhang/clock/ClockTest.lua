local ClockView = import(".ClockView")
--主函数
local ClockTest = {}
function ClockTest:main( ... )
	--创建场景
	local scene = cc.Scene:create()
	self.scene = scene

	local function onNodeEvent(event)
		if event == "exit" then
			self.clockView:exit()
		elseif event == "enter" then
			scene:addChild(CreateBackMenuItem())
			local clockView = ClockView:create()
			self.clockView = clockView
			clockView:setPosition(100,100)
			scene:addChild(clockView)
		end
	end
	scene:registerScriptHandler(onNodeEvent)
	return scene
end

return handler(ClockTest, ClockTest.main)