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
            skynet.call(service, "lua", "init", v.name)
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
        if type(dev_info) ~= 'table' or
        type(dev_info.udid) ~= "string" or
        #dev_info.udid == 0 then
            skynet.ret(skynet.pack(-100, "Invalid parameter dev_info."))
            return
        end
        local udid = dev_info.udid
        local ret, data = skynet.call(mysql, "lua", "query_app", appname, udid)
        local need_generate = false
        local service = nil
        if ret == 0 then
            skynet.ret(skynet.pack(ret, data))
            return
        elseif ret == 1 then
            -- TODO unregister device.
            if #unfull_services == 0 then
                skynet.ret(skynet.pack(-101, "Can't find unfull apple accout."))
                return
            end
            local service_info = unfull_services[1]
            local accname = service_info.name
            service = service_info.service
            local ret, msg = skynet.call(service, "lua", "register_device", accname, dev_info)
            if ret ~= 0 then
                skynet.ret(skynet.pack(ret, msg))
            end

            if skynet.call(service, "lua", "isfull") then
                table.remove(unfull_services, 1)
            end
            need_generate = true
        elseif ret == 2 then
            service = services[data]
            need_generate = true
        end
        if need_generate then
            if service == nil then
                skynet.ret(skynet.pack(-102, "Can't find apple accout service."))
                return
            end
            skynet.ret(skynet.pack(ret, data))
            -- call generate app service.
            local ret, data = skynet.call(service, "lua", "generate_app", appname, udid)
            return
        end
        skynet.ret(skynet.pack(ret, data))
    end)
    skynet.register("apple_accs")
end

skynet.start(dispatcher)