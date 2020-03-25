package.path = package.path .. ";lualib/?.lua;examples/?.lua;test/?.lua"

local skynet = require "skynet"
require "skynet.manager"

local msg_helper = require "msg.msg_helper"
local msg_maker = require "msg.msg_maker"
local sn_helper = require "utils.skynet_helper"

function dispatcher()
    skynet.dispatch("lua", function(_, __, msg)
        print("start auth:" .. msg.name .. ", " .. msg.pwd)
        local mysql = skynet.newservice("test/mysql")
        local ret_code, err, info = skynet.call(mysql, "lua", "register", msg)

        local res_msg = msg_maker.register_sc()
        res_msg.err_msg = err
        res_msg.ret_code = ret_code

        local res_data = sn_helper.mk_res(ret_code, err)
        res_data.info = info
        table.insert(res_data.msges, res_msg)

        skynet.ret(skynet.pack(res_data))
        skynet.exit()
    end)
end

skynet.start(dispatcher);
