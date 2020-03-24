local skynet = require "skynet"
require "skynet.manager"

function dispatcher()
    skynet.dispatch("lua", function(_, _, cmd, data)
        if cmd == "login_cs" then
            local ret = false
            print(data.name, data.pwd)
            local mysql = skynet.queryservice("test/mysql")
            local ret, err, info = skynet.call(mysql, "lua", "login", data)
            skynet.ret(skynet.pack("login_sc", ret, err, info))
            skynet.exit()
        elseif cmd == "register_cs" then
            local ret = false
            print(data.name, data.pwd)
            local mysql = skynet.queryservice("test/mysql")
            local ret, err, info = skynet.call(mysql, "lua", "register", data)
            skynet.ret(skynet.pack("register_sc", ret, err, info))
            skynet.exit()
        end
    end)
end

skynet.start(dispatcher);
