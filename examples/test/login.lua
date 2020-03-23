local skynet = require "skynet"
require "skynet.manager"

function dispatcher()
    skynet.dispatch("lua", function(_, _, cmd, data)
        if cmd == "login" then
            local ret = false
            print(data.name, data.pwd)
            local mysql = skynet.queryservice("test/mysql")
            local ret = skynet.call(mysql, "lua", "login", data)
            skynet.ret(skynet.pack(ret))
            skynet.exit()
        elseif cmd == "register" then
            local ret = false
            print(data.name, data.pwd)
            local mysql = skynet.queryservice("test/mysql")
            local ret = skynet.call(mysql, "lua", "register", data)
            skynet.ret(skynet.pack(ret))
            skynet.exit()
        end
    end)
end

skynet.start(dispatcher);
