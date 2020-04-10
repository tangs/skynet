local skynet = require "skynet"
require "skynet.manager"

local handle = {}

local udids = {}
local appleacc_name = ""
local mysql = nil

handle.init = function (accname)
    appleacc_name = accname
    local ret = skynet.call(mysql, "lua", "query_udids", accname)
    if type(ret) == "table" then
        for _, v in ipairs(ret) do
            if type(v.udid) == "string" then
                table.insert(udids, v.udid)
            end
        end
    end
end

handle.isfull = function ()
    return #udids >= 100
end

handle.register_device = function (accname, dev_info)
    if handle.isfull() then
        return -10, "apple account service is full."
    end
    local ret, msg = skynet.call(mysql, "lua", "register_device", accname, dev_info)
    if ret == 0 then
        table.insert(udids, dev_info.udid)
    end
    return ret, msg
end

handle.generate_app = function (appname, udid)

end

local function dispatcher()
    mysql = skynet.uniqueservice("mysql")
    skynet.dispatch("lua", function(session, address, cmd, ...)
        -- skynet.ret(skynet.pack(false))
        if type(handle[cmd]) == 'function' then
            skynet.ret(skynet.pack(handle[cmd](...)))
            return
        end
        skynet.ret(skynet.pack(-100, "invalid cmd: " .. cmd))
    end)
end

skynet.start(dispatcher)
