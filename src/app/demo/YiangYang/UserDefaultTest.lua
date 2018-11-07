
--[[
用户默认配置 存储
]]--
 
local function doTest()
  print("********************** init value ***********************")
  -- set default value
  -- 设置默认值
  cc.UserDefault:getInstance():setStringForKey("string", "Yiang")-- 字符串
  cc.UserDefault:getInstance():setIntegerForKey("integer", 10)-- 整型
  cc.UserDefault:getInstance():setFloatForKey("float", 2.3)--浮点型
  cc.UserDefault:getInstance():setDoubleForKey("double", 2.4)-- 双精度
  cc.UserDefault:getInstance():setBoolForKey("bool", true)-- 布尔型
  -- print value
  -- 打印获取到的值
  -- 根据key获取字符串值
  local ret = cc.UserDefault:getInstance():getStringForKey("string")
  print("string is %s", ret)
  -- 根据key获取双精度值
  local d = cc.UserDefault:getInstance():getDoubleForKey("double")
  print("double is %f", d)
  -- 根据key获取整型值
  local i = cc.UserDefault:getInstance():getIntegerForKey("integer")
  print("integer is %d", i)
  -- 根据key获取浮点数值
  local f = cc.UserDefault:getInstance():getFloatForKey("float")
  print("float is %f", f)
  -- 根据key获取布尔值
  local b = cc.UserDefault:getInstance():getBoolForKey("bool")
  if b == true then
    print("bool is true")
  else
    print("bool is false")
  end
  --cc.UserDefault:getInstance():flush()
  print("********************** after change value ***********************")
  -- change the value
  -- 修改值
  cc.UserDefault:getInstance():setStringForKey("string", "YiangYang")
  cc.UserDefault:getInstance():setIntegerForKey("integer", 11)
  cc.UserDefault:getInstance():setFloatForKey("float", 2.5)
  cc.UserDefault:getInstance():setDoubleForKey("double", 2.6)
  cc.UserDefault:getInstance():setBoolForKey("bool", false)
  -- 刷新写入
  cc.UserDefault:getInstance():flush()
  -- print value
  -- 根据key获取字符串值
  local ret = cc.UserDefault:getInstance():getStringForKey("string")
  print("string is %s", ret)
  -- 根据key获取双精度值
  local d = cc.UserDefault:getInstance():getDoubleForKey("double")
  print("double is %f", d)
  -- 根据key获取整型值
  local i = cc.UserDefault:getInstance():getIntegerForKey("integer")
  print("integer is %d", i)
  -- 根据key获取浮点数值
  local f = cc.UserDefault:getInstance():getFloatForKey("float")
  print("float is %f", f)
  -- 根据key获取布尔值
  local b = cc.UserDefault:getInstance():getBoolForKey("bool")
  if b == true then
    print("bool is true")
  else
    print("bool is false")
  end
end

local function main()
  local ret = cc.Scene:create()  
  local s = cc.Director:getInstance():getWinSize() -- 获取屏幕大小
  local  label = cc.Label:createWithTTF("UserDefaultTest see log", s_arialPath, 28)-- 创建标签
  ret:addChild(label, 0)
  label:setAnchorPoint(cc.p(0.5, 0.5))
  label:setPosition( cc.p(s.width/2, s.height-50) )
  ret:addChild(CreateBackMenuItem())
  doTest()
  return ret
end

return main