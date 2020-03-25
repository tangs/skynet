package.path = package.path .. ";lualib/?.lua;examples/?.lua;test/?.lua"

local skynet = require "skynet"
require "skynet.manager"

local msg_maker = require "msg.msg_maker"
local sn_helper = require "utils.skynet_helper"

local handle = {}
local att_whilelist = {
    "nickname",
}

local function update_att(info, k, v)
    print("modify_atts_cs: " .. k .. ", " .. v)
    if att_whilelist[k] ~= nil or true then
        local data = msg_maker.kv(k, v)
        local mysql = skynet.newservice("test/mysql")
        local ret_code, err = skynet.call(mysql, "lua", "update_info", data, info)
        if ret_code == 0 then return true end
        print("err: " .. err)
    end
    return false
end

handle.modify_atts_cs = function (info, msg)
    -- print("handle.modify_atts_cs.")
    if msg == nil then return end
    local res_msg = msg_maker.updateatt_sc()
    if type(msg.nums) == 'table' then
        for _, item in ipairs(msg.nums) do
            if update_att(info, item.key, item.value) then
                table.insert(res_msg.nums, item)
            end
        end
    end
    if type(msg.strs) == 'table' then
        for _, item in ipairs(msg.strs) do
            if update_att(info, item.key, item.value) then
                table.insert(res_msg.strs, item)
            end
        end
    end
    
    local res_data = sn_helper.mk_res(0)
    res_data.info = info
    table.insert(res_data.msges, res_msg)
    skynet.ret(skynet.pack(res_data))
end

function dispatcher()

    skynet.dispatch("lua", function(_, __, cmd, msg, info)
        print("cmd: " .. cmd)
        if type(handle[cmd]) == 'function' then
            handle[cmd](info, msg)
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
