local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local handle = {}
local db = nil

handle.login = function (data)
    if type(data) ~= "table" or 
        type(data.name) ~= "string" or #data.name == 0 or
        type(data.pwd) ~= "string" or #data.pwd == 0 then 
        skynet.ret(skynet.pack(2, "name of pwd is nil."))
        return
    end
    local sql = string.format("select * from person where name = '%s' and password = '%s';", 
        data.name, data.pwd)
    local res = db:query(sql)
    print( dump( res ) )
    -- skynet.ret(skynet.pack(#res > 0))
    if #res > 0 then
        skynet.ret(skynet.pack(0, "", res[1]))
    else
        skynet.ret(skynet.pack(1, "invalid name or pwd."))
    end
end

handle.register = function (data)
    if type(data) ~= "table" or
        type(data.name) ~= "string" or #data.name == 0 or
        type(data.pwd) ~= "string" or #data.pwd == 0 then 
        skynet.ret(skynet.pack(1, "name and pwd can't null."))
        return
    end
    local sql = string.format("select name from person where name = '%s';", 
        data.name, data.pwd)
    local res = db:query(sql)
    -- print( dump( res ) )
    if (#res > 0) then 
        skynet.ret(skynet.pack(2, "Curent name has registerd."))
        return 
    end
    -- sql = string.format("insert into person (name, password) values('%s', '%s');",
    --     data.name, data.pwd);

    local stmt_insert = db:prepare("insert into person (name, password, nickname) values(?,?,?)")
    local r = db:execute(stmt_insert, data.name, data.pwd, "中文")
    print( dump( r ) )
    if r.affected_rows > 0 then
        local sql = string.format("select * from person where id = '%s';", 
            r.insert_id)
        local res = db:query(sql)
        print( dump( res ) )
        skynet.ret(skynet.pack(0, "", res[1]))
    else
        skynet.ret(skynet.pack(3, "create account fail."))
    end
end

handle.update_info = function (data, info)
    print("mysql handle.update_info.")
    local sql = string.format("update person set %s='%s' where id=%d", 
        data.key, data.value, info.id)
    local res = db:query(sql)
    print( dump( res ) )
    if res.badresult then
        skynet.ret(skynet.pack(1, res.err))
    else
        skynet.ret(skynet.pack(0, ""))
    end
end

local function init_tables()
    -- create device table
    local res = db:query([[
        create table if not exists `device` (
			`udid` varchar(100) COLLATE utf8mb4_bin UNIQUE NOT NULL,
            `device_product` varchar(45) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            `device_version` varchar(45) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            PRIMARY KEY (`udid`),
			UNIQUE KEY `id_UNIQUE` (`udid`)
        )ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
    ]])
    print(dump(res))

    -- create apple acount table
    res = db:query([[
        create table if not exists `apple_account` (
            `apple_id` varchar(100) COLLATE utf8mb4_bin UNIQUE NOT NULL,
            `pwd` varchar(100) COLLATE utf8mb4_bin NOT NULL,
            `app_name` varchar(100) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            `fastlane_path` varchar(512) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            `download_path` varchar(512) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            PRIMARY KEY (`apple_id`),
            UNIQUE KEY `id_UNIQUE` (`apple_id`)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
    ]])
    print(dump(res))

    -- create apple app table
    res = db:query([[
        create table if not exists `app` (
			`udid` varchar(100) COLLATE utf8mb4_bin NOT NULL,
            `apple_id` varchar(100) COLLATE utf8mb4_bin NOT NULL,
            `download_path` varchar(512) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            PRIMARY KEY (`udid`, `apple_id`)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
    ]])
    print(dump(res))
end

skynet.start(function()

	local function on_connect(db)
		-- db:query("set charset utf8");
	end
	db = mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="ipamaker",
		user="root",
		password="111111",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
        print("failed to connect")
        return
	end
	print("success to connect to mysql server")

    init_tables()
    
    skynet.dispatch("lua", function(_, __, cmd, data, info)
        if type(handle[cmd]) == 'function' then
            handle[cmd](data, info)
            skynet.exit()
            return
        end
        skynet.ret(skynet.pack(-1, "invalid cmd: " .. cmd))
        skynet.exit()
    end)
end)