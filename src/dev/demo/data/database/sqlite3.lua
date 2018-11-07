local _M = {}
local sqlite3 = require("sqlite3")
if not sqlite3 then
    print("不支持sqlite3")
    return nil
end

print("sqlite3版本号 ",sqlite3.version())
print("Lsqlite版本号 ",sqlite3.lversion())

--基础函数
local function createDB(path,fullPath,del)
    if fullPath == nil or fullPath == false then
        path = device.writablePath .. path
    end
    if del == nil then
        del = false
    end
    if del then
        local isExist = cc.FileUtils:getInstance():isFileExist(path)
        if isExist then
            cc.FileUtils:getInstance():removeFile(path)
        end
    end
    
    return sqlite3.open(path)
end

local function closeDB(db)
    if db then
        return db:close() == sqlite3.OK
    else
        print(debug.traceback())
        print "db is nil"
        return false
    end
    
end

local function exec(db,sql)
    if db then
        return db:exec(sql)
    else
        print(debug.traceback())
        print "db is nil"
        return nil
    end
end


-- path 数据库名称，
-- fullpath 是否是觉得路径
-- del是否删除旧库
--如果是本机预先定义的库，打包到APP中，则需要复制到可读写路径，
--否则，不能使用数据库打开（打包生成的文件下面路径只有可读权限，无法使用数据库打开）
function _M.openDatabase(path,fullPath,del)
    return createDB(path,fullPath,del)
end

function _M.exec(db,sql)
    return exec(db,sql)
end

function _M.closeDB(db)
    return closeDB(db)
end

--相关API参考http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
-- function _M:complete(sql)
--     return sqlite3.complete(sql)
-- end

--测试基本输入输出
local function testSimple1()
    --建库
    local db = _M.openDatabase("simple1.db")

    --建表
    local sql = [[
        CREATE TABLE IF NOT EXISTS simpleTable1 (id INTEGER PRIMARY KEY AUTOINCREMENT,num1,num2);
    ]]
    print(sql)
    print(_M.exec(db,sql))

    --插入数据
    sql = [[
        INSERT INTO simpleTable1 VALUES(NULL,1,11);
        INSERT INTO simpleTable1 VALUES(NULL,2,22);
        INSERT INTO simpleTable1 VALUES(NULL,3,33);
    ]]
    print(sql)
    print(_M.exec(db,sql))

    --显示数据
    for row in db:nrows('SELECT * FROM simpleTable1') do
        dump(row) 
    end


    for row in db:nrows('SELECT * FROM simpleTable1 where num1 = 1') do
        dump(row) 
    end
    for row in db:nrows('SELECT * FROM simpleTable1 where num1 = 1 or num1 = 2') do
        dump(row) 
    end
    for row in db:nrows('SELECT * FROM simpleTable1 where num1 = 1 and num1 = 2') do
        dump(row) 
    end

    print(_M.closeDB(db))
end

--创建列回调test
local function testSimple2()
    local db = _M.openDatabase("simple1.db")
    db:exec[[
        CREATE TABLE numbers(name,score);
        INSERT INTO numbers VALUES("a",11);
        INSERT INTO numbers VALUES("b",22);
        INSERT INTO numbers VALUES("c",33);
    ]]
    local sum =0
    local function oneRow(context,num)  -- add one column in all rows
        sum = sum + num
    end
    local function afterLast(context)   -- return sum after last row has been processed
        context:result_number(sum)
        sum = 0
    end
    db:create_aggregate("do_the_sums",1,oneRow,afterLast)
    for sum in db:urows('SELECT do_the_sums(score) FROM numbers') do 
        print("Sum of col 2:",sum) 
    end

    local current = 1
    local function oneRow2(context,name)  -- add one column in all rows
        print(current,name)
        current = current + 1
    end
    local function afterLast2(context)   -- return sum after last row has been processed
        context:result_text("result anything you want to")
        current = 1
    end
    db:create_aggregate("do_the_sums2",1,oneRow2,afterLast2)
    for sum in db:urows('SELECT do_the_sums2(name) FROM numbers') do 
        print("Sum of col 1:",sum) 
    end

    print(_M.closeDB(db))
end


local function testSimple()
    testSimple1()
    testSimple2()
end
-- testSimple()



return _M