local skynet = require "skynet"
require "skynet.manager"

local handle = {}

local udids = {}
local appleacc_name = ""

handle.init = function (accname)
    appleacc_name = accname
    local mysql = skynet.uniqueservice("mysql")
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

local function dispatcher()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        -- skynet.ret(skynet.pack(false))
        if type(handle[cmd]) == 'function' then
            skynet.ret(skynet.pack(handle[cmd](...)))
            return
        end
        skynet.ret(skynet.pack(-100, "invalid cmd: " .. cmd))
    end)
end

skynet.start(dispatcher);
