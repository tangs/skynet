local skynet = require "skynet"
require "skynet.manager"

local command = {}

local function dispatcher()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.ret(skynet.pack(false))
    end)
end

skynet.start(dispatcher);
