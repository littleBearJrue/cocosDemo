
--require("BabeEngine/core/object")


local Delegate = class("Delegate")



function Delegate:ctor(id)
    self.m_nEventId     =  id
    self.m_funcs        =  {}
end


function Delegate:dtor()
   self.m_nEventId     =  nil

   for k,_ in pairs(self.m_funcs) do
      self.m_funcs[k] = nil
   end
   self.m_funcs = nil
end


function Delegate:addFunc(func,argc,nPriority)
    local f = { }
    f.m_func = func
    f.m_argc = argc
    f.m_nPriority = nPriority

    local index = 0
    local isFlag = false
    for k,v in pairs(self.m_funcs) do
        index = index + 1
        if v.m_nPriority <= nPriority then
            isFlag = true
            break
        end
    end

    if isFlag == false then
        table.insert(self.m_funcs,f)
    else
        table.insert(self.m_funcs,index,f)
    end
end


function Delegate:removeFunc(func,argc)
    if not self.m_running  then
        for k,v in pairs(self.m_funcs) do
            if v.m_func == func and v.m_argc == argc then
             table.remove(self.m_funcs,k)
                break
            end
        end
    else
        if isTableNilOrEmpty(self.m_removeFuncList) then
            self.m_removeFuncList = {}
        end

        local f = { }
        f.m_func = func
        f.m_argc = argc
        f.m_nPriority = nPriority
        table.insert(self.m_removeFuncList,f)
    end
end


function Delegate:run(...)

    self.m_running = true
    for k,v in pairs(self.m_funcs) do
        local ret = v.m_func(v.m_argc,...)
        if ret then
            break
        end
    end
    self.m_running = false

    --reomve
    if not isTableNilOrEmpty(self.m_removeFuncList) then
        for k,v in pairs(self.m_removeFuncList) do
           self:removeFunc(v.m_func,v.m_argc)
        end
        self.m_removeFuncList = nil
    end

end



return Delegate
