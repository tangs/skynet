local skynet = require "skynet"
require "skynet.manager"

local cfg = require "cfg"

local command = {}

local services = {}
local unfull_services = {}

local function start_services()
    for k, v in ipairs(cfg.apple_accouts) do
        -- print(v.name, v.fastlane)
        if services[v.name] == nil then
            local service = skynet.newservice("apple_acc")
            local ret = skynet.call(service, "lua", "isfull")
            if not ret then 
                table.insert(unfull_services, {
                    name = v.name,
                    service = service
                }) 
            end
            services[v.name] = service
        end
    end
end

local function dispatcher()
    start_services()
    local mysql = skynet.uniqueservice("mysql")
    skynet.dispatch("lua", function(_, __, appname, dev_info)
        local accname = ""
        if #unfull_services > 0 then accname = unfull_services[1].name end
        local ret, path = skynet.call(mysql, "lua", "query_app", appname, accname, dev_info)
        -- print(ret, path)
        if ret == 0 then 
            skynet.ret(skynet.pack(0, path))
            return
        end
        skynet.ret(skynet.pack(ret, path))
    end)
    skynet.register("apple_accs")
end

skynet.start(dispatcher);
