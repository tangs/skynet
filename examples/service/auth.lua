package.path = package.path .. ";lualib/?.lua;examples/?.lua;test/?.lua"

local skynet = require "skynet"
require "skynet.manager"

local msg_helper = require "msg.msg_helper"
local msg_maker = require "msg.msg_maker"

function dispatcher()
    skynet.dispatch("lua", function(_, __, msg)
        print("start auth:" .. msg.name .. ", " .. msg.pwd)
        local mysql = skynet.queryservice("test/mysql")
        local ret_code, err, info = skynet.call(mysql, "lua", "login", msg)
        local res_msg = msg_maker.login_sc()
        res_msg.errr_msg = err
        res_msg.ret_code = ret_code
        local res_data = {
            ret_code = ret_code,
            res_msg = err,
            info = info,
            msges = {
                [1] = res_msg
            }
        }
        skynet.ret(skynet.pack(res_data))
        skynet.exit()
    end)
end

skynet.start(dispatcher);
