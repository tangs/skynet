package.path = package.path .. ";lualib/?.lua;examples/?.lua;test/?.lua"

local skynet = require "skynet"
require "skynet.manager"

local msg_maker = require "msg.msg_maker"
local sn_helper = require "utils.skynet_helper"

local handle = {}

local function update_att(info, k, v)
    return false
end

handle.modify_add = function (info, msg)
    if msg == nil then return end
    local res_msg = msg_maker.updateatt_sc()
    if type(msg.nums) == 'table' then
        for k, v in ipairs(msg.nums) do
            if update_att(info, k, v) then
                table.insert(res_msg.nums, msg_maker.kv(k, v))
            end
        end
    end
    if type(msg.strs) == 'table' then
        for k, v in ipairs(msg.strs) do
            if update_att(info, k, v) then
                table.insert(res_msg.strs, msg_maker.kv(k, v))
            end
        end
    end
end

function dispatcher()

    skynet.dispatch("lua", function(_, __, info, cmd, msg)
        if type(handle[cmd]) == 'function' then
            handle[cmd](msg)
        end
        -- local mysql = skynet.queryservice("test/mysql")
        -- local ret_code, err, info = skynet.call(mysql, "lua", "login", msg)

        -- local res_msg = msg_maker.login_sc()
        -- res_msg.err_msg = err
        -- res_msg.ret_code = ret_code

        -- local res_data = sn_helper.mk_res(ret_code, err)
        -- res_data.info = info
        -- table.insert(res_data.msges, res_msg)

        -- skynet.ret(skynet.pack(res_data))
        -- skynet.exit()
    end)
end

skynet.start(dispatcher);
