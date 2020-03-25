local function kv(k, v)
    return {
        key = k,
        value = v,
    }
end

local att_key = {
    coin = "coin",
    nickname = "nickname",
}

local function login_sc()
    return {
        cmd = "login_sc",
        ret_code = 0,
        errr_msg = "",
    }
end

local function register_sc()
    return {
        cmd = "register_sc",
        ret_code = 0,
        errr_msg = "",
    }
end

local function updateatt_sc()
    return {
        cmd = "updateAtt_sc",
        strs = {},
        nums = {},
    }
end

return {
    kv = kv,
    att_key = att_key,
    login_sc = login_sc,
    register_sc = register_sc,
    updateatt_sc = updateatt_sc,
}