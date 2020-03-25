
local ATT_KEY = {
    coin = "coin",
    nickname = "nickname",
}

local SCENE_ID = {
    lobby = 1,
    catchfish = 2,
}

local function kv(k, v)
    return {
        key = k,
        value = v,
    }
end

local function ping()
    return {
        cmd = "ping",
        time_ms = 0,
    }
end

local function pong()
    return {
        cmd = "pong",
        time_ms = 0,
        -- delay_ms = 0,
    }
end

local function login_sc()
    return {
        cmd = "login_sc",
        ret_code = 0,
        err_msg = "",
    }
end

local function register_sc()
    return {
        cmd = "register_sc",
        ret_code = 0,
        err_msg = "",
    }
end

local function updateatt_sc()
    return {
        cmd = "updateAtt_sc",
        strs = {},
        nums = {},
    }
end

local function enterscene_sc()

end

return {
    ATT_KEY = ATT_KEY,
    SCENE_ID = SCENE_ID,
    kv = kv,
    ping = ping,
    pong = pong,
    login_sc = login_sc,
    register_sc = register_sc,
    updateatt_sc = updateatt_sc,
}