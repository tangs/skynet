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

handle.query_device = function (udid)
    if type(udid) ~= "string" or #udid == 0 then 
        return 1, "udid can't null."
    end
    local sql = string.format("select appleacc_name from device where udid = '%s'", 
        udid)
    local res = db:query(sql)
    print(dump(res))
    if (#res == 0) then 
        return 2, "udid has't registered."
    end
    return 0, res[1].appleacc_name
end

handle.register_device = function (appleacc_name, dev_info)
    local udid = dev_info.udid
    local device_product = dev_info.device_product or ""
    local device_version = dev_info.device_version or ""
    if type(udid) ~= "string" or #udid == 0 then 
        return -1, "udid can't null."
    end
    if type(appleacc_name) ~= "string" or #appleacc_name == 0 then 
        return -2, "appleacc_name can't null."
    end

    local stmt_insert = db:prepare("insert into device (udid, device_product, device_version, appleacc_name) values(?,?,?,?)")
    local r = db:execute(stmt_insert, udid, device_product, device_version, appleacc_name)
    print(dump(r))
    if r.affected_rows > 0 then
        return 0, ""
    else
        return -3, string.format("register device fail.udid:%s", udid)
    end
end

handle.query_app = function (appname, udid)
    if type(appname) ~= "string" or #appname == 0 then 
        return -1, "invalid appname param."
    end

    -- local udid = dev_info.udid
    if type(udid) ~= "string" or #udid == 0 then 
        return -2, "udid can't null."
    end

    local res, data = handle.query_device(udid)
    if res ~= 0 then
        return 1, "unregister device."
    end

    local sql = string.format("select download_path from app where udid = '%s' and appname = '%s'", 
        udid, appname)
    local res = db:query(sql)
    print(dump(res))

    if #res == 0 then
        -- need generate app.
        return 2, data
    end
    return 0, res[1].download_path or ""
end

handle.query_udids = function (appleacc_name)
    local sql = string.format("select udid from device where appleacc_name = '%s'", 
    appleacc_name)
    local res = db:query(sql)
    print(dump(res))
    return res
end

local function init_tables()
    -- create device table
    local res = db:query([[
        create table if not exists `device` (
			`udid` varchar(100) COLLATE utf8mb4_bin UNIQUE NOT NULL,
            `device_product` varchar(45) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            `device_version` varchar(45) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            `appleacc_name` varchar(45) COLLATE utf8mb4_bin NOT NULL,
            PRIMARY KEY (`udid`),
			UNIQUE KEY `id_UNIQUE` (`udid`)
        )ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
    ]])
    print(dump(res))

    -- create apple app table
    res = db:query([[
        create table if not exists `app` (
			`udid` varchar(100) COLLATE utf8mb4_bin NOT NULL,
            `appname` varchar(100) COLLATE utf8mb4_bin NOT NULL,
            `download_path` varchar(512) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
            PRIMARY KEY (`udid`, `appname`)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
    ]])
    print(dump(res))
end

skynet.start(function()

	local function on_connect(db)
		-- db:query("set charset utf8");
	end
	db = mysql.connect({
		host = "127.0.0.1",
		port = 3306,
		database = "ipamaker",
		user = "root",
		password = "111111",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
        print("failed to connect")
        return
	end
	print("success to connect to mysql server")

    init_tables()
    
    skynet.dispatch("lua", function(_, __, cmd, ...)
        if type(handle[cmd]) == 'function' then
            skynet.ret(skynet.pack(handle[cmd](...)))
            return
        end
        skynet.ret(skynet.pack(-100, "invalid cmd: " .. cmd))
    end)
end)