require "json"
-- local Sqlite3Utils = require("app.demo.JasonLiu.utils.Sqlite3Utils")

local function createLabeltextHttp()
    local label = cc.Label:createWithSystemFont("Hello World", "Arial", 14):move(display.cx, display.cy + 120)

    local xhr = cc.XMLHttpRequest:new() --创建一个请求  
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --设置返回数据格式为字符串  
    local req = "http://t.weather.sojson.com/api/weather/city/101280601" --请求地址  
    xhr:open("GET", req) --设置请求方式  GET     或者  POST  
    -- local req = "https://poll.kuaidi100.com/poll/query.do"
    -- xhr:open("POST", req) 
    -- local params = "customer=10000&sign=111&param=222"
    
    local function onReadyStateChange()  --请求响应函数  
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then --请求状态已完并且请求已成功  
                local statusString = "Http Status Code:"..xhr.statusText  
                -- print("请求返回状态码"..statusString)  
                local data = json.decode(xhr.response) --获得返回的内容  
                -- dump(data, "返回的数据")   
                label:setString(data.cityInfo.city .."  ".. data.data.forecast[1].date .. "  " .. data.data.forecast[1].type .. "  " .. data.data.forecast[1].low .. "  " .. data.data.forecast[1].high .. "\n" .. 
                            data.data.forecast[1].fx .. "  " .. data.data.forecast[1].notice)
        end  
    end  
    xhr:registerScriptHandler(onReadyStateChange) --注册请求响应函数  
    xhr:send(params) --最后发送请求  

    return label
end

local function createLabelTestFile()
    local label = cc.Label:createWithSystemFont("Hello World", "Arial", 14):move(display.cx, display.cy + 80)

    -- 获取可写目录
    local docpath = cc.FileUtils:getInstance():getWritablePath().."gameData.txt"
    dump(docpath, "docpath")
    -- 判断文件是否存在
    local isexit = cc.FileUtils:getInstance():isFileExist(docpath)
    dump(isexit, "isexit")

    local str
    if not isexit then
        str = "{\"name\":\"player\",\"id\":6,\"level\":0}"
    else
        -- 读取文件数据
        local fileDate = cc.FileUtils:getInstance():getStringFromFile(docpath)
        dump(fileDate, "file data")
        local data = json.decode(fileDate)
        data.level = data.level + 1
        str = json.encode(data)

        label:setString("FileUtils     name：" .. data.name .. "   id：" .. data.id .. "   level：" .. data.level)
    end
    -- 写入数据
    local f = assert(io.open(docpath, 'w'))
    f:write(str)
    f:close()

    return label
end

local function createLabelTestUserDefault()
    local label = cc.Label:createWithSystemFont("Hello World", "Arial", 14):move(display.cx, display.cy + 40)

    cc.UserDefault:getInstance():setIntegerForKey("gameTime", 100)
    local gameTime = cc.UserDefault:getInstance():getIntegerForKey("gameTime")
    cc.UserDefault:getInstance():setBoolForKey("isOpenVoice", true)    
    local isOpenVoice = cc.UserDefault:getInstance():getBoolForKey("isOpenVoice")
    cc.UserDefault:getInstance():setStringForKey("remark", "cocos")    
    local remark = cc.UserDefault:getInstance():getStringForKey("remark")
    cc.UserDefault:getInstance():setFloatForKey("volume", 5.8)    
    local volume = cc.UserDefault:getInstance():getFloatForKey("volume")
    cc.UserDefault:getInstance():setDoubleForKey("volume2", 5.8)    
    local volume2 = cc.UserDefault:getInstance():getDoubleForKey("volume2")

    label:setString("UserDefault     gameTime：" .. gameTime .. "   isOpenVoice：" .. (isOpenVoice and "1" or "2") .. "   remark：" .. remark .. "\nvolume：" .. volume .. "   volume2：" .. volume2)

    return label
end

-- local function createLableTestSqlite()
--     local label = cc.Label:createWithSystemFont("Hello World", "Arial", 14):move(display.cx, display.cy - 60)

--     Sqlite3Utils:getDBVersion()
--     Sqlite3Utils:openDB()
--     Sqlite3Utils:insert("10010, 10010, \"test\"")
--     Sqlite3Utils:update()
--     Sqlite3Utils:delete()
--     local str = Sqlite3Utils:select()

--     label:setString(str)
--     return label
-- end

local function main()
    local scene = cc.Scene:create()

    scene:addChild(createLabeltextHttp())
    scene:addChild(createLabelTestFile())
    scene:addChild(createLabelTestUserDefault())
    -- scene:addChild(createLableTestSqlite())
    scene:addChild(CreateBackMenuItem())

    return scene
end

return main