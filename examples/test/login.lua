local skynet = require "skynet"
require "skynet.manager"

function dispatcher()
    skynet.dispatch("lua", function(_, _, data)
        local ret = false
        print(data.name, data.pwd)
        if data and data.name and data.name == data.pwd then ret = true end
        skynet.ret(skynet.pack(ret))
        skynet.exit()
    end)
end

skynet.start(dispatcher);
