local skynet = require "skynet"
require "skynet.manager"

local command = {}

function command.HELLO(what)
    return "I'm echo server. get this:" .. what
end

function dispatcher()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        cmd = cmd:upper()
        if (cmd == "HELLO") then
            local f = command[cmd]
            assert(f)
            skynet.ret(skynet.pack(f(...)))
        else 
            skynet.ret(skynet.pack(cmd))
        end
    end)
    skynet.register("echo")
end

skynet.start(dispatcher);
