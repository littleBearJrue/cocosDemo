-- HintManager.lua
cc.exports.HintManager = class()


function HintManager.getInstance()
  if not HintManager.s_instance then
    HintManager.s_instance = HintManager.new()
  end
  return HintManager.s_instance
end

function HintManager.ctor(self)
	self.m_queue = {}
	self.m_size = 0
	self.m_preTime = 0
    
    self.m_scheduler = cc.Director:getInstance():getScheduler()
    self:startExcuteLoop()
end


function HintManager.dtor(self)
	if self.m_loopHandler then
		self.m_loopHandler:cancel()
	end
end



function HintManager.addData(self,data,duration)

	if data==nil or data=="" then return end
	local element = {m_data=data,m_duration=duration or 0}
	self:enterQueue(element)
end

function HintManager.addDataWithDetaTime(self,data,duration)
	local curTime = os.time()
	if curTime - self.m_preTime > 3 then
		self.m_preTime = curTime
		self:addData(data,duration)
	end
	
end


function HintManager.enterQueue(self,element)
	table.insert(self.m_queue,element)
	self.m_size = self.m_size + 1
end

function HintManager.popFront(self)
	local ret =nil
	for k,v in pairs(self.m_queue) do
		ret = table.remove(self.m_queue,k)
		self.m_size = self.m_size - 1
		break
	end
	return ret
end

function HintManager.isEmpty(self)
	if self:getSize() == 0 then
		return true
	else
		return false	
	end
end

function HintManager.getSize(self)
	return self.m_size
end

function HintManager.excuteNextHint(self)
	local value = self:popFront()
	if value then
		--TPNetSys:onEvent(value.m_cmd,value.m_data)
	end
end

function HintManager.excuteDelayHint(self,data)
	if data.m_duration > 0 then

		local _excuteQueue =function(dt)
			self:excuteLoop(dt)
		end

		self.m_curAction  = cc.DelayTime:create(data.m_duration)
		self.m_actionFunc = cc.CallFunc:create(_excuteQueue)
		self.m_sequenceAction = cc.Sequence:create(self.m_curAction,self.m_actionFunc)
			
		self:runAction(self.m_sequenceAction)
	end
end


function HintManager.excuteQueue(self)
	local value = self:popFront()
	if value then
		--TPNetSys:onEvent(value.m_cmd,value.m_data)
		self:excuteDelayHint(value)
	end
end

function HintManager.startExcuteLoop(self)
    if self.m_loopHandler then
        self.m_scheduler:unscheduleScriptEntry(self.m_loopHandler)
    end

    local _excuteLoop =function(dt)
        self:excuteLoop(dt)
    end
	self.m_loopHandler = self.m_scheduler:scheduleScriptFunc(_excuteLoop, 0.05, false) 

end

function HintManager.excuteLoop(self)
	if not LayerManager.getInstance():isShowing(LayerIds.POPUP_LAYER_TOP_HINT) then
		local value = self:popFront()
		if value then
			ViewSys:onEvent(ViewEvent.EVENT_LAYER_POPUP_COMMON_TOP_HINT,value.m_data)
		end
	end
end

return HintManager