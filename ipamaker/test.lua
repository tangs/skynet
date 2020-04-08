local skynet = require "skynet"
require "skynet.manager"

local command = {}

function command.HELLO(what)
    return "I'm echo server. get this:" .. what
end

local function dispatcher()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        cmd = cmd:upper()
        print("aaaa")
        skynet.sleep(100)
        print("bbbb")
        skynet.ret(skynet.pack(cmd))
    end)
    skynet.register("test")
end

skynet.start(dispatcher);
