local sqlite3 = require("lsqlite3")
local Sqlite3Utils = {}
local _db

-- 获取版本号
Sqlite3Utils.getDBVersion = function ()
    dump(sqlite3.version(),"SQLite DB version  ")
end

Sqlite3Utils.openDB = function ()
    local dbFilePath = device.writablePath..'test.db'
    local isExist = cc.FileUtils:getInstance():isFileExist(dbFilePath)

    _db = sqlite3.open(dbFilePath)
    if isExist then
        dump('SQLite DB File is exist')
    else
        dump('SQLite DB File is not exist, created it')
        -- 初始化表结构
        Sqlite3Utils:initDB()
    end
end

Sqlite3Utils.initDB = function ()
    -- Demo表DDL语句
    local t_demo_sql =
    [=[
        CREATE TABLE test_table(id, score, name);
        INSERT INTO test_table VALUES(1, 1000, "ABC");
        INSERT INTO test_table VALUES(2, 28, "DEF");
        INSERT INTO test_table VALUES(3, 13, "UVW");
        INSERT INTO test_table VALUES(4, 48, "XYZ");
        SELECT * FROM test_table;
    ]=]

    local showrow = function(ud, cols, values, names)
        assert(ud == 't_demo_create')

        dump(string.format('SQLite %s rows %s', ud, table.concat( values, "-")))

        return sqlite3.OK
    end

    _db:exec(t_demo_sql, showrow, 't_demo_create')
end

Sqlite3Utils.insert = function (o, tableParas)
    local t_demo_sql = " INSERT INTO test_table VALUES(".. tableParas .."); "

    local ret = _db:exec(t_demo_sql)
    if ret ~= sqlite3.OK then
        dump('error')
    else
        dump('insert complete')
    end
end

Sqlite3Utils.update = function ()
    local t_demo_sql = " UPDATE test_table SET name = 'Hello World !' WHERE id = 10010; "

    local ret = _db:exec(t_demo_sql)
    if ret ~= sqlite3.OK then
        dump('error')
    else
        dump('update complete')
    end
end

Sqlite3Utils.delete = function ()
    local t_demo_sql = " DELETE FROM test_table WHERE id = 10010; "

    local ret = _db:exec(t_demo_sql)
    if ret ~= sqlite3.OK then
        dump('error')
    else
        dump('delete complete')
    end
end

Sqlite3Utils.select = function ()
    local t_demo_sql = " SELECT * FROM test_table"
    local str = ""

    local showrow = function(ud, cols, values, names)
        assert(ud == 't_demo_select')

        dump(values, 'SQLite Select')
        for i = 1, cols do
            str = str .. names[i] .. "：" .. values[i] .. "   "
        end
        str = str .. "\n"

        return sqlite3.OK 
    end

    local ret = _db:exec(t_demo_sql, showrow, 't_demo_select')
    if ret ~= sqlite3.OK then
        dump('error')
    end

    return str
end

return Sqlite3Utils